//
//  TaskExecutorsModel.m
//  IQ300
//
//  Created by Tayphoon on 20.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TaskExecutorsModel.h"
#import "IQSelectableTextCell.h"
#import "TaskExecutorsGroup.h"
#import "TaskExecutor.h"
#import "IQService+Tasks.h"
#import "TaskExecutorCell.h"
#import "IQChannel.h"
#import "IQNotificationCenter.h"

@interface TaskExecutorsModel() {
    NSArray * _itemsInternal;
    NSMutableIndexSet * _selectedSections;
    
    __weak id _userStatusChangedObserver;
    NSString *_currentUserStatusChangedChannelName;
}

@end

@implementation TaskExecutorsModel

- (id)init {
    self = [super init];
    if (self) {
        self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"executorName" ascending:YES]];
        
        _selectedSections = [[NSMutableIndexSet alloc] init];
    }
    
    return self;
}

- (Class)cellClassForIndexPath:(NSIndexPath *)indexPath {
    return [TaskExecutorCell class];
}

- (void)setSelectAll:(BOOL)selectAll {
    if (_selectAll != selectAll) {
        _selectAll = selectAll;
        
        if (_selectAll) {
            
            
            NSMutableArray * items = [NSMutableArray array];
            for (int i = 0; i < [_items count]; i++) {
                TaskExecutorsGroup * group = _items[i];
                [items addObjectsFromArray:group.executors];
                [_selectedSections addIndex:i];
            }
            _executors = [items copy];
        }
        else {
            [_selectedSections removeAllIndexes];
            _executors = nil;
        }
        
        [self modelDidChanged];
    }
}

- (void)setFilter:(NSString *)filter {
    if (![_filter isEqualToString:filter]) {
        _filter = filter;
        [self applyFilters];
        [self updateSelectedIndexs];
        [self modelDidChanged];
    }
}

- (void)setExecutors:(NSArray *)executors {
    _executors = executors;
    
    [self updateSelectedIndexs];
}

- (NSUInteger)numberOfSections {
    return [_items count];
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    if(section < [self numberOfSections]) {
        TaskExecutorsGroup * group = _items[section];
        return [group.executors count];
    }
    return 0;
}

- (NSString*)titleForSection:(NSInteger)section {
    if(section < [self numberOfSections]) {
        TaskExecutorsGroup * group = _items[section];
        return group.name;
    }
    return nil;
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    TaskExecutor * item = [self itemAtIndexPath:indexPath];
    return [TaskExecutorCell heightForItem:item.executorName
                               detailTitle:nil
                                     width:self.cellWidth];
}

- (id)itemAtIndexPath:(NSIndexPath*)indexPath {
    if(indexPath.section < [self numberOfSections] &&
       indexPath.row < [self numberOfItemsInSection:indexPath.section]) {
        TaskExecutorsGroup * group = _items[indexPath.section];
        return group.executors[indexPath.row];
    }
    return nil;
}

- (NSIndexPath*)indexPathOfObject:(id)object {
    for (NSInteger section = 0; section < [_items count]; section++) {
        TaskExecutorsGroup * grop = _items[section];
        NSInteger row = [grop.executors indexOfObject:object];
        if (row != NSNotFound) {
            return [NSIndexPath indexPathForRow:row inSection:section];
        }
    }
    
    return  nil;
}

- (void)updateModelWithCompletion:(void (^)(NSError *))completion {
    [[IQService sharedService] taskExecutorsForCommunityId:self.communityId
                                              handler:^(BOOL success, NSArray * executors, NSData *responseData, NSError *error) {
                                                  if (success) {
                                                      _itemsInternal = executors;
                                                      [self applyFilters];
                                                      [self updateSelectedIndexs];
                                                  }
                                                  if (completion) {
                                                      completion(error);
                                                  }
                                                  [self subscribeToUserNotifications];
                                              }];
}

- (BOOL)isSectionSelected:(NSInteger)section {
    return (!self.isEditingMode) ? [_selectedSections containsIndex:section] : NO;
}

- (void)makeSection:(NSInteger)section selected:(BOOL)selected {
    if (self.isEditingMode) {
        return;
    }
    
    if (selected && ![_selectedSections containsIndex:section]) {
        [_selectedSections addIndex:section];
        
        TaskExecutorsGroup * group = _items[section];
        if (!_executors) {
            _executors = [NSArray array];
        }
        
        NSSet * executors = [NSSet setWithArray:[_executors arrayByAddingObjectsFromArray:group.executors]];
        _executors = [executors allObjects];
        _selectAll = [_selectedSections count] == [_items count];
        
        [self modelDidChanged];
    }
    else if(!selected && [_selectedSections containsIndex:section]) {
        [_selectedSections removeIndex:section];
        
        TaskExecutorsGroup * group = _items[section];
        NSMutableArray * items = [_executors mutableCopy];
        [items removeObjectsInArray:group.executors];
        _executors = [items copy];
        _selectAll = [_selectedSections count] == [_items count];

        [self modelDidChanged];
    }
}

- (BOOL)isItemSelectedAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self itemAtIndexPath:indexPath];
    return [_executors containsObject:item];
}

