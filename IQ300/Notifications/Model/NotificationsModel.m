//
//  NotificationsModel.m
//  IQ300
//
//  Created by Tayphoon on 20.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/CoreData/NSManagedObjectContext+RKAdditions.h>

#import "NotificationsModel.h"
#import "IQService.h"
#import "NotificationCell.h"
#import "ActionNotificationCell.h"
#import "IQCounters.h"
#import "NSManagedObjectContext+AsyncFetch.h"
#import "IQNotificationCenter.h"
#import "IQNotificationsGroup.h"
#import "IQNotificationsHolder.h"

#define CACHE_FILE_NAME @"NotificationsModelcache"
#define SORT_DIRECTION IQSortDirectionAscending

static NSString * NReuseIdentifier = @"NReuseIdentifier";
static NSString * NActionReuseIdentifier = @"NActionReuseIdentifier";

@interface NotificationsModel() <NSFetchedResultsControllerDelegate> {
    NSInteger _portionLenght;
    NSArray * _sortDescriptors;
    NSFetchedResultsController * _fetchController;
    NSInteger _totalItemsCount;
    NSInteger _unreadItemsCount;
    __weak id _notfObserver;
}

@end

@implementation NotificationsModel

- (id)init {
    self = [super init];
    if(self) {
        _portionLenght = 20;
        NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt"
                                                                    ascending:NO];
        _sortDescriptors = @[descriptor];
        _loadUnreadOnly = YES;
        _totalItemsCount = 0;
        _unreadItemsCount = 0;
    }
    return self;
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
    IQNotification * item = [self itemAtIndexPath:indexPath];
    return ([item.hasActions boolValue]) ? NActionReuseIdentifier : NReuseIdentifier;
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    IQNotification * item = [self itemAtIndexPath:indexPath];
    Class cellClass = ([item.hasActions boolValue]) ? [ActionNotificationCell class] : [NotificationCell class];
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                            reuseIdentifier:[self reuseIdentifierForIndexPath:indexPath]];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    IQNotification * item = [self itemAtIndexPath:indexPath];
    Class cellClass = ([item.hasActions boolValue]) ? [ActionNotificationCell class] : [NotificationCell class];
    return [cellClass heightForItem:item
                        andCellWidth:self.cellWidth];
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
        [self updateCounters];
        [self notificationsUpdatesWithCompletion:completion];
    }
}

- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelWithCompletion:completion];
    }
    else {
        NSNumber * notificationId = [self getLastIdFromTop:NO];
        [[IQService sharedService] notificationsForGroupWithId:self.group.lastNotificationId
                                                      beforeId:notificationId
                                                        unread:(_loadUnreadOnly) ? @(YES) : nil
                                                          page:@(1)
                                                           per:@(_portionLenght)
                                                          sort:IQSortDirectionDescending
                                                       handler:^(BOOL success, IQNotificationsHolder * holder, NSData *responseData, NSError *error) {
                                                           if(completion) {
                                                               completion(error);
                                                           }
                                                       }];
    }
}

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion {
    [self reloadModelSourceControllerWithCompletion:completion];

    NSDate * lastUpdatedDate = [self getLastNotificationChangedDate];

    [self updateCounters];
    [[IQService sharedService] notificationsForGroupWithId:self.group.lastNotificationId
                                              updatedAfter:lastUpdatedDate
                                                    unread:@(NO)
                                                      page:@(1)
                                                       per:@(_portionLenght)
                                                      sort:(lastUpdatedDate) ? IQSortDirectionAscending : IQSortDirectionDescending
                                                   handler:^(BOOL success, IQNotificationsHolder * holder, NSData *responseData, NSError *error) {
                                                       if(success && lastUpdatedDate && [_fetchController.fetchedObjects count] < _portionLenght) {
                                                           [self tryLoadFullPartitionWithCompletion:^(NSError *error) {
                                                               if(completion) {
                                                                   completion(error);
                                                               }
                                                           }];
                                                       }
                                                       else if(completion) {
                                                           completion(error);
                                                       }
                                                   }];
}

