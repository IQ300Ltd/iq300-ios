//
//  TodoListModel.m
//  IQ300
//
//  Created by Tayphoon on 19.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/CoreData/NSManagedObjectContext+RKAdditions.h>

#import "TodoListModel.h"
#import "TodoListItemCell.h"
#import "IQService+Tasks.h"
#import "IQTodoItem.h"

static NSString * TReuseIdentifier = @"TReuseIdentifier";

@interface TodoListModel() {
    NSArray * _sortDescriptors;
    NSMutableArray * _processableItems;
    NSMutableArray * _deletedItems;
    NSArray * _oldItems;
}

@end

@implementation TodoListModel

- (id)initWithManagedItems:(NSArray*)items {
    self = [super init];
    if (self) {
        _processableItems = [NSMutableArray array];
        _deletedItems = [NSMutableArray array];
        _sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
        
        if (items) {
            _oldItems = [[self todoItemsFromManagedObjects:items] sortedArrayUsingDescriptors:_sortDescriptors];
            _items = [[NSMutableArray alloc] initWithArray:_oldItems copyItems:YES];;
        }
    }
    return self;
}

- (BOOL)hasChanges {
    if ([_items count] != [_oldItems count]) {
        return YES;
    }
    
    for (int i = 0; i < [_items count]; i++) {
        IQTodoItem * oldItem = _oldItems[i];
        IQTodoItem * newItem = _items[i];
        if ([oldItem isEqualToItem:newItem] == NO) {
            return YES;
        }
    }
    
    return NO;
}

- (NSUInteger)numberOfSections {
    return 1;
}

- (NSString*)titleForSection:(NSInteger)section {
    return nil;
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    return (section == self.section) ? [_items count] : 0;
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    return TReuseIdentifier;
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    Class cellClass = [TodoListItemCell class];
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleSubtitle
                            reuseIdentifier:TReuseIdentifier];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    id<TodoItem> item = [self itemAtIndexPath:indexPath];
    return [TodoListItemCell heightForItem:item width:self.cellWidth];
}

- (id)itemAtIndexPath:(NSIndexPath*)indexPath {
    if(indexPath.section == self.section &&
       indexPath.row < _items.count) {
        return [_items objectAtIndex:indexPath.row];
    }
    return nil;
}

- (NSIndexPath *)indexPathOfObject:(id)object {
    NSInteger index = [_items indexOfObject:object];
    if (index != NSNotFound) {
        return [NSIndexPath indexPathForRow:index inSection:self.section];
    }
    return nil;
}

- (Class)controllerClassForItemAtIndexPath:(NSIndexPath*)indexPath {
    return nil;
}

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion {
    [[IQService sharedService] todoListByTaskId:self.taskId
                                        handler:^(BOOL success, NSArray * todoItems, NSData *responseData, NSError *error) {
                                            _items = todoItems;
                                            if (completion) {
                                                completion(error);
                                            }
                                        }];
}

- (BOOL)isItemCheckedAtIndexPath:(NSIndexPath*)indexPath {
    id<TodoItem> item = [self itemAtIndexPath:indexPath];
    return [item.completed boolValue];
}

- (BOOL)isItemSelectableAtIndexPath:(NSIndexPath *)indexPath {
    return ![_processableItems containsObject:indexPath];
}

- (void)makeItemAtIndexPath:(NSIndexPath *)indexPath checked:(BOOL)checked {
    id<TodoItem> item = [self itemAtIndexPath:indexPath];
    if (checked != [item.completed boolValue]) {
        item.completed = @(checked);
        
        [self modelWillChangeContent];
        [self modelDidChangeObject:[self itemAtIndexPath:indexPath]
                       atIndexPath:indexPath
                     forChangeType:NSFetchedResultsChangeUpdate
                      newIndexPath:nil];
        [self modelDidChangeContent];
    }
}

- (void)createItemWithCompletion:(void (^)(id<TodoItem> item, NSError *error))completion {
    NSInteger newRow = [_items count];
    NSIndexPath * newItemIndexPath = [NSIndexPath indexPathForRow:newRow inSection:self.section];
    IQTodoItem * item = [[IQTodoItem alloc] init];
    item.itemId = @(-1);
    item.position = @(newRow);
    
    _items = [_items arrayByAddingObject:item];
    
    [self modelWillChangeContent];

    [self modelDidChangeObject:item
                   atIndexPath:nil
                 forChangeType:NSFetchedResultsChangeInsert
                  newIndexPath:newItemIndexPath];
    [self modelDidChangeContent];
    
    if (completion) {
        completion(item, nil);
    }
}

- (void)deleteItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.section && indexPath.row >= 0 &&
        indexPath.row < [self.items count]) {
        
        id<TodoItem> item = [self itemAtIndexPath:indexPath];
        NSMutableArray * items = [self.items mutableCopy];
        [items removeObject:item];
        _items = [items copy];
        
        if (![item.itemId isEqualToNumber:@(-1)]) {
            item.destroy = @(YES);
            [_deletedItems addObject:item];
        }
        
        [self updateItemsPosition];
        
        [self modelWillChangeContent];
        [self modelDidChangeObject:[self itemAtIndexPath:indexPath]
                       atIndexPath:indexPath
                     forChangeType:NSFetchedResultsChangeDelete
                      newIndexPath:nil];
        [self modelDidChangeContent];
    }
}

- (void)saveChangesWithCompletion:(void (^)(NSError * error))completion {
    NSArray * items = ([_deletedItems count] > 0) ? [_items arrayByAddingObjectsFromArray:_deletedItems] : _items;
    [[IQService sharedService] saveTodoList:items
                                     taskId:self.taskId
                                    handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                                        if (completion) {
                                            completion(error);
                                        }
                                    }];
}

- (void)clearModelData {
    _items = nil;
}

#pragma mark - Private methods

- (void)updateItemsPosition {
    for (int position = 0; position < [_items count]; position++) {
        IQTodoItem * item = _items[position];
        item.position = @(position);
    }
}

- (NSArray*)todoItemsFromManagedObjects:(NSArray*)managedObjects {
    NSMutableArray * items = [NSMutableArray array];
    for (id<TodoItem> managedObject in managedObjects) {
        IQTodoItem * item = [IQTodoItem itemFromObject:managedObject];
        [items addObject:item];
    }
    return items;
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
