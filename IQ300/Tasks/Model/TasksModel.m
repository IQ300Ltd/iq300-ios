//
//  TasksModel.m
//  IQ300
//
//  Created by Tayphoon on 19.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TasksModel.h"
#import "TaskCell.h"
#import "IQTask.h"
#import "IQService+Tasks.h"
#import "IQCounters.h"
#import "IQTasksHolder.h"

static NSString * CellReuseIdentifier = @"CellReuseIdentifier";

#define CACHE_FILE_NAME @"TasksModelcache"
#define SORT_DIRECTION IQSortDirectionDescending

@interface TasksModel() <NSFetchedResultsControllerDelegate> {
    NSInteger _portionLenght;
    NSArray * _sortDescriptors;
    NSFetchedResultsController * _fetchController;
}

@end

@implementation TasksModel

- (id)init {
    self = [super init];
    if(self) {
        _portionLenght = 20;
        NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"updatedDate" ascending:SORT_DIRECTION == IQSortDirectionAscending];
        _sortDescriptors = @[descriptor];
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
    return CellReuseIdentifier;
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    Class cellClass = [TaskCell class];
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                            reuseIdentifier:CellReuseIdentifier];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    IQTask * item = [self itemAtIndexPath:indexPath];
    return [TaskCell heightForItem:item andCellWidth:self.cellWidth];
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
        [[IQService sharedService] tasksByFolder:self.folder
                                          status:nil
                                     communityId:nil
                                            page:@(1)
                                             per:@(_portionLenght)
                                          search:_filter
                                            sort:SORT_DIRECTION
                                         handler:^(BOOL success, IQTasksHolder * holder, NSData *responseData, NSError *error) {
                                             if(completion) {
                                                 completion(error);
                                             }
                                             if(success) {
                                                 [self updateCountersWithCompletion:nil];
                                             }
                                         }];
    }
}

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion {
    [self reloadSourceControllerWithCompletion:nil];
    [[IQService sharedService] tasksByFolder:self.folder
                                      status:nil
                                 communityId:nil
                                        page:@(1)
                                         per:@(_portionLenght)
                                      search:_filter
                                        sort:SORT_DIRECTION
                                     handler:^(BOOL success, IQTasksHolder * holder, NSData *responseData, NSError *error) {
                                         if(completion) {
                                             completion(error);
                                         }
                                         if(success) {
                                             [self updateCountersWithCompletion:nil];
                                         }
                                     }];
}

- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion {
    NSInteger count = [self numberOfItemsInSection:0];
    NSInteger page = (count > 0) ? count / _portionLenght + 1 : 0;
    [[IQService sharedService] tasksByFolder:self.folder
                                      status:nil
                                 communityId:nil
                                        page:@(page)
                                         per:@(_portionLenght)
                                      search:_filter
                                        sort:SORT_DIRECTION
                                     handler:^(BOOL success, IQTasksHolder * holder, NSData *responseData, NSError *error) {
                                         if(completion) {
                                             completion(error);
                                         }
                                         if(success) {
                                             [self updateCountersWithCompletion:nil];
                                         }
                                     }];
}

- (void)updateCountersWithCompletion:(void (^)(IQCounters * counter, NSError * error))completion {
    
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

- (void)reloadSourceControllerWithCompletion:(void (^)(NSError * error))completion {
    _fetchController.delegate = nil;
    
    [NSFetchedResultsController deleteCacheWithName:CACHE_FILE_NAME];
    _fetchController = nil;
    
    if(!_fetchController && [IQService sharedService].context) {
        NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQTask"];
        [fetchRequest setSortDescriptors:_sortDescriptors];
        _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                               managedObjectContext:[IQService sharedService].context
                                                                 sectionNameKeyPath:nil
                                                                          cacheName:CACHE_FILE_NAME];
    }
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"ownerId == %@", [IQSession defaultSession].userId];
    if([_filter length] > 0) {
        NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"(user.displayName CONTAINS[cd] $filter) OR (user.email CONTAINS[cd] $filter)"];
        filterPredicate = [filterPredicate predicateWithSubstitutionVariables:@{ @"filter" : _filter }];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, filterPredicate]];
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

@end
