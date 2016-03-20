//
//  MessagesModel.m
//  IQ300
//
//  Created by Tayphoon on 03.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/CoreData/NSManagedObjectContext+RKAdditions.h>

#import "MessagesModel.h"
#import "IQService+Messages.h"
#import "IQConversation.h"
#import "ConversationCell.h"
#import "IQUser.h"
#import "IQCounters.h"
#import "IQNotificationCenter.h"
#import "ConversationDeletedObjects.h"

#import "NSManagedObject+ActiveRecord.h"
#import "NSManagedObjectContext+AsyncFetch.h"

#define CACHE_FILE_NAME @"ConversationModelcache"
#define SORT_DIRECTION IQSortDirectionDescending
#define LAST_REQUEST_DATE_KEY @"conversation_ids_request_date"

static NSString * MReuseIdentifier = @"MReuseIdentifier";

@interface MessagesModel() <NSFetchedResultsControllerDelegate> {
    NSInteger _portionLenght;
    NSArray * _sortDescriptors;
    NSFetchedResultsController * _fetchController;
    NSInteger _unreadItemsCount;
    __weak id _newMessageObserver;
    __weak id _conversationsChangedObserver;
    NSMutableSet * _filteredIds;
}

@end

@implementation MessagesModel

+ (void)createConversationWithRecipientId:(NSNumber*)recipientId completion:(void (^)(IQConversation * conversation, NSError * error))completion {
    [[IQService sharedService] createConversationWithRecipientId:recipientId
                                                         handler:^(BOOL success, IQConversation * conversation, NSData *responseData, NSError *error) {
                                                             if (success) {
                                                                 [GAIService sendEventForCategory:GAIMessagesEventCategory
                                                                                           action:@"event_action_message_conversation_create"];
                                                             }
                                                             
                                                             if(completion) {
                                                                 completion(conversation, error);
                                                             }
                                                         }];
}

+ (void)createConferenceWithUserIds:(NSArray*)userIds completion:(void (^)(IQConversation * conversation, NSError * error))completion {
    [[IQService sharedService] createConversationWithRecipientIds:userIds
                                                          handler:^(BOOL success, IQConversation * conversation, NSData *responseData, NSError *error) {
                                                              if (success) {
                                                                  [GAIService sendEventForCategory:GAIMessagesEventCategory
                                                                                            action:@"event_action_message_conversation_create"];
                                                                  
                                                                  NSArray * userIds = [[conversation.users allObjects] valueForKey:@"userId"];
                                                                  [GAIService sendEventForCategory:GAIMessagesEventCategory
                                                                                            action:GAIAddConversationMemberEventAction
                                                                                             label:[userIds componentsJoinedByString:@", "]];
                                                              }
                                                              
                                                              if(completion) {
                                                                  completion(conversation, error);
                                                              }
                                                          }];

}

+ (void)markConversationAsRead:(IQConversation *)conversation completion:(void (^)(NSError *))completion {
    if(conversation) {
        
        if([conversation.unreadCommentsCount integerValue] > 0) {
            conversation.unreadCommentsCount = @(0);
            
            NSError *saveError = nil;
            if(![conversation.managedObjectContext saveToPersistentStore:&saveError] ) {
                NSLog(@"Save conversation error: %@", saveError);
            }
        }
        
        [[IQService sharedService] markDiscussionAsReadedWithId:conversation.discussion.discussionId
                                                        handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                            if(completion) {
                                                                completion(error);
                                                            }
                                                        }];
    }
}

#pragma mark - Static private methods

+ (void)removeLocalConversationsWithIds:(NSArray *)conversationIds inContext:(NSManagedObjectContext*)context {
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQConversation"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"conversationId IN %@", conversationIds]];
    [context executeFetchRequest:fetchRequest completion:^(NSArray * objects, NSError * error) {
        if ([objects count] > 0) {
            for (IQConversation * conversation in objects) {
                if (![conversation.locked boolValue]) {
                    [self removeLocalCommentsByDiscussionId:conversation.discussion.discussionId
                                                  inContext:context];
                    [context deleteObject:conversation];
                }
            }
            
            NSError * saveError = nil;
            [context saveToPersistentStore:&saveError];
        }
    }];
}

