//
//  TasksFilterModel.m
//  IQ300
//
//  Created by Tayphoon on 26.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TasksFilterModel.h"
#import "TaskFilterCell.h"
#import "CTaskFilterCell.h"
#import "TaskFilterSection.h"
#import "TaskFilterSortItem.h"
#import "TaskFilterCounters.h"
#import "TaskStatusFilterItem.h"
#import "IQService+Tasks.h"

static NSString * CellReuseIdentifier = @"CellReuseIdentifier";
static NSString * CCellReuseIdentifier = @"CCellReuseIdentifier";

extern NSString * DescriptionForSortField(NSString * sortField) {
    static NSDictionary * _descriptions = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _descriptions = @{
                     @"updated_at" : @"According to the latest activity",
                     @"id"         : @"By number",
                     @"end_date"   : @"According to deadline"
                     };
    });
    
    if([_descriptions objectForKey:sortField]) {
        return [_descriptions objectForKey:sortField];
    }
    return nil;
}


@interface TasksFilterModel () {
    NSMutableArray * _sections;
    NSMutableArray * _selectedItems;
    NSArray * _statuses;
}

@end

@implementation TasksFilterModel

- (id)init {
    self = [super init];
    
    if (self) {
        _sections = [NSMutableArray array];
        _selectedItems = [NSMutableArray array];
        _statuses = @[@"new",
                      @"browsed",
                      @"in_work",
                      @"on_init",
                      @"refused",
                      @"completed",
                      @"accepted",
                      @"declined",
                      @"canceled"];
    }
    
    return self;
}

- (NSUInteger)numberOfSections {
    return [_sections count];
}

- (NSString*)titleForSection:(NSInteger)section {
    TaskFilterSection * filterSection = _sections[section];
    return filterSection.title;
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    TaskFilterSection * filterSection = _sections[section];
    return [filterSection.items count];
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    return (indexPath.section == COMMUNITY_SECTION) ? CCellReuseIdentifier : CellReuseIdentifier;
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    Class cellClass = (indexPath.section == COMMUNITY_SECTION) ? [CTaskFilterCell class] : [TaskFilterCell class];
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                            reuseIdentifier:[self reuseIdentifierForIndexPath:indexPath]];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    return 42;
}

- (id<TaskFilterItem>)itemAtIndexPath:(NSIndexPath*)indexPath {
    if(indexPath) {
        TaskFilterSection * filterSection = _sections[indexPath.section];
        return filterSection.items[indexPath.row];
    }
    return nil;
}

- (NSIndexPath *)indexPathOfObject:(id)object {
    return nil;
}

- (BOOL)canExpandSection:(NSInteger)section {
    TaskFilterSection * filterSection = _sections[section];
    return filterSection.isExpandable;
}

- (BOOL)isSortActionAvailableAtSection:(NSInteger)section {
    TaskFilterSection * filterSection = _sections[section];
    return filterSection.isSortAvailable;
}

- (void)setAscendingSortOrder:(BOOL)ascending forSection:(NSInteger)section {
    TaskFilterSection * filterSection = _sections[section];
    filterSection.ascending = ascending;
    //Temporary set model asceding because we have one section with sorting
    self.ascending = ascending;
}

- (BOOL)isSortOrderAscendingForSection:(NSInteger)section {
    TaskFilterSection * filterSection = _sections[section];
   return filterSection.ascending;
}

- (Class)controllerClassForItemAtIndexPath:(NSIndexPath*)indexPath {
    return nil;
}

- (BOOL)isItemSellectedAtIndexPath:(NSIndexPath *)indexPath {
    return [_selectedItems containsObject:indexPath];
}

- (void)makeItemAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected {
    if (selected && ![_selectedItems containsObject:indexPath]) {
        [_selectedItems addObject:indexPath];
        [self updatePropertiesBySelectedItems];
    }
    else if(!selected && [_selectedItems containsObject:indexPath]) {
        [_selectedItems removeObject:indexPath];
        [self updatePropertiesBySelectedItems];
    }
}

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion {
    [[IQService sharedService] filterCountersForFolder:self.folder
                                                status:self.statusFilter
                                           communityId:self.communityId
                                               handler:^(BOOL success, TaskFilterCounters * counters, NSData *responseData, NSError *error) {
                                                   if (success) {
                                                       [_sections removeAllObjects];
                                                       
                                                       TaskFilterSection * statusSection = [self makeStatusesSectionFromStatuses:counters.statuses];
                                                       [_sections addObject:statusSection];
                                                       
                                                       NSSortDescriptor * descriptor = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO];
                                                       TaskFilterSection * communitiesSection = [[TaskFilterSection alloc] init];
                                                       communitiesSection.title = NSLocalizedString(@"Communities", nil);
                                                       communitiesSection.expandable = YES;
                                                       communitiesSection.items = [counters.communities sortedArrayUsingDescriptors:@[descriptor]];
                                                       [_sections addObject:communitiesSection];
                                                       
                                                       TaskFilterSection * sortingSection = [self makeSortSection];
                                                       [_sections addObject:sortingSection];
                                                       
                                                       [self selectItemsByFields];
                                                       if(completion) {
                                                           completion(nil);
                                                       }
                                                   }
                                                   else if(completion) {
                                                       completion(error);
                                                   }
                                               }];
}

- (NSIndexPath*)selectedIndexPathForSection:(NSInteger)section {
    return [[_selectedItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"section == %d", section]] firstObject];
}

