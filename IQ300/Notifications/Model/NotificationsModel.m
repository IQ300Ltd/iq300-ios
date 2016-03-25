//
//  NotificationsModel.m
//  IQ300
//
//  Created by Tayphoon on 20.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/CoreData/NSManagedObjectContext+RKAdditions.h>

#import "NotificationsModel.h"
#import "IQService+Notifications.h"
#import "NotificationCell.h"
#import "ActionNotificationCell.h"
#import "IQCounters.h"
#import "NSManagedObjectContext+AsyncFetch.h"
#import "IQNotificationCenter.h"
#import "IQNotificationsHolder.h"
#import "IQNotificationCounters.h"

#define CACHE_FILE_NAME @"NotificationsModelcache"
#define SORT_DIRECTION IQSortDirectionAscending

static NSString * NReuseIdentifier = @"NReuseIdentifier";
static NSString * NActionReuseIdentifier = @"NActionReuseIdentifier";

@interface NotificationsModel() <NSFetchedResultsControllerDelegate> {
    NSInteger _portionLenght;
    NSArray * _sortDescriptors;
    NSFetchedResultsController * _fetchController;
    NSInteger _unreadItemsCount;
    NSInteger _pinnedItemsCount;
    __weak id _notfObserver;
}

@end

@implementation NotificationsModel

+ (void)markNotificationsRelatedToComments:(NSArray*)comments {
    NSManagedObjectContext * context = [IQService sharedService].context;
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IQNotification"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"readed == NO AND commentId IN %@", [comments valueForKey:@"commentId"]]];
    
    [context executeFetchRequest:fetchRequest completion:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            [objects setValue:@(YES) forKey:@"readed"];
            
            NSError * saveError = nil;
            if(![context saveToPersistentStore:&saveError] ) {
                NSLog(@"Failed save after mark related notifications: %@", saveError);
            }
        }
    }];
}


