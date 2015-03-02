//
//  NGroupModel.m
//  IQ300
//
//  Created by Tayphoon on 29.01.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/CoreData/NSManagedObjectContext+RKAdditions.h>

#import "NGroupModel.h"
#import "IQService.h"
#import "IQNotificationGroupsHolder.h"
#import "IQCounters.h"
#import "NSManagedObjectContext+AsyncFetch.h"
#import "IQNotificationCenter.h"
#import "NGroupCell.h"
#import "IQNotification.h"
#import "IQGroupCounter.h"
#import "NActionGropCell.h"

#define CACHE_FILE_NAME @"NotificationsModelcache"
#define SORT_DIRECTION IQSortDirectionAscending

static NSString * NReuseIdentifier = @"NReuseIdentifier";

@interface NGroupModel() <NSFetchedResultsControllerDelegate> {
    NSInteger _portionLenght;
    NSArray * _sortDescriptors;
    NSFetchedResultsController * _fetchController;
    NSInteger _totalItemsCount;
    NSInteger _unreadItemsCount;
    __weak id _notfObserver;
}

@end

@implementation NGroupModel

- (id)init {
    self = [super init];
    if(self) {
        _portionLenght = 20;
        NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"lastNotification.createdAt"
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
    return NReuseIdentifier;
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    IQNotificationsGroup * item = [self itemAtIndexPath:indexPath];
    Class cellClass = ([item.unreadCount integerValue] == 1 && [item.lastNotification.hasActions boolValue]) ? [NActionGropCell class] : [NGroupCell class];
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                            reuseIdentifier:[self reuseIdentifierForIndexPath:indexPath]];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    IQNotificationsGroup * item = [self itemAtIndexPath:indexPath];
    return [NGroupCell heightForItem:item andCellWidth:self.cellWidth];
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
        [self groupUpdatesWithCompletion:completion];
    }
}

- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelWithCompletion:completion];
    }
    else {
        NSNumber * notificationId = [self getLastIdFromTop:NO];
        [[IQService sharedService] notificationsGroupBeforeId:notificationId
                                                       unread:(_loadUnreadOnly) ? @(YES) : nil
                                                         page:@(1)
                                                          per:@(_portionLenght)
                                                         sort:IQSortDirectionDescending
                                                      handler:^(BOOL success, IQNotificationGroupsHolder * holder, NSData *responseData, NSError *error) {
                                                          if(completion) {
                                                              completion(error);
                                                          }
                                                      }];
    }
}

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion {
    [self reloadModelSourceControllerWithCompletion:completion];
    
    NSDate * lastUpdatedDate = [self getLastNotificationChangedDate];
    
    [[IQService sharedService] notificationsGroupUpdatedAfter:lastUpdatedDate
                                                       unread:(_loadUnreadOnly) ? @(YES) : nil
                                                         page:@(1)
                                                          per:@(_portionLenght)
                                                         sort:(lastUpdatedDate) ? IQSortDirectionAscending : IQSortDirectionDescending
                                                      handler:^(BOOL success, IQNotificationGroupsHolder * holder, NSData *responseData, NSError *error) {
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
                                                          
                                                          if (success) {
                                                              [self syncNotificationsForReadedGroups];
                                                          }
                                                      }];
}