- (void)reloadFirstPartWithCompletion:(void (^)(NSError * error))completion {
    BOOL hasObjects = ([_fetchController.fetchedObjects count] > 0);
    if(!hasObjects) {
        [self reloadModelSourceControllerWithCompletion:nil];
    }
    
    [self updateCounters];
    NSDate * lastUpdatedDate = [self getLastNotificationChangedDate];
    if(!lastUpdatedDate) {
        [[IQService sharedService] notificationsForGroupWithId:self.group.lastNotificationId
                                                  updatedAfter:nil
                                                        unread:@(NO)
                                                          page:@(1)
                                                           per:@(_portionLenght)
                                                          sort:IQSortDirectionAscending
                                                       handler:^(BOOL success, IQNotificationsHolder * holder, NSData *responseData, NSError *error) {
                                                           if(completion) {
                                                               completion(error);
                                                           }
                                                       }];
        
    }
    else {
        [self notificationsUpdatesWithCompletion:^(NSError *error) {
            if(!error && [_fetchController.fetchedObjects count] < _portionLenght) {
                [self tryLoadFullPartitionWithCompletion:^(NSError *error) {
                    if(completion) {
                        completion(error);
                    }
                }];
            }
            else if(completion) {
                completion(error);
            }
        }];
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

- (void)markNotificationAsReadAtIndexPath:(NSIndexPath*)indexPath completion:(void (^)(NSError * error))completion {
    IQNotification * item = [self itemAtIndexPath:indexPath];
    [[IQService sharedService] markNotificationAsRead:item.notificationId
                                              handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                  if(success) {
                                                      item.readed = @(YES);
                                                      
                                                      NSNumber * unreadCount = @(MAX([self.group.unreadCount integerValue] - 1, 0));
                                                      self.group.unreadCount = unreadCount;
                                                      
                                                      NSError *saveError = nil;
                                                      if(![item.managedObjectContext saveToPersistentStore:&saveError] ) {
                                                          NSLog(@"Save notification error: %@", saveError);
                                                      }
                                                      
                                                      [self updateCountersWithCompletion:^(IQCounters *counters, NSError *error) {
                                                          if(self.loadUnreadOnly && _unreadItemsCount > 0 &&
                                                             [_fetchController.fetchedObjects count] == 0) {
                                                              [self loadNextPartWithCompletion:nil];
                                                          }
                                                      }];
                                                  }
                                                  if(completion) {
                                                      completion(error);
                                                  }
                                              }];
}

- (void)markAllNotificationAsReadWithCompletion:(void (^)(NSError * error))completion {
    [[IQService sharedService] markNotificationsGroupAsReadWithId:self.group.lastNotificationId
                                                          handler:^(BOOL success, IQNotificationsGroup * group, NSData *responseData, NSError *error) {
                                                              if(success) {
                                                                  [self markAllLocalNotificationAsRead];
                                                                  [self updateCountersWithCompletion:^(IQCounters *counters, NSError *error) {
                                                                      if(self.loadUnreadOnly && _unreadItemsCount > 0 &&
                                                                         [_fetchController.fetchedObjects count] == 0) {
                                                                          [self loadNextPartWithCompletion:nil];
                                                                      }
                                                                  }];                                                              }
                                                              if(completion) {
                                                                  completion(error);
                                                              }
                                                          }];
}

- (void)updateCountersWithCompletion:(void (^)(IQCounters * counters, NSError * error))completion {
    [[IQService sharedService] notificationsCountForGroupWithId:self.group.lastNotificationId
                                                        handler:^(BOOL success, IQCounters * counter, NSData *responseData, NSError *error) {
        if(success) {
            _totalItemsCount = [counter.totalCount integerValue];
            _unreadItemsCount = [counter.unreadCount integerValue];
            [self modelCountersDidChanged];
        }
        if(completion) {
            completion(counter, error);
        }
    }];
}

- (void)setSubscribedToNotifications:(BOOL)subscribed {
    if(subscribed) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [self resubscribeToIQNotifications];
    }
    else {
        [[IQNotificationCenter defaultCenter] removeObserver:_notfObserver];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationWillEnterForegroundNotification
                                                      object:nil];
    }
}

- (void)acceptNotification:(IQNotification*)notification completion:(void (^)(NSError * error))completion {
    [[IQService sharedService] acceptNotificationWithId:notification.notificationId
                                                handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                    if(success) {
                                                        [self resetActionsForNotification:notification];
                                                        [self updateCounters];
                                                    }
                                                    if(completion) {
                                                        completion(error);
                                                    }
                                                }];
}

- (void)declineNotification:(IQNotification*)notification completion:(void (^)(NSError * error))completion {
    [[IQService sharedService] declineNotificationWithId:notification.notificationId
                                                 handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                     if(success) {
                                                         [self resetActionsForNotification:notification];
                                                         [self updateCounters];
                                                     }
                                                     if(completion) {
                                                         completion(error);
                                                     }
                                                 }];
}

