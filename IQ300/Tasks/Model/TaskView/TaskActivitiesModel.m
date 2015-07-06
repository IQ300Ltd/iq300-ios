//
//  TaskActivitiesModel.m
//  IQ300
//
//  Created by Tayphoon on 01.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TaskActivitiesModel.h"
#import "IQService+Tasks.h"
#import "IQTaskActivityItem.h"
#import "TActivityItemCell.h"

#define CACHE_FILE_NAME @"TaskActivitiesModelCache"
#define SORT_DIRECTION IQSortDirectionDescending

static NSString * ReuseIdentifier = @"THReuseIdentifier";

@interface TaskActivitiesModel() <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController * _fetchController;
    NSArray * _sortDescriptors;
    __weak id _notfObserver;
    NSInteger _portionSize;
}

@end

@implementation TaskActivitiesModel

- (id)init {
    self = [super init];
    if(self) {
        _portionSize = 20;
        _sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdDate"
                                                           ascending:SORT_DIRECTION == IQSortDirectionAscending]];
    }
    return self;
}

- (NSString*)category {
    return @"history";
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
    Class cellClass = [TActivityItemCell class];
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleSubtitle
                            reuseIdentifier:[self reuseIdentifierForIndexPath:indexPath]];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    IQTaskActivityItem * item = [self itemAtIndexPath:indexPath];
    return [TActivityItemCell heightForItem:item andCellWidth:self.cellWidth];
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
        NSDate * lastUpdatedDate = [self lastActivityChangedDate];

        [[IQService sharedService] activitiesForTaskWithId:self.taskId
                                              updatedAfter:lastUpdatedDate
                                                      page:@(1)
                                                       per:@(_portionSize)
                                                      sort:SORT_DIRECTION
                                                   handler:^(BOOL success, NSArray * activities, NSData *responseData, NSError *error) {
                                                       if (completion) {
                                                           completion(error);
                                                       }
                                                   }];
    }
}

- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelWithCompletion:completion];
    }
    else {
        NSNumber * lastTaskId = [self lastIdFromBottom];
        
        [[IQService sharedService] activitiesForTaskWithId:self.taskId
                                                  beforeId:lastTaskId
                                                      page:@(1)
                                                       per:@(_portionSize)
                                                      sort:SORT_DIRECTION
                                                   handler:^(BOOL success, NSArray * activities, NSData *responseData, NSError *error) {
                                                       if (completion) {
                                                           completion(error);
                                                       }
                                                   }];
    }
}

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion {
    [self reloadModelSourceControllerWithCompletion:^(NSError *error) {
        if (!error) {
            [self modelDidChanged];
        }
    }];
    
    NSDate * lastUpdatedDate = [self lastActivityChangedDate];
    
    [[IQService sharedService] activitiesForTaskWithId:self.taskId
                                          updatedAfter:lastUpdatedDate
                                                  page:@(1)
                                                   per:@(_portionSize)
                                                  sort:SORT_DIRECTION
                                               handler:^(BOOL success, NSArray * activities, NSData *responseData, NSError *error) {
                                                   if (completion) {
                                                       completion(error);
                                                   }
                                               }];
}

- (void)reloadModelSourceControllerWithCompletion:(void (^)(NSError * error))completion {
    _fetchController.delegate = nil;
    
    [NSFetchedResultsController deleteCacheWithName:CACHE_FILE_NAME];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"taskId == %@", self.taskId];
    
    if(!_fetchController && [IQService sharedService].context) {
        NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQTaskActivityItem"];
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

- (void)resetReadFlagWithCompletion:(void (^)(NSError * error))completion {
    [[IQService sharedService] markCategoryAsReaded:self.category
                                             taskId:self.taskId
                                            handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                if (success) {
                                                    self.unreadCount = @(0);
                                                    [self modelCountersDidChanged];
                                                }
                                                if(completion) {
                                                    completion(error);
                                                }
                                            }];
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

- (NSDate*)lastActivityChangedDate {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IQTaskActivityItem"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updatedDate" ascending:NO]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"taskId == %@", self.taskId]];
    fetchRequest.fetchLimit = 1;
    
    NSError *error = nil;
    
    NSArray *objects = [[IQService sharedService].context executeFetchRequest:fetchRequest error:&error];
    if ([objects count] > 0) {
        IQTaskActivityItem * lastActivity = ((IQTaskActivityItem*)[objects objectAtIndex:0]);
        return lastActivity.updatedDate;
    }

    return nil;
}

- (NSNumber*)lastIdFromBottom {
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IQTaskActivityItem"];
    NSExpression * keyPathExpression = [NSExpression expressionForKeyPath:@"itemId"];
    NSExpression * maxIdExpression = [NSExpression expressionForFunction:@"min:"
                                                               arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"itemId"];
    [expressionDescription setExpression:maxIdExpression];
    [expressionDescription setExpressionResultType:NSDecimalAttributeType];
    
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    [fetchRequest setResultType:NSDictionaryResultType];
    fetchRequest.fetchLimit = 1;
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"taskId == %@", self.taskId]];
    
    NSError *error = nil;
    
    NSArray *objects = [[IQService sharedService].context executeFetchRequest:fetchRequest error:&error];
    if ([objects count] > 0) {
        return [[objects objectAtIndex:0] valueForKey:@"itemId"];
    }
    
    return nil;
}

- (void)applicationWillEnterForeground {
    [self updateModelWithCompletion:nil];
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
