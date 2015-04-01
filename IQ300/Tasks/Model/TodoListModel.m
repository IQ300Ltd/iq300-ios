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
    NSMutableArray * _checkedItems;
    NSMutableArray * _processableItems;
}

@end

@implementation TodoListModel

+ (NSArray*)makeTodoItemsFromManagedObjects:(NSArray*)managedObjects {
    NSMutableArray * items = [NSMutableArray array];
    for (id<TodoItem> managedObject in managedObjects) {
        IQTodoItem * item = [IQTodoItem itemFromObject:managedObject];
        [items addObject:item];
    }
    return items;
}

- (id)init {
    self = [super init];
    if (self) {
        _checkedItems = [NSMutableArray array];
        _processableItems = [NSMutableArray array];
        _sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
    }
    return self;
}

- (void)setItems:(NSArray *)items {
    _items = [items sortedArrayUsingDescriptors:_sortDescriptors];
    [self updateCheckedProperties];
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
    if(completion) {
        completion(nil);
    }
}

- (BOOL)isItemCheckedAtIndexPath:(NSIndexPath*)indexPath {
    return [_checkedItems containsObject:indexPath];
}

- (BOOL)isItemSelectableAtIndexPath:(NSIndexPath *)indexPath {
    return ![_processableItems containsObject:indexPath];
}

- (void)makeItemAtIndexPath:(NSIndexPath *)indexPath checked:(BOOL)checked {
    if (checked && ![_checkedItems containsObject:indexPath]) {
        [_checkedItems addObject:indexPath];
        
        [self modelWillChangeContent];
        [self modelDidChangeObject:[self itemAtIndexPath:indexPath]
                       atIndexPath:indexPath
                     forChangeType:NSFetchedResultsChangeUpdate
                      newIndexPath:nil];
        [self modelDidChangeContent];
    }
    else if(!checked && [_checkedItems containsObject:indexPath]) {
        [_checkedItems removeObject:indexPath];
        
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
    item.position = @(newRow - 1);
    
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
        NSMutableArray * items = [self.items mutableCopy];
        [items removeObjectAtIndex:indexPath.row];
        self.items = [items copy];
        
        [self updateItemsPosition];
        
        [self modelWillChangeContent];
        [self modelDidChangeObject:[self itemAtIndexPath:indexPath]
                       atIndexPath:indexPath
                     forChangeType:NSFetchedResultsChangeDelete
                      newIndexPath:nil];
        [self modelDidChangeContent];
    }
}

- (void)completeTodoItemAtIndexPath:(NSIndexPath *)indexPath completion:(void (^)(NSError *))completion {
    [_processableItems addObject:indexPath];
    id<TodoItem> item = [self itemAtIndexPath:indexPath];
    
    [[IQService sharedService] completeTodoItemWithId:item.itemId
                                               taskId:self.taskId
                                              handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                                                  if (success) {
                                                      [self  makeItemAtIndexPath:indexPath checked:YES];
                                                  }
                                                  
                                                  [_processableItems removeObject:indexPath];
                                                  
                                                  if (completion) {
                                                      completion(error);
                                                  }
                                              }];

}

- (void)rollbackTodoItemWithId:(NSIndexPath *)indexPath completion:(void (^)(NSError *))completion {
    [_processableItems addObject:indexPath];
    id<TodoItem> item = [self itemAtIndexPath:indexPath];
    
    [[IQService sharedService] rollbackTodoItemWithId:item.itemId
                                               taskId:self.taskId
                                              handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                                                  if (success) {
                                                      [self  makeItemAtIndexPath:indexPath checked:NO];
                                                  }
                                                  
                                                  [_processableItems removeObject:indexPath];
                                                  
                                                  if (completion) {
                                                      completion(error);
                                                  }
                                              }];
}

- (void)clearModelData {
    _items = nil;
}

#pragma mark - Private methods

- (void)updateCheckedProperties {
    [_checkedItems removeAllObjects];
    
    for (NSInteger index = 0; index < [_items count]; index++) {
        id<TodoItem> item = _items[index];
        if ([item.completed boolValue]) {
            [_checkedItems addObject:[NSIndexPath indexPathForRow:index inSection:self.section]];
        }
    }
}

- (void)updateItemsPosition {
    for (int position = 0; position < [_items count]; position++) {
        IQTodoItem * item = _items[position];
        item.position = @(position);
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