- (void)makeItemAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected {
    TaskExecutor * executor = [self itemAtIndexPath:indexPath];

    if (!self.isEditingMode) {
        _selectAll = NO;
        
        if (selected && ![_executors containsObject:executor]) {
            
            if (!_executors) {
                _executors = [NSArray array];
            }
            
            _executors = [_executors arrayByAddingObject:executor];
            [self updateSelectedIndexs];
            
            [self modelDidChanged];
        }
        else if(!selected && [_executors containsObject:executor]) {
            
            NSMutableArray * items = [_executors mutableCopy];
            [items removeObject:executor];
            _executors = [items copy];
            [self updateSelectedIndexs];
            
            [self modelDidChanged];
        }
    }
    else {
        NSIndexPath * selectedIndexPath = [self indexPathOfObject:[_executors firstObject]];
        if (selected && ![selectedIndexPath isEqual:indexPath]) {
            _executors = @[executor];
            [self modelDidChanged];
        }
    }
}

#pragma mark - Private methods

- (void)updateSelectedIndexs {
    [_selectedSections removeAllIndexes];
    
    if ([_items count] > 0 && [_executors count] > 0) {
        NSUInteger totalCount = 0;
        NSSet * executors = [NSSet setWithArray:_executors];
        for (NSInteger section = 0; section < [_items count]; section++) {
            TaskExecutorsGroup * grop = _items[section];
            if ([grop.executors count] > 0) {
                totalCount += [grop.executors count];
                NSSet * items = [NSSet setWithArray:grop.executors];
                if ([items isSubsetOfSet:executors]) {
                    [_selectedSections addIndex:section];
                }
            }
        }
        
        _selectAll = [_selectedSections count] == [_items count];
    }
}

- (void)applyFilters {
    if ([_filter length] > 0) {
        NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"(executorName CONTAINS[cd] %@)", _filter];
        NSMutableArray * groups = [NSMutableArray array];
        for (int i = 0; i < [_itemsInternal count]; i++) {
            TaskExecutorsGroup * group = _itemsInternal[i];
            NSArray * executors = [group.executors filteredArrayUsingPredicate:filterPredicate];
            if ([executors count] > 0) {
                TaskExecutorsGroup * filteredGroup = [[TaskExecutorsGroup alloc] init];
                filteredGroup.name = group.name;
                filteredGroup.executors = [executors sortedArrayUsingDescriptors:self.sortDescriptors];
                [groups addObject:filteredGroup];
            }
        }
        _items = [groups copy];
    }
    else {
        _items = _itemsInternal;
    }
}

#pragma mark - User subscrtiptions

- (void)subscribeToUserNotifications {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *executors = [[NSMutableArray alloc] init];
        
        NSArray *executorArrays = [_itemsInternal valueForKey:@"executors"];
        for (NSArray *nestedExecutors in executorArrays) {
            if (nestedExecutors.count > 0) {
                [executors addObjectsFromArray:nestedExecutors];
            }
        }
        
        if (executors.count > 0) {
            [[IQService sharedService] subscribeToUserStatusChangedNotification:[[executors filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"executorId != %@", [IQSession defaultSession].userId]] valueForKey:@"executorId"]
                                                                        handler:^(BOOL success,  IQChannel *channel, NSData *responseData, NSError *error) {
                                                                            [self resubscribeToUserStatusChangedNotificationWithChannel:channel.name];
                                                                        }];
        }
    });
}

- (void)resubscribeToUserStatusChangedNotificationWithChannel:(NSString *)channel {
    [self unsubscribeToUserStatusChangedNotification];
    
    if (channel) {
        __weak typeof(self) weakSelf = self;
        void (^block)(IQCNotification * notf) = ^(IQCNotification * notf) {
            [weakSelf modelWillChangeContent];
            
            NSMutableArray *executors = [[NSMutableArray alloc] init];
            
            NSArray *executorArrays = [_itemsInternal valueForKey:@"executors"];
            for (NSArray *nestedExecutors in executorArrays) {
                if (nestedExecutors.count > 0) {
                    [executors addObjectsFromArray:nestedExecutors];
                }
            }
            
            NSArray *onlineUserIndexes = [notf.userInfo[IQNotificationDataKey] objectForKey:@"online_ids"];
            NSArray *offlineUserIndexes = [notf.userInfo[IQNotificationDataKey] objectForKey:@"offline_ids"];
            
            NSArray *onlineExecutors = [executors filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"executorId IN %@", onlineUserIndexes]];
            
            for (TaskExecutor *executor in  onlineExecutors) {
                executor.online = @(YES);
                NSIndexPath *indexPath = [self indexPathOfObject:executor];
                [self modelDidChangeObject:executor atIndexPath:indexPath forChangeType:NSFetchedResultsChangeUpdate newIndexPath:nil];
            }
            
            NSArray *offlineExecutors = [executors filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"executorId IN %@", offlineUserIndexes]];
            
            for (TaskExecutor *executor in  offlineExecutors) {
                executor.online = @(NO);
                NSIndexPath *indexPath = [self indexPathOfObject:executor];
                [self modelDidChangeObject:executor atIndexPath:indexPath forChangeType:NSFetchedResultsChangeUpdate newIndexPath:nil];
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
- (void)dealloc {
    [self unsubscribeToUserStatusChangedNotification];
}


@end