- (void)reloadFirstPartWithCompletion:(void (^)(NSError * error))completion {
    BOOL hasObjects = ([_fetchController.fetchedObjects count] > 0);
    if(!hasObjects) {
        [self reloadModelSourceControllerWithCompletion:nil];
    }
    
    [self updateCountersWithCompletion:nil];
    
    NSDate * lastUpdatedDate = [self getLastNotificationChangedDate];
    if(!lastUpdatedDate) {
    [[IQService sharedService] notificationsGroupUpdatedAfter:nil
                                                       unread:(_loadUnreadOnly) ? @(YES) : nil
                                                         page:@(1)
                                                          per:@(_portionLenght)
                                                         sort:(lastUpdatedDate) ? IQSortDirectionAscending : IQSortDirectionDescending
                                                      handler:^(BOOL success, IQNotificationGroupsHolder * holder, NSData *responseData, NSError *error) {
                                                          if(completion) {
                                                              completion(error);
                                                          }
                                                          if (success) {
                                                              [self syncNotificationsForReadedGroups];
                                                          }
                                                      }];
    }
    else {
        [self groupUpdatesWithCompletion:^(NSError *error) {
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

- (void)markNotificationsAsReadAtIndexPath:(NSIndexPath*)indexPath completion:(void (^)(NSError * error))completion {
    IQNotificationsGroup * item = [self itemAtIndexPath:indexPath];
    
    [[IQService sharedService] markNotificationsGroupAsReadWithId:item.lastNotificationId
                                                          handler:^(BOOL success, IQNotificationsGroup * group, NSData *responseData, NSError *error) {
                                                              if(success) {
                                                                  [self markAllNotificationsAsReadInGroup:item];
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
    [[IQService sharedService] markAllNotificationGroupsAsReadWithHandler:^(BOOL success, NSArray * groups, NSData *responseData, NSError *error) {
        if(success) {
            [self markAllLocalNotificationsAsReadExceptGroups:groups];
            [self updateCounters];
        }
        if(completion) {
            completion(error);
        }
    }];
}

- (void)updateCountersWithCompletion:(void (^)(IQCounters * counters, NSError * error))completion {
    [[IQService sharedService] notificationsGroupCountWithHandler:^(BOOL success, IQCounters * counter, NSData *responseData, NSError *error) {
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


- (void)acceptNotificationsGroupAtIndexPath:(NSIndexPath*)indexPath completion:(void (^)(NSError * error))completion {
    IQNotificationsGroup * item = [self itemAtIndexPath:indexPath];
    [[IQService sharedService] acceptNotificationWithId:item.lastNotification.notificationId
                                                handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                    if(success) {
                                                        [self resetActionsForGroupNotification:item];
                                                        [self updateCounters];
                                                    }
                                                    if(completion) {
                                                        completion(error);
                                                    }
                                                }];
}

- (void)declineNotificationsGroupAtIndexPath:(NSIndexPath*)indexPath completion:(void (^)(NSError * error))completion {
    IQNotificationsGroup * item = [self itemAtIndexPath:indexPath];
   [[IQService sharedService] declineNotificationWithId:item.lastNotification.notificationId
                                                 handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                     if(success) {
                                                         [self resetActionsForGroupNotification:item];
                                                         [self updateCounters];
                                                     }
                                                     if(completion) {
                                                         completion(error);
                                                     }
                                                 }];
}

#pragma mark - Private methods

- (void)resetActionsForGroupNotification:(IQNotificationsGroup*)group {
    group.lastNotification.hasActions = @(NO);
    group.lastNotification.availableActions = nil;
    group.lastNotification.readed = @(YES);
    
    group.unreadCount = @(0);
    
    NSError *saveError = nil;
    if(![group.managedObjectContext saveToPersistentStore:&saveError] ) {
        NSLog(@"Save notification error: %@", saveError);
    }
}

- (void)groupUpdatesAfterDate:(NSDate*)lastUpdatedDate page:(NSNumber*)page completion:(void (^)(NSError * error))completion {
    [[IQService sharedService] notificationsGroupUpdatedAfter:lastUpdatedDate
                                                       unread:@(NO)
                                                         page:page
                                                          per:@(_portionLenght)
                                                         sort:IQSortDirectionAscending
                                                      handler:^(BOOL success, IQNotificationGroupsHolder * holder, NSData *responseData, NSError *error) {
                                                          if(success && holder.currentPage < holder.totalPages) {
                                                              [self groupUpdatesAfterDate:lastUpdatedDate
                                                                                     page:@([page integerValue] + 1)
                                                                               completion:completion];
                                                          }
                                                          else if(completion) {
                                                              completion(error);
                                                          }
                                                          
                                                          if (holder.currentPage >= holder.totalPages) {
                                                              [self syncNotificationsForReadedGroups];
                                                          }
                                                      }];
}

- (void)groupUpdatesWithCompletion:(void (^)(NSError * error))completion {
    NSDate * lastUpdatedDate = [self getLastNotificationChangedDate];
    [self groupUpdatesAfterDate:lastUpdatedDate
                           page:@(1)
                     completion:completion];
}

- (void)markAllLocalNotificationsAsReadExceptGroups:(NSArray*)unreadGroups {
    NSManagedObjectContext * context = _fetchController.managedObjectContext;
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQNotification"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(readed == NO AND hasActions == NO) AND ownerId = %@", [IQSession defaultSession].userId]];
    [context executeFetchRequest:fetchRequest completion:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            [objects makeObjectsPerformSelector:@selector(setReaded:) withObject:@(YES)];
            NSError *saveError = nil;
            
            if(![context saveToPersistentStore:&saveError]) {
                NSLog(@"Save notifications error: %@", saveError);
            }
        }
    }];
    
    NSArray * unreadIds = [unreadGroups valueForKey:@"sID"];
    NSArray * groups = [_fetchController fetchedObjects];
    NSArray * readedGroups = [groups filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"unreadCount > 0 AND NOT(sID IN %@)", unreadIds]];
    if([readedGroups count] > 0) {
        [readedGroups makeObjectsPerformSelector:@selector(setUnreadCount:) withObject:@(0)];
    }
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjects:unreadGroups forKeys:[unreadGroups valueForKey:@"sID"]];
    NSArray * filteredGroups = [groups filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"sID IN %@", unreadIds]];
    if([filteredGroups count] > 0) {
        for (IQNotificationsGroup * group in filteredGroups) {
            IQGroupCounter * counter = dict[group.sID];
            if(![group.unreadCount isEqualToNumber:counter.unreadCount]) {
                group.unreadCount = counter.unreadCount;
            }
        }
    }

    NSError * saveError = nil;
    if([context hasChanges] && ![context saveToPersistentStore:&saveError]) {
        NSLog(@"Save notifications error: %@", saveError);
    }
}

- (void)markAllNotificationsAsReadInGroup:(IQNotificationsGroup*)group {
    NSManagedObjectContext * context = _fetchController.managedObjectContext;
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQNotification"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"readed == NO AND ownerId = %@ AND groupSid == %@",
                                                                [IQSession defaultSession].userId,
                                                                group.sID]];
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


