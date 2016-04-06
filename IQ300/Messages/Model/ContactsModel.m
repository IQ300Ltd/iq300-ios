//
//  ContactsModel.m
//  IQ300
//
//  Created by Tayphoon on 09.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/CoreData/NSManagedObjectContext+RKAdditions.h>

#import "ContactsModel.h"
#import "IQService+Messages.h"
#import "ContactCell.h"
#import "IQContactsDeletedIds.h"
#import "NSManagedObjectContext+AsyncFetch.h"
#import "IQContact.h"
#import "IQChannel.h"
#import "IQUser.h"
#import "IQNotificationCenter.h"


#define SORT_DIRECTION IQSortDirectionDescending
#define LAST_REQUEST_DATE_KEY @"contacts_ids_request_date"

static NSString * UReuseIdentifier = @"UReuseIdentifier";

@interface ContactsModel() {
    NSMutableArray * _contacts;
    
    __weak id _userStatusChangedObserver;
    NSString *_currentUserStatusChangedChannelName;
}

@end

@implementation ContactsModel

+ (NSDate*)lastRequestDate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:LAST_REQUEST_DATE_KEY];
}

+ (void)setLastRequestDate:(NSDate*)date {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:date forKey:LAST_REQUEST_DATE_KEY];
}

+ (instancetype)modelWithPortionSize:(NSUInteger)portionSize {
    return [[self alloc] initWithPortionSize:portionSize];
}

- (id)initWithPortionSize:(NSUInteger)portionSize {
    self = [super init];
    if(self) {
        _contacts = [NSMutableArray array];
        _portionSize = portionSize;
        self.allowsMultipleSelection = YES;
        self.allowsDeselection = YES;
        self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:SORT_DIRECTION == IQSortDirectionAscending]];
    }
    return self;
}

- (id)init {
    return [self initWithPortionSize:20];
}

- (NSArray*)contacts {
    return [_contacts copy];
}

- (NSString*)cacheFileName {
    return @"ContactsModelCache";
}

- (NSString*)entityName {
    return @"IQContact";
}

- (NSManagedObjectContext*)context {
    return [IQService sharedService].context;
}

- (Class)cellClassForIndexPath:(NSIndexPath *)indexPath {
    return [ContactCell class];
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    Class cellClass = [self cellClassForIndexPath:indexPath];
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleSubtitle
                            reuseIdentifier:UReuseIdentifier];
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    return UReuseIdentifier;
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    return 68;
}

- (NSPredicate*)fetchPredicate {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"ownerId == %@", [IQSession defaultSession].userId];

    if([_filter length] > 0) {
        NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"(user.displayName CONTAINS[cd] %@) OR (user.email CONTAINS[cd] %@)", _filter, _filter];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, filterPredicate]];
    }
    
    if([_excludeUserIds count] > 0) {
        NSPredicate * usersPredicate = [NSPredicate predicateWithFormat:@"NOT (user.userId IN %@)", _excludeUserIds];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, usersPredicate]];
    }
    
    return predicate;
}

- (void)makeItemAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected {
    id item = [self itemAtIndexPath:indexPath];
    if (selected && ![_contacts containsObject:item]) {
        [_contacts addObject:item];
    }
    else if(!selected && [_contacts containsObject:item]) {
        [_contacts removeObject:item];
    }
}

- (BOOL)isItemSelectedAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self itemAtIndexPath:indexPath];
    return [_contacts containsObject:item];
}

- (NSArray*)selectedItems {
    return self.contacts;
}

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelWithCompletion:completion];
    }
    else {
        [self clearRemovedConversations];
        
        [[IQService sharedService] contactsWithPage:@(1)
                                                per:@(_portionSize)
                                               sort:SORT_DIRECTION
                                             search:_filter
                                            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                                                if(completion) {
                                                    completion(error);
                                                }
                                                [self subscribeToUserNotifications];
                                            }];
    }
}

- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelWithCompletion:completion];
    }
    else {
        NSInteger count = [self numberOfItemsInSection:0];
        NSInteger page = (count > 0) ? count / _portionSize + 1 : 1;
        [[IQService sharedService] contactsWithPage:@(page)
                                                per:@(_portionSize)
                                               sort:SORT_DIRECTION
                                             search:_filter
                                            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                                                if(completion) {
                                                    completion(error);
                                                }
                                                [self subscribeToUserNotifications];
                                            }];
    }
}

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion {
    [self reloadModelSourceControllerWithCompletion:^(NSError *error) {
        if (!error) {
            [self modelDidChanged];
        }
    }];

    [self clearRemovedConversations];

    [[IQService sharedService] contactsWithPage:@(1)
                                            per:@(_portionSize)
                                           sort:SORT_DIRECTION
                                         search:_filter
                                        handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                                            if(completion) {
                                                completion(error);
                                            }
                                            [self subscribeToUserNotifications];
                                        }];
}