+ (void)removeLocalCommentsByDiscussionId:(NSNumber*)discussionId inContext:(NSManagedObjectContext*)context {
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQComment"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"discussionId == %@", discussionId]];
    [context executeFetchRequest:fetchRequest completion:^(NSArray * objects, NSError * error) {
        for (NSManagedObject * comment in objects) {
            [context deleteObject:comment];
        }
    }];
}

+ (NSDate*)lastRequestDate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:LAST_REQUEST_DATE_KEY];
}

+ (void)setLastRequestDate:(NSDate*)date {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:date forKey:LAST_REQUEST_DATE_KEY];
}

#pragma mark - MessagesModel

- (id)init {
    self = [super init];
    if(self) {
        NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"discussion.updateDate" ascending:SORT_DIRECTION == IQSortDirectionAscending];
        _sortDescriptors = @[descriptor];
        _portionLenght = 20;
        _unreadItemsCount = 0;
        self.modelUpdateRequired = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(accountDidChanged)
                                                     name:AccountDidChangedNotification
                                                   object:nil];

        [self resubscribeToIQNotification];
    }
    return self;
}

- (void)setFilter:(NSString *)filter {
    _filter = filter;
    _filteredIds = nil;
}

- (NSUInteger)numberOfSections {
    return 1;
}

- (NSString*)titleForSection:(NSInteger)section {
    return nil;
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [_fetchController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    return MReuseIdentifier;
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    Class cellClass = [ConversationCell class];
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                            reuseIdentifier:MReuseIdentifier];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    IQConversation * item = [self itemAtIndexPath:indexPath];
    return [ConversationCell heightForItem:item andCellWidth:320.0f];
}

- (id)itemAtIndexPath:(NSIndexPath*)indexPath {
    if(indexPath.section < [self numberOfSections] &&
       indexPath.row < [self numberOfItemsInSection:indexPath.section]) {
        return [_fetchController objectAtIndexPath:indexPath];
    }
    return nil;
}

- (NSIndexPath *)indexPathOfObject:(id)object {
    return [_fetchController indexPathForObject:object];
}

- (Class)controllerClassForItemAtIndexPath:(NSIndexPath*)indexPath {
    return nil;
}

- (void)updateModelWithCompletion:(void (^)(NSError *))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelWithCompletion:completion];
    }
    else {
        [self clearRemovedConversations];

        BOOL isFilterEnabled = ([_filter length] > 0);
        [[IQService sharedService] conversationsUnread:(_loadUnreadOnly) ? @(YES) : nil
                                                  page:@(1)
                                                   per:@(_portionLenght)
                                                search:_filter
                                                  sort:SORT_DIRECTION
                                               handler:^(BOOL success, NSArray * conversations, NSData *responseData, NSError *error) {
                                                   if(success) {
                                                       [self updateCounters];
                                                       if (isFilterEnabled) {
                                                           [self updateFilteredIdsWithArray:[conversations valueForKey:@"conversationId"]];
                                                           [self reloadModelSourceControllerWithCompletion:nil];
                                                       }
                                                   }
                                                   
                                                   [self reloadModelSourceControllerWithCompletion:nil];

                                                   if(completion) {
                                                       completion(error);
                                                   }
                                               }];
    }
}

- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelWithCompletion:completion];
    }
    else {
        BOOL isFilterEnabled = ([_filter length] > 0);
        NSInteger count = [self numberOfItems];
        NSInteger page = (count > 0) ? count / _portionLenght + 1 : 1;
        [[IQService sharedService] conversationsUnread:(_loadUnreadOnly) ? @(YES) : nil
                                                  page:@(page)
                                                   per:@(_portionLenght)
                                                search:_filter
                                                  sort:SORT_DIRECTION
                                               handler:^(BOOL success, NSArray * conversations, NSData *responseData, NSError *error) {
                                                   if(success) {
                                                       [self updateCounters];
                                                       if (isFilterEnabled) {
                                                           [self updateFilteredIdsWithArray:[conversations valueForKey:@"conversationId"]];
                                                           [self reloadModelSourceControllerWithCompletion:nil];
                                                       }
                                                   }
                                                   
                                                   if(completion) {
                                                       completion(error);
                                                   }
                                               }];
    }
}

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion {
    [self clearRemovedConversations];
    
    BOOL isFilterEnabled = ([_filter length] > 0);
    void(^conversationsRequestBlock)(NSError * error) = ^(NSError * error){
        [[IQService sharedService] conversationsUnread:(_loadUnreadOnly) ? @(YES) : nil
                                                  page:@(1)
                                                   per:@(_portionLenght)
                                                search:_filter
                                                  sort:SORT_DIRECTION
                                               handler:^(BOOL success, NSArray * conversations, NSData *responseData, NSError *error) {
                                                   if(success) {
                                                       [self updateCounters];
                                                       if (isFilterEnabled) {
                                                           [self updateFilteredIdsWithArray:[conversations valueForKey:@"conversationId"]];
                                                           [self reloadModelSourceControllerWithCompletion:nil];
                                                       }
                                                   }
                                                   
                                                   if(completion) {
                                                       completion(error);
                                                   }
                                               }];
    };
    
    if (isFilterEnabled) {
        [self filteredConversationIdsWithCompletion:^(NSArray *objects, NSError *error) {
            if (!error) {
                [self updateFilteredIdsWithArray:objects];
                [self reloadModelSourceControllerWithCompletion:^(NSError *error) {
                    if (!error) {
                        [self modelDidChanged];
                    }
                }];
                conversationsRequestBlock(nil);
            }
        }];
    }
    else {
        [self reloadModelSourceControllerWithCompletion:^(NSError *error) {
            if (!error) {
                [self modelDidChanged];
            }
        }];
        
        conversationsRequestBlock(nil);
    }
}

- (void)reloadModelSourceControllerWithCompletion:(void (^)(NSError * error))completion {
    _fetchController.delegate = nil;
    
    [NSFetchedResultsController deleteCacheWithName:CACHE_FILE_NAME];
    _fetchController = nil;
    
    if(!_fetchController && [IQService sharedService].context) {
        NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQConversation"];
        [fetchRequest setSortDescriptors:_sortDescriptors];
        _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                               managedObjectContext:[IQService sharedService].context
                                                                 sectionNameKeyPath:nil
                                                                          cacheName:CACHE_FILE_NAME];
    }
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"ownerId == %@", [IQSession defaultSession].userId];
    if(_loadUnreadOnly) {
        NSPredicate * readCondition = [NSPredicate predicateWithFormat:@"unreadCommentsCount > 0"];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[readCondition, predicate]];
    }
    
    NSPredicate * filterPredicate = nil;
    if([_filteredIds count] > 0) {
        NSArray * filteredIds = ([_filteredIds count] > 0) ? [_filteredIds allObjects] : [NSArray array];
        filterPredicate = [NSPredicate predicateWithFormat:@"conversationId IN %@", filteredIds];
    }
    
    if([_filter length] > 0) {
        NSString * filterformat = @"SUBQUERY(users, $user, $user.displayName CONTAINS[cd] %@).@count > 0";
        NSPredicate * filterTextPredicate = [NSPredicate predicateWithFormat:filterformat, _filter];
        
        filterPredicate = (filterPredicate) ? [NSCompoundPredicate orPredicateWithSubpredicates:@[filterPredicate, filterTextPredicate]] :
                                               filterTextPredicate;
    }
    
    if (filterPredicate) {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, filterPredicate]];
    }
    
    NSError * fetchError = nil;
    [_fetchController.fetchRequest setPredicate:predicate];
    [_fetchController.fetchRequest setSortDescriptors:_sortDescriptors];
    [_fetchController setDelegate:self];
    [_fetchController performFetch:&fetchError];
    
    if(completion) {
        completion(fetchError);
    }
}