/**
 *  Mark unread notifications for readed groups
 */

- (void)syncNotificationsForReadedGroups {
    NSManagedObjectContext * context = _fetchController.managedObjectContext;
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQNotificationsGroup"];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:@[@"sID"]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"unreadCount == 0 AND ownerId = %@", [IQSession defaultSession].userId]];
    
    NSError * error = nil;
    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSArray * sids = [fetchedObjects valueForKey:@"sID"];
    if([sids count] > 0) {
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"IQNotification"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(readed == NO OR hasActions == YES) AND ownerId = %@ AND groupSid IN %@",
                               [IQSession defaultSession].userId, sids]];
        
        [context executeFetchRequest:request completion:^(NSArray *objects, NSError *error) {
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
}

- (void)reloadModelSourceControllerWithCompletion:(void (^)(NSError * error))completion {
    _fetchController.delegate = nil;
    
    [NSFetchedResultsController deleteCacheWithName:CACHE_FILE_NAME];
    
    if(!_fetchController && [IQService sharedService].context) {
        NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQNotificationsGroup"];
        [fetchRequest setSortDescriptors:_sortDescriptors];
        
        _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                               managedObjectContext:[IQService sharedService].context
                                                                 sectionNameKeyPath:nil
                                                                          cacheName:nil];
    }
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"ownerId = %@", [IQSession defaultSession].userId];
    if(_loadUnreadOnly) {
        NSPredicate * readCondition = [NSPredicate predicateWithFormat:@"unreadCount > 0"];
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
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IQNotificationsGroup"];
    NSExpression * keyPathExpression = [NSExpression expressionForKeyPath:@"lastNotificationId"];
    NSExpression * maxIdExpression = [NSExpression expressionForFunction:(top) ? @"max:" : @"min:"
                                                                   arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"notificationId"];
    [expressionDescription setExpression:maxIdExpression];
    [expressionDescription setExpressionResultType:NSDecimalAttributeType];
    
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    [fetchRequest setResultType:NSDictionaryResultType];
    fetchRequest.fetchLimit = 1;
    
    if(_loadUnreadOnly) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"unreadCount > 0 AND ownerId = %@", [IQSession defaultSession].userId]];
    }
    else {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ownerId = %@", [IQSession defaultSession].userId]];
    }
    
    NSError *error = nil;
    
    NSArray *objects = [[IQService sharedService].context executeFetchRequest:fetchRequest error:&error];
    if ([objects count] > 0) {
        return [[objects objectAtIndex:0] valueForKey:@"notificationId"];
    }
    return nil;
}

- (NSDate*)getLastNotificationChangedDate {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IQNotificationsGroup"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastNotification.updatedAt" ascending:NO]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ownerId = %@", [IQSession defaultSession].userId]];
    fetchRequest.fetchLimit = 1;
    
    NSError *error = nil;
    
    NSArray *objects = [[IQService sharedService].context executeFetchRequest:fetchRequest error:&error];
    if ([objects count] > 0) {
        IQNotification * lastNotification = ((IQNotificationsGroup*)[objects objectAtIndex:0]).lastNotification;
        return lastNotification.updatedAt;
    }
    return nil;
}

- (void)tryLoadFullPartitionWithCompletion:(void (^)(NSError * error))completion {
    NSNumber * lastLoadedId = [self getLastIdFromTop:YES];

    [[IQService sharedService] notificationsGroupBeforeId:lastLoadedId
                                                   unread:(_loadUnreadOnly) ? @(YES) : nil
                                                     page:@(1)
                                                      per:@(_portionLenght)
                                                     sort:IQSortDirectionDescending
                                                  handler:^(BOOL success, IQNotificationGroupsHolder * holder, NSData *responseData, NSError *error) {
                                                      if(completion) {
                                                          completion(error);
                                                      }
                                                  }];
}

- (void)updateCounters {
    [self updateCountersWithCompletion:nil];
}

- (void)resubscribeToIQNotifications {
    [self unsubscribeFromIQNotifications];
    
    __weak typeof(self) weakSelf = self;
    void (^block)(IQCNotification * notf) = ^(IQCNotification * notf) {
        NSArray * changedIds = notf.userInfo[IQNotificationDataKey][@"object_ids"];
        if([changedIds respondsToSelector:@selector(count)] && [changedIds count] > 0) {
            [weakSelf groupUpdatesWithCompletion:nil];
            [weakSelf updateCounters];
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
    if([IQSession defaultSession]) {
        [self resubscribeToIQNotifications];
        [self updateCounters];
    }
    else {
        _loadUnreadOnly = YES;
        [self unsubscribeFromIQNotifications];
        [self clearModelData];
        [self modelDidChanged];
    }
}

- (void)applicationWillEnterForeground {
    [self updateCounters];
    [self groupUpdatesWithCompletion:nil];
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
