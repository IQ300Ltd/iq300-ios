//
//  TaskHistoryModel.m
//  IQ300
//
//  Created by Tayphoon on 01.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TaskHistoryModel.h"
#import "IQService+Tasks.h"
#import "IQTaskHistoryItem.h"
#import "THistoryItemCell.h"

#define CACHE_FILE_NAME @"TaskHistoryModelCache"
#define SORT_DIRECTION IQSortDirectionAscending

static NSString * ReuseIdentifier = @"THReuseIdentifier";

@interface TaskHistoryModel() <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController * _fetchController;
    NSArray * _sortDescriptors;
    __weak id _notfObserver;
    NSInteger _portionSize;
}

@end

@implementation TaskHistoryModel

- (id)init {
    self = [super init];
    if(self) {
        _portionSize = 20;
        _sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"user.displayName"
                                                           ascending:SORT_DIRECTION == IQSortDirectionAscending]];
    }
    return self;
}

- (NSUInteger)numberOfSections {
    return [_fetchController.sections count];
}

- (NSString*)titleForSection:(NSInteger)section {
    return nil;
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [_fetchController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    return ReuseIdentifier;
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    Class cellClass = [THistoryItemCell class];
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleSubtitle
                            reuseIdentifier:[self reuseIdentifierForIndexPath:indexPath]];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    IQTaskHistoryItem * item = [self itemAtIndexPath:indexPath];
    return [THistoryItemCell heightForItem:item andCellWidth:self.cellWidth];
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
//        [[IQService sharedService] contactsWithPage:@(1)
//                                                per:@(_portionSize)
//                                               sort:SORT_DIRECTION
//                                             search:_filter
//                                            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
//                                                if(completion) {
//                                                    completion(error);
//                                                }
//                                            }];
    }
}

- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelWithCompletion:completion];
    }
    else {
//        NSInteger count = [self numberOfItemsInSection:0];
//        NSInteger page = (count > 0) ? count / _portionLenght + 1 : 0;
//        
//        [[IQService sharedService] tasksBeforeId:nil
//                                          folder:self.folder
//                                          status:self.statusFilter
//                                     communityId:self.communityId
//                                            page:@(page)
//                                             per:@(_portionLenght)
//                                          search:self.search
//                                            sort:_sort
//                                         handler:^(BOOL success, IQTasksHolder * holder, NSData *responseData, NSError *error) {
//                                             if(completion) {
//                                                 completion(error);
//                                             }
//                                             [self loadNextPartSourceControllerWithCompletion:nil];
//                                         }];
    }
}

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion {
    [self reloadModelSourceControllerWithCompletion:completion];
    [self updateModelWithCompletion:nil];
}

- (void)reloadModelSourceControllerWithCompletion:(void (^)(NSError * error))completion {
    _fetchController.delegate = nil;
    
    [NSFetchedResultsController deleteCacheWithName:CACHE_FILE_NAME];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"ownerId == %@", [IQSession defaultSession].userId];
    
    if(!_fetchController && [IQService sharedService].context) {
        NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQTaskHistoryItem"];
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