- (void)clearModelData {
    [NSFetchedResultsController deleteCacheWithName:CACHE_FILE_NAME];
    _filteredIds = nil;
    if(_fetchController) {
        [_fetchController.fetchRequest setPredicate:[NSPredicate predicateWithValue:NO]];
        [_fetchController performFetch:nil];
        [_fetchController setDelegate:nil];
        _fetchController = nil;
    }
}

- (NSInteger)unreadItemsCount {
    return _unreadItemsCount;
}

- (void)updateCountersWithCompletion:(void (^)(IQCounters * counter, NSError * error))completion {
    [[IQService sharedService] conversationsCountersWithHandler:^(BOOL success, IQCounters * counter, NSData *responseData, NSError *error) {
        if(counter) {
            _unreadItemsCount = [counter.unreadCount integerValue];
        }
        if(completion) {
            completion(counter, error);
        }
    }];
}

#pragma mark - Private methods

/*
 Count conversations in context
 
 @return Total number of objects in context
*/

- (NSUInteger)numberOfItems {
    NSManagedObjectContext * context = [IQService sharedService].context;
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"ownerId == %@", [IQSession defaultSession].userId];
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQConversation"];
    [fetchRequest setPredicate:predicate];
    
    NSError * error;
    NSUInteger numberOfItems = [context countForFetchRequest:fetchRequest error:&error];
    
    return (numberOfItems != NSNotFound) ? numberOfItems : 0;
}

- (void)updateFilteredIdsWithArray:(NSArray*)conversationIds {
    if (!_filteredIds) {
        _filteredIds = [[NSMutableSet alloc] init];
    }
    
    [_filteredIds addObjectsFromArray:conversationIds];
}

- (void)updateModel {
    [self updateModelWithCompletion:^(NSError *error) {
        [self modelDidChanged];
    }];
}

- (void)updateCounters {
    [self updateCountersWithCompletion:^(IQCounters * counter, NSError *error) {
        if(!error) {
            [self modelCountersDidChanged];
        }
    }];
}

- (void)resubscribeToIQNotification {
    [self unsubscribeFromIQNotification];
    
    __weak typeof(self) weakSelf = self;
    void (^block)(IQCNotification * notf) = ^(IQCNotification * notf) {
        NSDictionary * commentData = notf.userInfo[IQNotificationDataKey][@"comment"];
        NSString * disscusionParentType = [commentData[@"discussable"][@"type"] lowercaseString];
        NSNumber * authorId = commentData[@"author"][@"id"];
        
        if(authorId && ![authorId isEqualToNumber:[IQSession defaultSession].userId] &&
           [disscusionParentType isEqualToString:@"conversation"]) {
            if (weakSelf.isModelUpdateRequired) {
                [weakSelf updateModel];
            }
            else {
                [weakSelf updateCounters];
            }
        }
    };
    
    _newMessageObserver = [[IQNotificationCenter defaultCenter] addObserverForName:IQNewMessageNotification
                                                                             queue:nil
                                                                        usingBlock:block];
    
    void (^conversationsBlock)(IQCNotification * notf) = ^(IQCNotification * notf) {
        if (weakSelf.isModelUpdateRequired) {
            [weakSelf updateModel];
        }
        else {
            [weakSelf updateCounters];
        }
    };
    
    _conversationsChangedObserver = [[IQNotificationCenter defaultCenter] addObserverForName:IQConversationsDidChanged
                                                                                       queue:nil
                                                                                  usingBlock:conversationsBlock];
}

- (void)unsubscribeFromIQNotification {
    if(_newMessageObserver) {
        [[IQNotificationCenter defaultCenter] removeObserver:_newMessageObserver];
    }
    
    if (_conversationsChangedObserver) {
        [[IQNotificationCenter defaultCenter] removeObserver:_conversationsChangedObserver];
    }
}