- (void)resetFilters {
    self.sortField = @"updated_at";
    self.ascending = NO;
    self.statusFilter = nil;
    self.communityId = nil;
    
    [_selectedItems removeAllObjects];
    [_selectedItems addObject:[NSIndexPath indexPathForRow:0 inSection:SORT_SECTION]];
}

- (void)clearModelData {
    [_sections removeAllObjects];
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

#pragma mark - Private methods

- (TaskFilterSection*)makeSortSection {
    TaskFilterSection * sortingSection = [[TaskFilterSection alloc] init];
    sortingSection.title = NSLocalizedString(@"Sorting", nil);
    sortingSection.expandable = YES;
    sortingSection.sortAvailable = YES;
    sortingSection.ascending = self.ascending;

    NSMutableArray * items = [NSMutableArray array];
    
    TaskFilterSortItem * lastActivity = [[TaskFilterSortItem alloc] init];
    lastActivity.sortField = @"updated_at";
    lastActivity.title = NSLocalizedString(DescriptionForSortField(lastActivity.sortField), nil);
    [items addObject:lastActivity];
    
    TaskFilterSortItem * number = [[TaskFilterSortItem alloc] init];
    number.sortField = @"id";
    number.title = NSLocalizedString(DescriptionForSortField(number.sortField), nil);
    [items addObject:number];

    TaskFilterSortItem * dueDate = [[TaskFilterSortItem alloc] init];
    dueDate.sortField = @"end_date";
    dueDate.title = NSLocalizedString(DescriptionForSortField(dueDate.sortField), nil);
    [items addObject:dueDate];
    
    sortingSection.items = items;

    return sortingSection;
}

- (TaskFilterSection*)makeStatusesSectionFromStatuses:(NSDictionary*)statuses {
    NSMutableArray * items = [NSMutableArray array];
    TaskFilterSection * statusSection = [[TaskFilterSection alloc] init];
    statusSection.title = NSLocalizedString(@"Statuses", nil);
    statusSection.expandable = YES;

    for (NSString * status in _statuses) {
        if ([statuses[status] integerValue] > 0) {
            TaskStatusFilterItem * item = [[TaskStatusFilterItem alloc] init];
            item.status = status;
            item.title = NSLocalizedStringFromTable(status, @"FiltersLocalization", nil);
            item.count = statuses[status];
            [items addObject:item];
        }
    }
    
    statusSection.items = items;
    return statusSection;
}

- (void)selectItemsByFields {
    TaskFilterSection * statusSection = _sections[STATUS_SECTION];
    if(self.statusFilter) {
        __weak typeof(self) weakSelf = self;
        NSInteger selectedIndex = [statusSection.items indexOfObjectPassingTest:^BOOL(TaskStatusFilterItem * obj, NSUInteger idx, BOOL *stop) {
            if([obj.status isEqualToString:weakSelf.statusFilter]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        
        if(selectedIndex != NSNotFound) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:selectedIndex
                                                         inSection:STATUS_SECTION];
            if(![_selectedItems containsObject:indexPath]) {
                [_selectedItems addObject:indexPath];
            }
        }
    }

    TaskFilterSection * communitySection = _sections[COMMUNITY_SECTION];
    if(self.communityId) {
        __weak typeof(self) weakSelf = self;
        NSInteger selectedIndex = [communitySection.items indexOfObjectPassingTest:^BOOL(CommunityFilter * obj, NSUInteger idx, BOOL *stop) {
            if([obj.communityId isEqualToNumber:weakSelf.communityId]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        
        if(selectedIndex != NSNotFound) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:selectedIndex
                                                         inSection:COMMUNITY_SECTION];
            if(![_selectedItems containsObject:indexPath]) {
                [_selectedItems addObject:indexPath];
            }
        }
    }

    TaskFilterSection * sortingSection = _sections[SORT_SECTION];
    __weak typeof(self) weakSelf = self;
    NSInteger sortSelectedIndex = [sortingSection.items indexOfObjectPassingTest:^BOOL(TaskFilterSortItem * obj, NSUInteger idx, BOOL *stop) {
        if([obj.sortField isEqualToString:weakSelf.sortField]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    if(sortSelectedIndex != NSNotFound) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:sortSelectedIndex
                                                     inSection:SORT_SECTION];
        if(![_selectedItems containsObject:indexPath]) {
            [_selectedItems addObject:indexPath];
        }
    }
}

- (void)updatePropertiesBySelectedItems {
    NSIndexPath * statusIndexPath = [self selectedIndexPathForSection:STATUS_SECTION];
    TaskStatusFilterItem * statusItem = (TaskStatusFilterItem*)[self itemAtIndexPath:statusIndexPath];
    self.statusFilter = statusItem.status;
    
    NSIndexPath * communityIndexPath = [self selectedIndexPathForSection:COMMUNITY_SECTION];
    CommunityFilter * communityItem = (CommunityFilter*)[self itemAtIndexPath:communityIndexPath];
    self.communityId = communityItem.communityId;
    _communityDescription = communityItem.title;

    NSIndexPath * sortIndexPath = [self selectedIndexPathForSection:SORT_SECTION];
    TaskFilterSortItem * sortItem = (TaskFilterSortItem*)[self itemAtIndexPath:sortIndexPath];
    self.sortField = sortItem.sortField;
    
    TaskFilterSection * sortingSection = _sections[SORT_SECTION];
    self.ascending = sortingSection.ascending;
}

@end
