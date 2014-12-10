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
#import "CommentCell.h"
#import "IQConversation.h"
#import "IQUser.h"
#import "IQCounters.h"

#define CACHE_FILE_NAME @"ConversationModelcache"
#define SORT_DIRECTION IQSortDirectionDescending

static NSString * MReuseIdentifier = @"MReuseIdentifier";

@interface MessagesModel() <NSFetchedResultsControllerDelegate> {
    NSInteger _portionLenght;
    NSArray * _sortDescriptors;
    NSFetchedResultsController * _fetchController;
    NSInteger _totalItemsCount;
    NSInteger _unreadItemsCount;
    __weak id _notfObserver;
}

@end

@implementation MessagesModel

+ (void)createConversationWithRecipientId:(NSNumber*)recipientId completion:(void (^)(IQConversation * conv, NSError * error))completion {
    [[IQService sharedService] createConversationWithRecipientId:recipientId
                                                         handler:^(BOOL success, IQConversation * conv, NSData *responseData, NSError *error) {
                                                             if(completion) {
                                                                 completion(conv, error);
                                                             }
                                                         }];
}

+ (void)markConversationAsRead:(IQConversation *)conversation completion:(void (^)(NSError *))completion {
    if(conversation) {
        
        if([conversation.unreadCommentsCount integerValue] > 0) {
            conversation.unreadCommentsCount = @(0);
            
            NSError *saveError = nil;
            if(![conversation.managedObjectContext saveToPersistentStore:&saveError] ) {
                NSLog(@"Save error: %@", saveError);
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

- (id)init {
    if(self) {
        _portionLenght = 20;
        NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"lastComment.createDate" ascending:SORT_DIRECTION == IQSortDirectionAscending];
        _sortDescriptors = @[descriptor];
        _totalItemsCount = 0;
        _unreadItemsCount = 0;
    }
    return self;
}

- (NSUInteger)numberOfSections {
    return [_fetchController.sections count];
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
    Class cellClass = [CommentCell class];
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                            reuseIdentifier:MReuseIdentifier];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    IQConversation * item = [self itemAtIndexPath:indexPath];
    return [CommentCell heightForItem:item.lastComment andCellWidth:320.0f];
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

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelWithCompletion:completion];
    }
    else {
        NSInteger count = [self numberOfItemsInSection:0];
        NSInteger page = (count > 0) ? count / _portionLenght + 1 : 0;
        [[IQService sharedService] conversationsUnread:(_loadUnreadOnly) ? @(YES) : nil
                                                  page:@(page)
                                                   per:@(_portionLenght)
                                                search:_filter
                                                  sort:IQSortDirectionAscending
                                               handler:^(BOOL success, NSArray * conversations, NSData *responseData, NSError *error) {
                                                   if(completion) {
                                                       completion(error);
                                                   }
                                               }];
    }
}


- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion {
    [self updateModelSourceControllerWithCompletion:completion];
    [[IQService sharedService] conversationsUnread:(_loadUnreadOnly) ? @(YES) : nil
                                              page:@(1)
                                               per:@(_portionLenght)
                                            search:_filter
                                              sort:IQSortDirectionAscending
                                           handler:^(BOOL success, NSArray * conversations, NSData *responseData, NSError *error) {
                                               if(success) {
                                               }
                                           }];
}

- (void)reloadFirstPartWithCompletion:(void (^)(NSError * error))completion {
    [[IQService sharedService] conversationsUnread:nil
                                              page:@(1)
                                               per:@(_portionLenght)
                                            search:_filter
                                              sort:IQSortDirectionAscending
                                           handler:^(BOOL success, NSArray * conversations, NSData *responseData, NSError *error) {
                                               if(completion) {
                                                   completion(error);
                                               }
                                               if(success) {
                                               }
                                           }];
}


- (void)updateModelSourceControllerWithCompletion:(void (^)(NSError * error))completion {
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
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"ANY users.userId == %@", [IQSession defaultSession].userId];
    if(_loadUnreadOnly) {
        NSPredicate * readCondition = [NSPredicate predicateWithFormat:@"readed == NO"];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[readCondition, predicate]];
    }
    
    if([_filter length] > 0) {
        NSString * format = @"SUBQUERY(users, $user, $user.userId != %@ AND $user.displayName CONTAINS[cd] %@).@count > 0";
        NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:format, [IQSession defaultSession].userId, _filter];
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
    if(_fetchController) {
        [_fetchController.fetchRequest setPredicate:[NSPredicate predicateWithValue:NO]];
        [_fetchController performFetch:nil];
        [_fetchController setDelegate:nil];
        _fetchController = nil;
    }
}

- (NSInteger)totalItemsCount {
    return _totalItemsCount;
}

- (NSInteger)unreadItemsCount {
    return _unreadItemsCount;
}

- (void)updateCountersWithCompletion:(void (^)(NSError * error))completion {
    [[IQService sharedService] conversationsCountersWithHandler:^(BOOL success, IQCounters * counter, NSData *responseData, NSError *error) {
        if(success) {
            _totalItemsCount = [counter.totalCount integerValue];
            _unreadItemsCount = [counter.unreadCount integerValue];
        }
        if(completion) {
            completion(error);
        }
    }];
}

- (void)setSubscribedToSystemWakeNotifications:(BOOL)subscribed {
    if(subscribed) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadFirstPart)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationWillEnterForegroundNotification
                                                      object:nil];
    }
}

#pragma mark - Private methods

- (void)reloadFirstPart {
    [self reloadFirstPartWithCompletion:^(NSError *error) {
        
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
}

@end