- (void)accountDidChanged {
    if([IQSession defaultSession]) {
        [self resubscribeToIQNotification];
        [self updateCounters];
    }
    else {
        [self unsubscribeFromIQNotification];
        [self clearModelData];
        [self modelDidChanged];
    }
}

- (void)filteredConversationIdsWithCompletion:(void (^)(NSArray *objects, NSError *error))completion {
    NSManagedObjectContext * context = [IQService sharedService].context;
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"body CONTAINS[cd] %@", _filter];
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"IQComment"];
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToFetch:@[@"discussionId"]];
    [request setPredicate:predicate];
    
    [context executeFetchRequest:request completion:^(NSArray *objects, NSError *error) {
        if([objects count] > 0) {
            NSError * fetchError = nil;
            NSArray * discussionIds = [objects valueForKey:@"discussionId"];
            NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IQConversation"];
            [fetchRequest setResultType:NSDictionaryResultType];
            [fetchRequest setPropertiesToFetch:@[@"conversationId"]];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"discussion.discussionId IN %@", discussionIds]];
            NSArray * conversationIds = [context executeFetchRequest:fetchRequest error:&fetchError];
            
            if (completion) {
                completion([conversationIds valueForKey:@"conversationId"], fetchError);
            }
        }
        else if(completion) {
            completion(nil, error);
        }
    }];
}

#pragma mark - Clear removed conversations

- (void)clearRemovedConversations {
    NSDate *lastRequestDate = [MessagesModel lastRequestDate];
    
    [[IQService sharedService] conversationsIdsDeletedAfter:lastRequestDate
                                                    handler:^(BOOL success, ConversationDeletedObjects *object, NSData *responseData, NSError *error) {
                                                        if (success) {
                                                            [MessagesModel setLastRequestDate:object.serverDate];
                                                            
                                                            if ([object.objectIds count] > 0) {
                                                                NSManagedObjectContext * context = [IQService sharedService].context;
                                                                [MessagesModel removeLocalConversationsWithIds:object.objectIds
                                                                                                     inContext:context];
                                                            }
                                                        }
                                                    }];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller {
    [self modelWillChangeContent];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    [self modelDidChangeSectionAtIndex:sectionIndex
                         forChangeType:type];
}

- (void)controller:(NSFetchedResultsController*)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    [self modelDidChangeObject:anObject
                   atIndexPath:indexPath
                 forChangeType:type
                  newIndexPath:newIndexPath];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller {
    [self modelDidChangeContent];
}

#pragma mark - Delegate methods

- (void)modelWillChangeContent {
    if ([self.delegate respondsToSelector:@selector(modelWillChangeContent:)]) {
        [self.delegate modelWillChangeContent:self];
    }
}

- (void)modelDidChangeSectionAtIndex:(NSUInteger)sectionIndex forChangeType:(NSInteger)type {
    if ([self.delegate respondsToSelector:@selector(model:didChangeSectionAtIndex:forChangeType:)]) {
        [self.delegate model:self didChangeSectionAtIndex:sectionIndex forChangeType:type];
    }
}

- (void)modelDidChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSInteger)type newIndexPath:(NSIndexPath *)newIndexPath {
    if ([self.delegate respondsToSelector:@selector(model:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
        [self.delegate model:self didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    }
}

- (void)modelDidChangeContent {
    if ([self.delegate respondsToSelector:@selector(modelDidChangeContent:)]) {
        [self.delegate modelDidChangeContent:self];
    }
}

- (void)modelDidChanged {
    if([self.delegate respondsToSelector:@selector(modelDidChanged:)]) {
        [self.delegate modelDidChanged:self];
    }
}

- (void)modelCountersDidChanged {
    if([self.delegate respondsToSelector:@selector(modelCountersDidChanged:)]) {
        [self.delegate modelCountersDidChanged:self];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unsubscribeFromIQNotification];
}

@end
