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
#import "IQNotification.h"

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
    NSNumber * _lastLoadedId;
}

@end

@implementation NotificationsModel

- (id)init {
    if(self) {
        _portionLenght = 20;
        NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt"
                                                                    ascending:NO];
        _sortDescriptors = @[descriptor];
        _loadUnreadOnly = YES;
        _totalItemsCount = 0;
        _unreadItemsCount = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(accountDidChanged)
                                                     name:AccountDidChangedNotification
                                                   object:nil];
        [self resubscribeToIQNotifications];
    }
    return self;
}

- (NSUInteger)numberOfSections {
    return 1;//[_fetchController.sections count];
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
        if(!_lastLoadedId) {
            _lastLoadedId = [self getLastIdFromTop:YES];
        }
        
        [self updateCounters];
        [self syncLocalNotificationsWithCompletion:nil];
        [[IQService sharedService] notificationsForGroupWithId:self.group.lastNotificationId
                                                       afterId:_lastLoadedId
                                                        unread:(_loadUnreadOnly) ? @(YES) : nil
                                                          page:@(1)
                                                           per:@(_portionLenght)
                                                          sort:SORT_DIRECTION
                                                       handler:^(BOOL success, NSArray * notifications, NSData *responseData, NSError *error) {
                                                           if(success && [notifications count] > 0) {
                                                               _lastLoadedId = [notifications valueForKeyPath:@"@max.notificationId"];
                                                           }
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
        NSNumber * notificationId = [self getLastIdFromTop:NO];
        [[IQService sharedService] notificationsForGroupWithId:self.group.lastNotificationId
                                                      beforeId:notificationId
                                                        unread:(_loadUnreadOnly) ? @(YES) : nil
                                                          page:@(1)
                                                           per:@(_portionLenght)
                                                          sort:IQSortDirectionDescending
                                                       handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                                                           if(completion) {
                                                               completion(error);
                                                           }
                                                       }];
    }
}

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion {
    [self reloadModelSourceControllerWithCompletion:completion];
  
    _lastLoadedId = [self getLastIdFromTop:YES];
    
    [[IQService sharedService] notificationsForGroupWithId:self.group.lastNotificationId
                                                   afterId:_lastLoadedId
                                                    unread:(_loadUnreadOnly) ? @(YES) : nil
                                                      page:@(1)
                                                       per:@(_portionLenght)
                                                      sort:(_lastLoadedId) ? IQSortDirectionAscending : IQSortDirectionDescending
                                                   handler:^(BOOL success, NSArray * notifications, NSData *responseData, NSError *error) {
                                                       if(success && [notifications count] > 0) {
                                                           _lastLoadedId = [notifications valueForKeyPath:@"@max.notificationId"];
                                                       }
                                                       
                                                       if(success && _lastLoadedId && [_fetchController.fetchedObjects count] < _portionLenght) {
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
    
    if(!_lastLoadedId) {
        _lastLoadedId = [self getLastIdFromTop:YES];
    }
    
    [self updateCountersWithCompletion:nil];
    [self syncLocalNotificationsWithCompletion:nil];
    [[IQService sharedService] notificationsForGroupWithId:self.group.lastNotificationId
                                                   afterId:_lastLoadedId
                                                    unread:(_loadUnreadOnly) ? @(YES) : nil
                                                      page:@(1)
                                                       per:@(_portionLenght)
                                                      sort:(_lastLoadedId) ? IQSortDirectionAscending : IQSortDirectionDescending
                                                   handler:^(BOOL success, NSArray * notifications, NSData *responseData, NSError *error) {
                                                       if(success && [notifications count] > 0) {
                                                           _lastLoadedId = [notifications valueForKeyPath:@"@max.notificationId"];
                                                       }
                                                       
                                                       if(success && _lastLoadedId && [_fetchController.fetchedObjects count] < _portionLenght) {
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
                                                  if(completion) {
                                                      completion(error);
                                                  }
                                                  if(success) {
                                                      item.readed = @(YES);
                                                      
                                                      NSNumber * unreadCount = @(MAX([self.group.unreadCount integerValue] - 1, 0));
                                                      self.group.unreadCount = unreadCount;
                                                      
                                                      NSError *saveError = nil;
                                                      if(![item.managedObjectContext saveToPersistentStore:&saveError] ) {
                                                          NSLog(@"Save notification error: %@", saveError);
                                                      }

                                                      [self updateCounters];
                                                  }
                                              }];
}

- (void)markAllNotificationAsReadWithCompletion:(void (^)(NSError * error))completion {
    [[IQService sharedService] markNotificationsGroupAsReadWithId:self.group.lastNotificationId
                                                          handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                              if(completion) {
                                                                  completion(error);
                                                              }
                                                              if(success) {
                                                                  [self markAllLocalNotificationAsRead];
                                                                  [self updateCounters];
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
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationWillEnterForegroundNotification
                                                      object:nil];
    }
}

- (void)acceptNotification:(IQNotification*)notification completion:(void (^)(NSError * error))completion {
    [[IQService sharedService] acceptNotificationWithId:notification.notificationId
                                                handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                    if(completion) {
                                                        completion(error);
                                                    }
                                                    if(success) {
                                                        [self resetActionsForNotification:notification];
                                                        [self updateCounters];
                                                    }
                                                }];
}

- (void)declineNotification:(IQNotification*)notification completion:(void (^)(NSError * error))completion {
    [[IQService sharedService] declineNotificationWithId:notification.notificationId
                                                 handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                     if(completion) {
                                                         completion(error);
                                                     }
                                                     if(success) {
                                                         [self resetActionsForNotification:notification];
                                                         [self updateCounters];
                                                     }
                                                 }];
}

- (void)syncLocalNotificationsWithCompletion:(void (^)(NSError * error))completion {
    [[IQService sharedService] unreadNotificationIdsWithHandler:^(BOOL success, NSArray * notificationIds, NSData *responseData, NSError *error) {
        if(success && [notificationIds count] > 0) {
            NSManagedObjectContext * context = _fetchController.managedObjectContext;
            NSPredicate * readCondition = [NSPredicate predicateWithFormat:@"(readed == NO || hasActions == YES) AND NOT(notificationId in %@)", notificationIds];
            NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQNotification"];
            [fetchRequest setPredicate:readCondition];
            [context executeFetchRequest:fetchRequest completion:^(NSArray *objects, NSError *error) {
                if ([objects count] > 0) {
                    [objects makeObjectsPerformSelector:@selector(setReaded:) withObject:@(YES)];
                    [objects makeObjectsPerformSelector:@selector(setHasActions:) withObject:@(NO)];
                    [objects makeObjectsPerformSelector:@selector(setAvailableActions:) withObject:nil];
                    NSError *saveError = nil;
                    
                    if(![context saveToPersistentStore:&saveError]) {
                        NSLog(@"Save notifications error: %@", saveError);
                    }
                }
            }];
        }
    }];
}

#pragma mark - Private methods

- (void)markAllLocalNotificationAsRead {
    self.group.unreadCount = @(0);
    
    NSNumber * notificableId = self.group.lastNotification.notificable.notificableId;
    NSString * notificableType = self.group.lastNotification.notificable.type;
    NSManagedObjectContext * context = _fetchController.managedObjectContext;
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQNotification"];
    NSString * predicateFormat = @"readed == NO AND ownerId = %@ AND notificable.notificableId == %@ AND notificable.type == %@";
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:predicateFormat, [IQSession defaultSession].userId,
                                notificableId,
                                notificableType]];
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
    
    NSError *saveError = nil;
    if(![notification.managedObjectContext saveToPersistentStore:&saveError] ) {
        NSLog(@"Save notification error: %@", saveError);
    }
}