#pragma mark - Private methods

- (void)notificationsUpdatesAfterDate:(NSDate*)lastUpdatedDate page:(NSNumber*)page completion:(void (^)(NSError * error))completion {
    [[IQService sharedService] notificationsForGroupWithId:self.group.lastNotificationId
                                              updatedAfter:lastUpdatedDate
                                                    unread:@(NO)
                                                      page:page
                                                       per:@(_portionLenght)
                                                      sort:IQSortDirectionAscending
                                                   handler:^(BOOL success, IQNotificationsHolder * holder, NSData *responseData, NSError *error) {
                                                       if(success && holder.currentPage < holder.totalPages) {
                                                           [self notificationsUpdatesAfterDate:lastUpdatedDate
                                                                                          page:@([page integerValue] + 1)
                                                                                    completion:completion];
                                                       }
                                                       else if(completion) {
                                                           completion(error);
                                                       }
                                                   }];
}

- (void)notificationsUpdatesWithCompletion:(void (^)(NSError * error))completion {
    NSDate * lastUpdatedDate = [self getLastNotificationChangedDate];
    [self notificationsUpdatesAfterDate:lastUpdatedDate
                                   page:@(1)
                             completion:completion];
}

- (NSDate*)getLastNotificationChangedDate {
    NSString * predicateFormat = @"ownerId = %@ AND groupSid == %@";
    NSPredicate * predicate = [NSPredicate predicateWithFormat:predicateFormat, [IQSession defaultSession].userId,
                               self.group.sID];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IQNotification"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]];
    [fetchRequest setPredicate:predicate];
    fetchRequest.fetchLimit = 1;
    
    NSError *error = nil;
    
    NSArray *objects = [[IQService sharedService].context executeFetchRequest:fetchRequest error:&error];
    if ([objects count] > 0) {
        IQNotification * lastNotification = ((IQNotification*)[objects objectAtIndex:0]);
        return lastNotification.updatedAt;
    }
    return nil;
}

- (void)updateGroupCounter {
    NSManagedObjectContext * context = _fetchController.managedObjectContext;
    NSPredicate * readCondition = [NSPredicate predicateWithFormat:@"(readed == NO || hasActions == YES) AND groupSid == %@", self.group.sID];
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQNotification"];
    [fetchRequest setPredicate:readCondition];
    [fetchRequest setIncludesSubentities:NO];
    
    NSError * error;
    NSUInteger unreadCount = [context countForFetchRequest:fetchRequest error:&error];
    if(unreadCount != NSNotFound && [self.group.unreadCount integerValue] != unreadCount) {

        self.group.unreadCount = @(unreadCount);
        
        if(![context saveToPersistentStore:&error]) {
            NSLog(@"Save notifications error: %@", error);
        }
    }
}

- (void)markAllLocalNotificationAsRead {
    NSManagedObjectContext * context = _fetchController.managedObjectContext;
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQNotification"];
    NSString * predicateFormat = @"readed == NO AND ownerId = %@ AND groupSid == %@";
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:predicateFormat, [IQSession defaultSession].userId,
                                                                                 self.group.sID]];
    [context executeFetchRequest:fetchRequest completion:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            [objects makeObjectsPerformSelector:@selector(setReaded:) withObject:@(YES)];
            NSError *saveError = nil;
            
            if(![context saveToPersistentStore:&saveError]) {
                NSLog(@"Save notifications error: %@", saveError);
            }
        }
    }];
}

- (void)resetActionsForNotification:(IQNotification*)notification {
    notification.hasActions = @(NO);
    notification.availableActions = nil;
    notification.readed = @(YES);
    
    NSNumber * unreadCount = @(MAX([self.group.unreadCount integerValue] - 1, 0));
    self.group.unreadCount = unreadCount;
    
    NSError *saveError = nil;
    if(![notification.managedObjectContext saveToPersistentStore:&saveError] ) {
        NSLog(@"Save notification error: %@", saveError);
    }
}

