//
//  ManagedTodoListModel.m
//  IQ300
//
//  Created by Tayphoon on 07.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "ManagedTodoListModel.h"
#import "TodoListItemCell.h"
#import "IQService+Tasks.h"
#import "TodoItem.h"

#define CACHE_FILE_NAME @"ManagedTodoListModelCache"

static NSString * TReuseIdentifier = @"TReuseIdentifier";

@interface ManagedTodoListModel() <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController * _fetchController;
    NSArray * _sortDescriptors;
    NSInteger _portionSize;
    NSMutableArray * _processableItems;
}

@end

@implementation ManagedTodoListModel

- (id)init {
    self = [super init];
    if(self) {
        _portionSize = 20;
        _processableItems = [NSMutableArray array];
        _sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
    }
    return self;
}

- (NSArray*)items {
    return [_fetchController fetchedObjects];
}

- (NSUInteger)numberOfSections {
    return [_fetchController.sections count];
}

- (NSString*)titleForSection:(NSInteger)section {
    return nil;
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [_fetchController.sections objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    return TReuseIdentifier;
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    Class cellClass = [TodoListItemCell class];
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleSubtitle
                            reuseIdentifier:[self reuseIdentifierForIndexPath:indexPath]];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    id<TodoItem> item = [self itemAtIndexPath:indexPath];
    return [TodoListItemCell heightForItem:item width:self.cellWidth];
}

- (id)itemAtIndexPath:(NSIndexPath*)indexPath {
    NSIndexPath * itemIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    if(itemIndexPath.section < [self numberOfSections] &&
       itemIndexPath.row < [self numberOfItemsInSection:itemIndexPath.section]) {
        return [_fetchController objectAtIndexPath:itemIndexPath];
    }
    return nil;
}

- (NSIndexPath *)indexPathOfObject:(id)object {
    NSIndexPath * indexPath = [_fetchController indexPathForObject:object];
    return [NSIndexPath indexPathForRow:indexPath.row inSection:self.section];
}

- (Class)controllerClassForItemAtIndexPath:(NSIndexPath*)indexPath {
    return nil;
}

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelWithCompletion:completion];
    }
    else {
        [[IQService sharedService] todoListByTaskId:self.taskId
                                            handler:^(BOOL success, NSArray * todoItems, NSData *responseData, NSError *error) {
                                                if (completion) {
                                                    completion(error);
                                                }
                                            }];
    }
}

- (BOOL)isItemCheckedAtIndexPath:(NSIndexPath*)indexPath {
    id<TodoItem> item = [self itemAtIndexPath:indexPath];
    return [item.completed boolValue];
}

- (BOOL)isItemSelectableAtIndexPath:(NSIndexPath *)indexPath {
    return ![_processableItems containsObject:indexPath];
}

- (void)completeTodoItemAtIndexPath:(NSIndexPath *)indexPath completion:(void (^)(NSError *))completion {
    [_processableItems addObject:indexPath];
    id<TodoItem> item = [self itemAtIndexPath:indexPath];
    
    [[IQService sharedService] completeTodoItemWithId:item.itemId
                                               taskId:self.taskId
                                              handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
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
                                                  [_processableItems removeObject:indexPath];
                                                  
                                                  if (completion) {
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

#pragma mark - Private methods

- (void)reloadModelSourceControllerWithCompletion:(void (^)(NSError * error))completion {
    _fetchController.delegate = nil;
    
    [NSFetchedResultsController deleteCacheWithName:CACHE_FILE_NAME];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"taskId == %@", self.taskId];
    
    if(!_fetchController && [IQService sharedService].context) {
        NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQManagedTodoItem"];
        [fetchRequest setSortDescriptors:_sortDescriptors];
        
        _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                               managedObjectContext:[IQService sharedService].context
                                                                 sectionNameKeyPath:nil
                                                                          cacheName:CACHE_FILE_NAME];
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

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion {
    [self reloadModelSourceControllerWithCompletion:^(NSError *error) {
        if (!error) {
            [self modelDidChanged];
        }
    }];
    
    [[IQService sharedService] todoListByTaskId:self.taskId
                                        handler:^(BOOL success, NSArray * todoItems, NSData *responseData, NSError *error) {
                                            if (completion) {
                                                completion(error);
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
    [self modelDidChangeSectionAtIndex:self.section
                         forChangeType:type];
}

- (void)controller:(NSFetchedResultsController*)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    [self modelDidChangeObject:anObject
                   atIndexPath:(indexPath) ? [NSIndexPath indexPathForRow:indexPath.row inSection:self.section] : nil
                 forChangeType:type
                  newIndexPath:(newIndexPath) ? [NSIndexPath indexPathForRow:newIndexPath.row inSection:self.section] : nil];
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