- (void)updateModelSourceControllerWithCompletion:(void (^)(NSError * error))completion {
    NSInteger count = [self numberOfItemsInSection:0];
    NSInteger fetchLimit = _fetchController.fetchRequest.fetchLimit;
    
    //load next portiosion from fetchController
    NSError * fetchError = nil;
    [_fetchController.fetchRequest setFetchLimit:fetchLimit + _portionLenght];
    [_fetchController performFetch:&fetchError];
    if (!fetchError) {
        NSInteger itemsCount = [self numberOfItemsInSection:0];
        NSInteger difference = itemsCount - count;
        if(difference > 0) {
            [self modelWillChangeContent];
            NSInteger lastIndex = count - 1;
            for (NSInteger i = lastIndex; i < itemsCount - 1; i++) {
                [self modelDidChangeObject:nil
                               atIndexPath:nil
                             forChangeType:NSFetchedResultsChangeInsert
                              newIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            [self modelDidChangeContent];
        }
    }
    
    if (completion) {
        completion(fetchError);
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
    
    NSNumber * notificableId = self.group.lastNotification.notificable.notificableId;
    NSString * notificableType = self.group.lastNotification.notificable.type;
    NSString * predicateFormat = @"ownerId = %@ AND notificable.notificableId == %@ AND notificable.type == %@";
    NSPredicate * predicate = [NSPredicate predicateWithFormat:predicateFormat, [IQSession defaultSession].userId,
                                                                                notificableId,
                                                                                notificableType];
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
    NSExpression * maxSalaryExpression = [NSExpression expressionForFunction:(top) ? @"max:" : @"min:"
                                                                  arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"notificationId"];
    [expressionDescription setExpression:maxSalaryExpression];
    [expressionDescription setExpressionResultType:NSDecimalAttributeType];
  
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    [fetchRequest setResultType:NSDictionaryResultType];
    fetchRequest.fetchLimit = 1;
    
    NSNumber * notificableId = self.group.lastNotification.notificable.notificableId;
    NSString * notificableType = self.group.lastNotification.notificable.type;
    NSString * predicateFormat = @"ownerId = %@ AND notificable.notificableId == %@ AND notificable.type == %@";
    NSPredicate * predicate = [NSPredicate predicateWithFormat:predicateFormat, [IQSession defaultSession].userId,
                                                                                notificableId,
                                                                                notificableType];

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
    [[IQService sharedService] notificationsForGroupWithId:self.group.lastNotificationId
                                                  beforeId:_lastLoadedId
                                                   unread:(_loadUnreadOnly) ? @(YES) : nil
                                                     page:@(1)
                                                      per:@(_portionLenght)
                                                     sort:IQSortDirectionDescending
                                                  handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
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

- (void)accountDidChanged {
    _lastLoadedId = nil;

    if([IQSession defaultSession]) {
        [self resubscribeToIQNotifications];
        [self updateCounters];
    }
    else {
        [self unsubscribeFromIQNotifications];
        [self clearModelData];
        [self modelDidChanged];
    }
}

- (void)applicationWillEnterForeground {
    [self recursiveNotificationsLoadingFromId:_lastLoadedId];
    [self syncLocalNotificationsWithCompletion:nil];
}

- (void)recursiveNotificationsLoadingFromId:(NSNumber*)notificationId {
    [[IQService sharedService] notificationsForGroupWithId:self.group.lastNotificationId
                                                   afterId:notificationId
                                                    unread:(_loadUnreadOnly) ? @(YES) : nil
                                                      page:@(1)
                                                       per:@(_portionLenght)
                                                      sort:SORT_DIRECTION
                                                   handler:^(BOOL success, NSArray * notifications, NSData *responseData, NSError *error) {
                                                       if(success && [notifications count] > 0) {
                                                           _lastLoadedId = [notifications valueForKeyPath:@"@max.notificationId"];
                                                           [self recursiveNotificationsLoadingFromId:_lastLoadedId];
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
    [[IQNotificationCenter defaultCenter] removeObserver:_notfObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