- (void)reloadModelSourceControllerWithCompletion:(void (^)(NSError * error))completion {
    _fetchController.delegate = nil;
    
    [NSFetchedResultsController deleteCacheWithName:CACHE_FILE_NAME];
    
    if(!_fetchController && [IQService sharedService].context) {
        NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQNotification"];
        [fetchRequest setSortDescriptors:_sortDescriptors];
        
        _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                               managedObjectContext:[IQService sharedService].context
                                                                 sectionNameKeyPath:nil
                                                                          cacheName:nil];
    }
    
    NSString * predicateFormat = @"ownerId = %@ AND groupSid == %@";
    NSPredicate * predicate = [NSPredicate predicateWithFormat:predicateFormat, [IQSession defaultSession].userId,
                                                                                self.group.sID];
    if(_loadUnreadOnly) {
        NSPredicate * readCondition = [NSPredicate predicateWithFormat:@"(readed == NO || hasActions == YES)"];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[readCondition, predicate]];
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

- (NSNumber*)getLastIdFromTop:(BOOL)top {
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IQNotification"];
    NSExpression * keyPathExpression = [NSExpression expressionForKeyPath:@"notificationId"];
    NSExpression * maxIdExpression = [NSExpression expressionForFunction:(top) ? @"max:" : @"min:"
                                                                  arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"notificationId"];
    [expressionDescription setExpression:maxIdExpression];
    [expressionDescription setExpressionResultType:NSDecimalAttributeType];
  
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    [fetchRequest setResultType:NSDictionaryResultType];
    fetchRequest.fetchLimit = 1;
    
    NSString * predicateFormat = @"ownerId = %@ AND groupSid == %@";
    NSPredicate * predicate = [NSPredicate predicateWithFormat:predicateFormat, [IQSession defaultSession].userId,
                                                                                self.group.sID];

    if(_loadUnreadOnly) {
        NSPredicate * readCondition = [NSPredicate predicateWithFormat:@"(readed == NO || hasActions == YES)"];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[readCondition, predicate]];
    }
    
    [fetchRequest setPredicate:predicate];

    NSError *error = nil;
    
    NSArray *objects = [[IQService sharedService].context executeFetchRequest:fetchRequest error:&error];
    if ([objects count] > 0) {
        return [[objects objectAtIndex:0] valueForKey:@"notificationId"];
    }
    return nil;
}

- (void)loadNotificationsWithIds:(NSArray*)ids {
    [[IQService sharedService] notificationsWithIds:ids
                                            handler:^(BOOL success, NSArray * notifications, NSData *responseData, NSError *error) {
                                                if(success) {
                                                    [self updateCounters];
                                                }
                                            }];
}

- (void)tryLoadFullPartitionWithCompletion:(void (^)(NSError * error))completion {
    NSNumber * lastLoadedId = [self getLastIdFromTop:YES];
    [[IQService sharedService] notificationsForGroupWithId:self.group.lastNotificationId
                                                  beforeId:lastLoadedId
                                                   unread:(_loadUnreadOnly) ? @(YES) : nil
                                                     page:@(1)
                                                      per:@(_portionLenght)
                                                     sort:IQSortDirectionDescending
                                                  handler:^(BOOL success, IQNotificationsHolder * holder, NSData *responseData, NSError *error) {
                                                      if(completion) {
                                                          completion(error);
                                                      }
                                                  }];
}

- (void)updateCounters {
    [self updateCountersWithCompletion:nil];
    [self initGlobalCounterUpdate];
}

- (void)initGlobalCounterUpdate {
    NSDictionary * userInfo = @{ ChangedCounterNameUserInfoKey : @"notifications" };
    [[NSNotificationCenter defaultCenter] postNotificationName:CountersDidChangedNotification
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)resubscribeToIQNotifications {
    [self unsubscribeFromIQNotifications];
    
    __weak typeof(self) weakSelf = self;
    void (^block)(IQCNotification * notf) = ^(IQCNotification * notf) {
        NSArray * changedIds = notf.userInfo[IQNotificationDataKey][@"object_ids"];
        if([changedIds respondsToSelector:@selector(count)] && [changedIds count] > 0) {
            [weakSelf reloadFirstPartWithCompletion:nil];
            [weakSelf initGlobalCounterUpdate];
        }
    };
    _notfObserver = [[IQNotificationCenter defaultCenter] addObserverForName:IQNotificationsDidChanged
                                                                       queue:nil
                                                                  usingBlock:block];
}

- (void)unsubscribeFromIQNotifications {
    if(_notfObserver) {
        [[IQNotificationCenter defaultCenter] removeObserver:_notfObserver];
    }
}

- (void)applicationWillEnterForeground {
    [self updateCounters];
    [self notificationsUpdatesWithCompletion:nil];
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
    [[IQNotificationCenter defaultCenter] removeObserver:_notfObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