#pragma mark - User subscrtiptions

- (void)subscribeToUserNotifications {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *indexes = [_fetchController.fetchedObjects valueForKeyPath:@"user.userId"];
        [[IQService sharedService] subscribeToUserStatusChangedNotification:indexes
                                                                    handler:^(BOOL success,  IQChannel *channel, NSData *responseData, NSError *error) {
                                                                        [self resubscribeToUserStatusChangedNotificationWithChannel:channel.name];
                                                                    }];
    });
}

- (void)resubscribeToUserStatusChangedNotificationWithChannel:(NSString *)channel {
    [self unsubscribeToUserStatusChangedNotification];
    
    if (channel) {
        __weak typeof(self) weakSelf = self;
        void (^block)(IQCNotification * notf) = ^(IQCNotification * notf) {
            [weakSelf modelWillChangeContent];
            
            NSArray *onlineUserIndexes = [notf.userInfo[IQNotificationDataKey] objectForKey:@"online_ids"];
            NSArray *offlineUserIndexes = [notf.userInfo[IQNotificationDataKey] objectForKey:@"offline_ids"];
            
            NSArray *onlineUsersMembers = [_fetchController.fetchedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"user.userId IN %@", onlineUserIndexes]];
            
            for (IQContact *member in  onlineUsersMembers) {
                member.user.online = @(YES);
                NSIndexPath *indexPath = [self indexPathOfObject:member];
                [self modelDidChangeObject:member atIndexPath:indexPath forChangeType:NSFetchedResultsChangeUpdate newIndexPath:nil];
            }
            
            NSArray *offlineUserMembers = [_fetchController.fetchedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"user.userId IN %@", offlineUserIndexes]];
            
            for (IQContact *member in  offlineUserMembers) {
                member.user.online = @(NO);
                NSIndexPath *indexPath = [self indexPathOfObject:member];
                [self modelDidChangeObject:member atIndexPath:indexPath forChangeType:NSFetchedResultsChangeUpdate newIndexPath:nil];
            }
            [[IQService sharedService].context saveToPersistentStore:nil];
            
            [weakSelf modelDidChangeContent];
        };
        
        _userStatusChangedObserver = [[IQNotificationCenter defaultCenter] addObserverForName:IQUserDidChangeStatusNotification
                                                                                  channelName:channel
                                                                                        queue:nil
                                                                                   usingBlock:block];
        
    }
    _currentUserStatusChangedChannelName = channel;
}

- (void)unsubscribeToUserStatusChangedNotification {
    if (_userStatusChangedObserver) {
        [[IQNotificationCenter defaultCenter] removeObserver:_userStatusChangedObserver];
    }
}




#pragma mark - Private methods

#pragma mark - Clear removed conversations

- (void)clearRemovedConversations {
    NSDate *lastRequestDate = [ContactsModel lastRequestDate];
    
    [[IQService sharedService] contactIdsDeletedAfter:lastRequestDate
                                              handler:^(BOOL success, IQContactsDeletedIds *object, NSData *responseData, NSError *error) {
                                                  if (success) {
                                                      [ContactsModel setLastRequestDate:object.serverDate];
                                                      
                                                      if ([object.objectIds count] > 0) {
                                                          NSManagedObjectContext * context = [IQService sharedService].context;
                                                          [self removeLocalContactsWithIds:object.objectIds
                                                                                               inContext:context];
                                                      }
                                                  }
                                              }];
}

- (void)removeLocalContactsWithIds:(NSArray*)contactIds inContext:(NSManagedObjectContext*)context {
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQContact"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"contactId IN %@", contactIds]];
    [context executeFetchRequest:fetchRequest completion:^(NSArray * objects, NSError * error) {
        if ([objects count] > 0) {
            for (IQContact * contact in objects) {
                [context deleteObject:contact];
            }
            
            NSError * saveError = nil;
            [context saveToPersistentStore:&saveError];
        }
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unsubscribeToUserStatusChangedNotification];
}

@end
