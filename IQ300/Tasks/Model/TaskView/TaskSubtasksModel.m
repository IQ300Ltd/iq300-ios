//
//  TaskSubtasksModel.m
//  IQ300
//
//  Created by Vladislav Grigoriev on 22/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "TaskSubtasksModel.h"
#import "IQTableManagedModel+Subclass.h"
#import "IQService.h"
#import "IQService+Tasks.h"
#import "TSubtaskCell.h"
#import "IQSubtask.h"
#import "IQSubtasksHolder.h"

#define CACHE_FILE_NAME @"SubtasksModelcache"


NSString *const SubtaskCellReuseIdentifier = @"SubtaskCellReuseIdentifier";

@interface TaskSubtasksModel() {
    NSInteger _portionLenght;
}

@end

@implementation TaskSubtasksModel

- (NSDate*)subtasksLastChangedDate {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IQSubtask"];
    [fetchRequest setPredicate:[self fetchPredicate]];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updatedDate" ascending:NO]];
    fetchRequest.fetchLimit = 1;
    
    NSError *error = nil;
    
    NSArray *objects = [[IQService sharedService].context executeFetchRequest:fetchRequest error:&error];
    if ([objects count] > 0) {
        IQSubtask * subtask = [objects objectAtIndex:0];
        return subtask.updatedDate;
    }
    return nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:YES]];
        _portionLenght = 20;
    }
    return self;
}

- (NSString *)category {
    return @"subtasks";
}

#pragma mark - IQTableManagedModel

- (NSString*)cacheFileName {
    return @"SubtasksModelCache";
}

- (NSString*)entityName {
    return @"IQSubtask";
}

- (NSManagedObjectContext*)context {
    return [IQService sharedService].context;
}

- (NSPredicate*)fetchPredicate {
    NSPredicate * fetchPredicate = nil;
    if (_taskId) {
        fetchPredicate = [NSPredicate predicateWithFormat:@"parentId == %@", _taskId];

    }
    return fetchPredicate;
}

#pragma mark - IQTableModel

- (Class)cellClassForIndexPath:(NSIndexPath*)indexPath {
    return [TSubtaskCell class];
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    return SubtaskCellReuseIdentifier;
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    return [TSubtaskCell heightForItem:[self itemAtIndexPath:indexPath] andCellWidth:self.cellWidth];
}

- (void)updateModelWithCompletion:(void (^)(NSError *))completion {
    if (!_fetchController) {
        [self reloadModelWithCompletion:completion];
    }
    else {
        [self subtasksUpdatesAfterDateWithCompletion:completion];
    }
}

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion {
    [self reloadModelSourceControllerWithCompletion:^(NSError *error) {
        [self modelDidChanged];
        [self updateModelFromServiceWithCompletion:completion];
    }];
}

- (void)updateModelFromServiceWithCompletion:(void (^)(NSError *))completion {
    [[IQService sharedService] subtasksForTaskWithId:_taskId
                                        updatedAfter:nil
                                                page:@(1)
                                                 per:@(_portionLenght)
                                             handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                                                 if(success) {
                                                     [self reloadSourceControllerWithCompletion:completion];
                                                 }
                                                 else if(completion) {
                                                     completion(error);
                                                 }
                                             }];
}

- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelWithCompletion:completion];
    }
    else {
        NSInteger count = [self numberOfItemsInSection:0];
        NSInteger page = (count > 0) ? count / _portionLenght + 1 : 1;
        
        [[IQService sharedService] subtasksForTaskWithId:_taskId
                                            updatedAfter:nil
                                                    page:@(page)
                                                     per:@(_portionLenght)
                                                 handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                                                     if(completion) {
                                                         completion(error);
                                                     }
                                                     [self loadNextPartSourceControllerWithCompletion:nil];
                                                 }];
    }
}


- (void)subtasksUpdatesAfterDate:(NSDate*)lastUpdatedDate page:(NSNumber*)page completion:(void (^)(NSError * error))completion {
    [[IQService sharedService] subtasksForTaskWithId:_taskId
                                        updatedAfter:lastUpdatedDate
                                                page:page
                                                 per:@(_portionLenght)
                                             handler:^(BOOL success, IQSubtasksHolder *holder, NSData *responseData, NSError *error) {
                                                 if (success && [holder.currentPage compare:holder.totalPages] == NSOrderedAscending) {
                                                     [self subtasksUpdatesAfterDate:lastUpdatedDate
                                                                               page:@([page integerValue] + 1)
                                                                         completion:completion];
                                                 }
                                                 else if(completion) {
                                                     completion(error);
                                                 }
                                             }];
}

- (void)subtasksUpdatesAfterDateWithCompletion:(void (^)(NSError * error))completion {
    NSDate * lastUpdatedDate = [self subtasksLastChangedDate];
    [self subtasksUpdatesAfterDate:lastUpdatedDate
                              page:@(1)
                        completion:completion];
}

- (void)reloadSourceControllerWithCompletion:(void (^)(NSError * error))completion {
    _fetchController.delegate = nil;
    
    [NSFetchedResultsController deleteCacheWithName:CACHE_FILE_NAME];
    _fetchController = nil;
    
    if(!_fetchController && [IQService sharedService].context) {
        NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQSubtask"];
        [fetchRequest setSortDescriptors:self.sortDescriptors];
        _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                               managedObjectContext:[IQService sharedService].context
                                                                 sectionNameKeyPath:nil
                                                                          cacheName:CACHE_FILE_NAME];
    }
    
    NSError * fetchError = nil;
    [_fetchController.fetchRequest setFetchLimit:_portionLenght];
    [_fetchController.fetchRequest setPredicate:[self fetchPredicate]];
    [_fetchController.fetchRequest setSortDescriptors:self.sortDescriptors];
    [_fetchController setDelegate:self];
    [_fetchController performFetch:&fetchError];
    
    if(completion) {
        completion(fetchError);
    }
}

- (void)loadNextPartSourceControllerWithCompletion:(void (^)(NSError * error))completion {
    [NSFetchedResultsController deleteCacheWithName:CACHE_FILE_NAME];
    
    NSInteger count = [self numberOfItemsInSection:0];
    NSInteger fetchLimit = _fetchController.fetchRequest.fetchLimit;
    
    //load next portiosion from fetchController
    NSError * fetchError = nil;
    [_fetchController.fetchRequest setFetchLimit:fetchLimit + _portionLenght];
    [_fetchController performFetch:&fetchError];
    if (!fetchError) {
        NSInteger itemsCount = [self numberOfItemsInSection:0];
        NSInteger difference = itemsCount - count;
        if(difference > 0) {
            [self modelWillChangeContent];
            NSInteger lastIndex = count - 1;
            for (NSInteger i = lastIndex; i < itemsCount - 1; i++) {
                [self modelDidChangeObject:nil
                               atIndexPath:nil
                             forChangeType:NSFetchedResultsChangeInsert
                              newIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            [self modelDidChangeContent];
        }
    }
    
    if (completion) {
        completion(fetchError);
    }
}





@end
