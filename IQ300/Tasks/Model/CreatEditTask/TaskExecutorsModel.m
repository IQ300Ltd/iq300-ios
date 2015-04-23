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

@interface TaskExecutorsModel() {
    NSArray * _itemsInternal;
    NSMutableIndexSet * _selectedSections;
}

@end

@implementation TaskExecutorsModel

- (id)init {
    self = [super init];
    if (self) {
        self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],
                                 [NSSortDescriptor sortDescriptorWithKey:@"executors.name" ascending:YES]];
        
        _selectedSections = [[NSMutableIndexSet alloc] init];
    }
    
    return self;
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

- (Class)cellClass {
    return [IQSelectableTextCell class];
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
    return [IQSelectableTextCell heightForItem:item.executorName
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
                                                      _itemsInternal = [executors sortedArrayUsingDescriptors:self.sortDescriptors];
                                                      
                                                      [self applyFilters];
                                                      [self updateSelectedIndexs];
                                                  }
                                                  if (completion) {
                                                      completion(error);
                                                  }
                                              }];
}

- (BOOL)isSectionSelected:(NSInteger)section {
    return [_selectedSections containsIndex:section];
}

- (void)makeSection:(NSInteger)section selected:(BOOL)selected {
    if (selected && ![_selectedSections containsIndex:section]) {
        [_selectedSections addIndex:section];
        
        TaskExecutorsGroup * group = _items[section];
        if (!_executors) {
            _executors = [NSArray array];
        }
        
        _executors = [_executors arrayByAddingObjectsFromArray:group.executors];
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
    _selectAll = NO;
    
    id item = [self itemAtIndexPath:indexPath];

    if (selected && ![_executors containsObject:item]) {
        
        if (!_executors) {
            _executors = [NSArray array];
        }

        _executors = [_executors arrayByAddingObject:item];
        [self updateSelectedIndexs];
        
        [self modelDidChanged];
    }
    else if(!selected && [_executors containsObject:item]) {
        
        NSMutableArray * items = [_executors mutableCopy];
        [items removeObject:item];
        _executors = [items copy];
        [self updateSelectedIndexs];
       
        [self modelDidChanged];
    }
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

#pragma mark - Private methods

- (void)applicationWillEnterForeground {
    [self updateModelWithCompletion:nil];
}

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
                filteredGroup.executors = executors;
                [groups addObject:filteredGroup];
            }
        }
        [groups sortUsingDescriptors:self.sortDescriptors];
        _items = [groups copy];
    }
    else {
        _items = _itemsInternal;
    }
}

@end