- (id)init {
    self = [super init];
    if(self) {
        _portionLenght = 20;
        NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt"
                                                                    ascending:NO];
        _sortDescriptors = @[descriptor];
        _filterType = IQNotificationsFilterUnread;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(accountDidChanged)
                                                     name:AccountDidChangedNotification
                                                   object:nil];
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
        [[IQService sharedService] notificationsBeforeId:notificationId
                                                  unread:(_filterType == IQNotificationsFilterUnread) ? @(YES) : nil
                                                  pinned:(_filterType == IQNotificationsFilterPinned) ? @(YES) : nil
                                           withoutPinned:(_filterType != IQNotificationsFilterPinned) ? @(YES) : nil
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
    [self reloadModelSourceControllerWithCompletion:^(NSError *error) {
        if (!error) {
            [self modelDidChanged];
        }
    }];

    NSDate * lastUpdatedDate = [self getLastNotificationChangedDate];

    [self updateCounters];
    [[IQService sharedService] notificationsUpdatedAfter:lastUpdatedDate
                                                  unread:(_filterType == IQNotificationsFilterUnread) ? @(YES) : nil
                                                  pinned:(_filterType == IQNotificationsFilterPinned) ? @(YES) : nil
                                           withoutPinned:(_filterType != IQNotificationsFilterPinned) ? @(YES) : nil
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
                                                     
                                                     if(completion) {
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

- (NSInteger)unreadItemsCount {
    return _unreadItemsCount;
}

- (NSInteger)pinnedItemsCount {
    return _pinnedItemsCount;
}

- (void)markNotificationAsReadAtIndexPath:(NSIndexPath*)indexPath completion:(void (^)(NSError * error))completion {
    IQNotification * item = [self itemAtIndexPath:indexPath];
    
    if (![item.isPinned boolValue]) {
        [[IQService sharedService] markNotificationAsRead:item.notificationId
                                                  handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                      if(success) {
                                                          item.readed = @(YES);
                                                          
                                                          NSError *saveError = nil;
                                                          if(![item.managedObjectContext saveToPersistentStore:&saveError] ) {
                                                              NSLog(@"Save notification error: %@", saveError);
                                                          }
                                                          
                                                          [self updateCountersWithCompletion:^(IQNotificationCounters *counters, NSError *error) {
                                                              if(((_filterType == IQNotificationsFilterUnread && _unreadItemsCount > 0) ||
                                                                  (_filterType == IQNotificationsFilterPinned && _pinnedItemsCount > 0)) &&
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
}

- (void)markAllNotificationAsReadWithCompletion:(void (^)(NSError * error))completion {
    [[IQService sharedService] markAllNotificationsAsReadWithHandler:^(BOOL success, NSData *responseData, NSError *error) {
        if(success) {
            [self markAllLocalNotificationAsRead];
            [self updateCountersWithCompletion:^(IQNotificationCounters *counters, NSError *error) {
                if(((_filterType == IQNotificationsFilterUnread && _unreadItemsCount > 0) ||
                    (_filterType == IQNotificationsFilterPinned && _pinnedItemsCount > 0)) &&
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

- (void)updateCountersWithCompletion:(void (^)(IQNotificationCounters * counters, NSError * error))completion {
    [[IQService sharedService] notificationsCountWithHandler:^(BOOL success, IQNotificationCounters * counter, NSData *responseData, NSError *error) {
        if(success) {
            _unreadItemsCount = [counter.unreadCount integerValue];
            _pinnedItemsCount = [counter.pinnedCount integerValue];
            [self modelCountersDidChanged];
        }
        if(completion) {
            completion(counter, error);
        }
    }];
}

- (void)resubscribeToIQNotifications {
    [self unsubscribeFromIQNotifications];
    
    __weak typeof(self) weakSelf = self;
    void (^block)(IQCNotification * notf) = ^(IQCNotification * notf) {
        NSArray * changedIds = notf.userInfo[IQNotificationDataKey][@"object_ids"];
        if([changedIds respondsToSelector:@selector(count)] && [changedIds count] > 0) {
            [weakSelf updateModelWithCompletion:nil];
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

- (void)pinnedNotificationAtIndexPath:(NSIndexPath*)indexPath completion:(void (^)(NSError * error))completion {
    IQNotification * item = [self itemAtIndexPath:indexPath];
    [[IQService sharedService] pinnedNotificationWithId:item.notificationId
                                                handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                    if(success) {
                                                        item.isPinned = @(YES);
                                                        item.readed = @(NO);

                                                        NSError *saveError = nil;
                                                        if(![item.managedObjectContext saveToPersistentStore:&saveError] ) {
                                                            NSLog(@"Save notification error: %@", saveError);
                                                        }
                                                        
                                                        [self updateCounters];
                                                    }
                                                    if(completion) {
                                                        completion(error);
                                                    }
                                                }];
}

- (void)unpinnedNotificationAtIndexPath:(NSIndexPath*)indexPath completion:(void (^)(NSError * error))completion {
    IQNotification * item = [self itemAtIndexPath:indexPath];
    [[IQService sharedService] unpinnedNotificationWithId:item.notificationId
                                                  handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                      if(success) {
                                                          [self resetActionsForNotification:item];
                                                          
                                                          [self updateCounters];
                                                      }
                                                      if(completion) {
                                                          completion(error);
                                                      }
                                                  }];
}

#pragma mark - Private methods

- (void)notificationsUpdatesAfterDate:(NSDate*)lastUpdatedDate page:(NSNumber*)page completion:(void (^)(NSError * error))completion {
    [[IQService sharedService] notificationsUpdatedAfter:lastUpdatedDate
                                                  unread:nil
                                                  pinned:nil
                                           withoutPinned:nil
                                                    page:page
                                                     per:@(_portionLenght)
                                                    sort:IQSortDirectionAscending
                                                 handler:^(BOOL success, IQNotificationsHolder * holder, NSData *responseData, NSError *error) {
                                                     if(success && [holder.currentPage compare:holder.totalPages] == NSOrderedAscending) {
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
    NSString * predicateFormat = @"ownerId = %@";
    NSPredicate * predicate = [NSPredicate predicateWithFormat:predicateFormat, [IQSession defaultSession].userId];
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

- (void)markAllLocalNotificationAsRead {
    NSManagedObjectContext * context = _fetchController.managedObjectContext;
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQNotification"];
    NSString * predicateFormat = @"readed == NO AND isPinned == NO AND ownerId = %@";
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:predicateFormat, [IQSession defaultSession].userId]];
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
    notification.isPinned = @(NO);
    
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
    
    NSString * predicateFormat = @"ownerId = %@";
    NSPredicate * predicate = [NSPredicate predicateWithFormat:predicateFormat, [IQSession defaultSession].userId];

    if(_filterType == IQNotificationsFilterUnread) {
        NSPredicate * readCondition = [NSPredicate predicateWithFormat:@"(readed == NO || hasActions == YES)"];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[readCondition, predicate]];
    }

    if(_filterType == IQNotificationsFilterPinned) {
        NSPredicate * pinnedCondition = [NSPredicate predicateWithFormat:@"(isPinned == YES)"];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[pinnedCondition, predicate]];
    }
    else {
        NSPredicate * pinnedCondition = [NSPredicate predicateWithFormat:@"(isPinned == NO)"];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[pinnedCondition, predicate]];
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
    
    NSString * predicateFormat = @"ownerId = %@";
    NSPredicate * predicate = [NSPredicate predicateWithFormat:predicateFormat, [IQSession defaultSession].userId];

    if(_filterType == IQNotificationsFilterUnread) {
        NSPredicate * readCondition = [NSPredicate predicateWithFormat:@"(readed == NO || hasActions == YES)"];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[readCondition, predicate]];
    }
    
    if(_filterType == IQNotificationsFilterPinned) {
        NSPredicate * pinnedCondition = [NSPredicate predicateWithFormat:@"(isPinned == YES)"];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[pinnedCondition, predicate]];
    }
    else {
        NSPredicate * pinnedCondition = [NSPredicate predicateWithFormat:@"(isPinned == NO)"];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[pinnedCondition, predicate]];
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
    [[IQService sharedService] notificationsBeforeId:lastLoadedId
                                              unread:(_filterType == IQNotificationsFilterUnread) ? @(YES) : nil
                                              pinned:(_filterType == IQNotificationsFilterPinned) ? @(YES) : nil
                                       withoutPinned:(_filterType != IQNotificationsFilterPinned) ? @(YES) : nil
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
}

- (void)initGlobalCounterUpdate {
    NSDictionary * userInfo = @{ ChangedCounterNameUserInfoKey : @"notifications" };
    [[NSNotificationCenter defaultCenter] postNotificationName:CountersDidChangedNotification
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)accountDidChanged {
    if([IQSession defaultSession]) {
        [self resubscribeToIQNotifications];
        [self updateCountersWithCompletion:nil];
    }
    else {
        [self unsubscribeFromIQNotifications];
        [self clearModelData];
        [self modelDidChanged];
    }
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
