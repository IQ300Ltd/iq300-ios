//
//  TasksFilterModel.m
//  IQ300
//
//  Created by Tayphoon on 26.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TasksFilterModel.h"
#import "TaskFilterCell.h"
#import "TaskFilterSection.h"
#import "TaskFilterSortItem.h"

static NSString * CellReuseIdentifier = @"CellReuseIdentifier";

@interface TasksFilterModel () {
    NSMutableDictionary * _sortingOrders;
    NSMutableArray * _sections;
    NSMutableArray * _selectedItems;
}

@end

@implementation TasksFilterModel

- (id)init {
    self = [super init];
    
    if (self) {
        _sortingOrders = [NSMutableDictionary dictionary];
        _sections = [NSMutableArray array];
        _selectedItems = [NSMutableArray array];
        
        TaskFilterSection * statusSection = [[TaskFilterSection alloc] init];
        statusSection.title = NSLocalizedString(@"Statuses", nil);
        statusSection.expandable = YES;
        [_sections addObject:statusSection];
        
        TaskFilterSection * communitiesSection = [[TaskFilterSection alloc] init];
        communitiesSection.title = NSLocalizedString(@"Communities", nil);
        communitiesSection.expandable = YES;
        [_sections addObject:communitiesSection];
        
        TaskFilterSection * sortingSection = [self makeSortSection];
        [_sections addObject:sortingSection];
        
        [self makeItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[_sections indexOfObject:sortingSection]]
                         selected:YES];
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
    return CellReuseIdentifier;
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    Class cellClass = [TaskFilterCell class];
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                            reuseIdentifier:CellReuseIdentifier];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    return 42;
}

- (id<TaskFilterItem>)itemAtIndexPath:(NSIndexPath*)indexPath {
    TaskFilterSection * filterSection = _sections[indexPath.section];
    return filterSection.items[indexPath.row];
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
    _sortingOrders[@(section)] = @(ascending);
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
    }
    else if(!selected && [_selectedItems containsObject:indexPath]) {
        [_selectedItems removeObject:indexPath];
    }
}

- (NSArray*)selectedIndexPathsForSection:(NSInteger)section {
    return [_selectedItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"section == %d", section]];
}

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion {
    if(completion) {
        completion(nil);
    }
}

- (void)clearModelData {
}

- (void)reloadItemAtIndexPath:(NSIndexPath*)indexPath {
    [self modelWillChangeContent];
    [self modelDidChangeObject:[self itemAtIndexPath:indexPath]
                   atIndexPath:indexPath
                 forChangeType:NSFetchedResultsChangeUpdate
                  newIndexPath:nil];
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

#pragma mark - Private methods

- (TaskFilterSection*)makeSortSection {
    TaskFilterSection * sortingSection = [[TaskFilterSection alloc] init];
    sortingSection.title = NSLocalizedString(@"Sorting", nil);
    sortingSection.expandable = YES;
    sortingSection.sortAvailable = YES;

    NSMutableArray * items = [NSMutableArray array];
    
    TaskFilterSortItem * lastActivity = [[TaskFilterSortItem alloc] init];
    lastActivity.title = NSLocalizedString(@"According to the latest activity", nil);
    [items addObject:lastActivity];
    
    TaskFilterSortItem * number = [[TaskFilterSortItem alloc] init];
    number.title = NSLocalizedString(@"By number", nil);
    [items addObject:number];

    TaskFilterSortItem * dueDate = [[TaskFilterSortItem alloc] init];
    dueDate.title = NSLocalizedString(@"According to deadline", nil);
    [items addObject:dueDate];
    
    sortingSection.items = items;

    return sortingSection;
}

@end
