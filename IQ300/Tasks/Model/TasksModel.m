//
//  TasksModel.m
//  IQ300
//
//  Created by Tayphoon on 19.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <RestKit/CoreData/NSManagedObjectContext+RKAdditions.h>

#import "TasksModel.h"
#import "TaskCell.h"
#import "IQTask.h"
#import "IQService+Tasks.h"
#import "IQCounters.h"
#import "IQTasksHolder.h"
#import "IQNotificationCenter.h"
#import "NSManagedObjectContext+AsyncFetch.h"
#import "IQTaskDeletedIds.h"

static NSString * CellReuseIdentifier = @"CellReuseIdentifier";

#define CACHE_FILE_NAME @"TasksModelcache"

#define SORT_DIRECTION IQSortDirectionDescending

#define LAST_REQUEST_DATE_KEY @"task_ids_request_date"

#define ACTUAL_FORMAT @"type LIKE[c] 'Task' AND (customer.userId == $userId OR executor.userId == $userId) AND \
                        (status IN {\"new\", \"in_work\", \"browsed\", \"completed\", \"refused\", \"declined\"} OR \
                         (status LIKE[c] 'on_init' AND customer.userId == $userId))"

#define OVERDUE_FORMAT @"type LIKE[c] 'Task' AND endDate < $nowDate AND \
                         ((executor.userId == $userId AND status IN {\"new\", \"browsed\", \"in_work\", \"on_init\", \"declined\"}) OR \
                          (customer.userId == $userId AND status IN {\"new\", \"browsed\", \"refused\", \"in_work\", \"on_init\", \"declined\", \"completed\"}))"

#define INBOX_FORMAT @"type LIKE[c] 'Task' AND executor.userId == $userId AND \
                       status IN {\"new\", \"in_work\", \"browsed\", \"completed\", \"refused\", \"declined\"}"

#define OUTBOX_FORMAT @"type LIKE[c] 'Task' AND customer.userId == $userId AND executor.userId != $userId AND \
                        status IN {\"new\", \"in_work\", \"browsed\", \"completed\", \"refused\", \"declined\", \"on_init\"}"

#define ARCHIVE_FORMAT @"type LIKE[c] 'Task' AND (customer.userId == $userId OR executor.userId == $userId) AND \
                         status IN {\"accepted\", \"canceled\"}"

@interface TasksModel() <NSFetchedResultsControllerDelegate> {
    NSInteger _portionLenght;
    NSFetchedResultsController * _fetchController;
    NSString * _sort;
    __weak id _notfObserver;
}

@end

@implementation TasksModel

+ (NSPredicate*)predicateForFolder:(NSString*)folder userId:(NSNumber*)userId {
    static NSDictionary * _folders = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _folders = @{
                     @"actual"    : ACTUAL_FORMAT,
                     @"overdue"   : OVERDUE_FORMAT,
                     @"inbox"     : INBOX_FORMAT,
                     @"outbox"    : OUTBOX_FORMAT,
                     @"watchable" : @"type LIKE[c] 'Task' AND (customer.userId != $userId AND executor.userId != $userId)",
                     @"templates" : @"type LIKE[c] 'TemplateTask' AND ownerId == $userId AND ownerType LIKE[c] 'User'",
                     @"archive"   : ARCHIVE_FORMAT
                     };
    });
    
    if([_folders objectForKey:folder]) {
        NSString * format = [_folders objectForKey:folder];
        NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:format];
        filterPredicate = [filterPredicate predicateWithSubstitutionVariables:@{ @"userId" : NSObjectNullForNil(userId),
                                                                                 @"nowDate" : [NSDate date]}];
        return filterPredicate;
    }
    
    return nil;
}

+ (NSString*)propertyNameForSortField:(NSString*)sortField {
    static NSDictionary * _propertyNames = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _propertyNames = @{
                                @"updated_at" : @"updatedDate",
                                @"id"         : @"taskId",
                                @"end_date"   : @"endDate",
                                };
    });
    
    if([_propertyNames objectForKey:sortField]) {
        return [_propertyNames objectForKey:sortField];
    }
    
    return nil;
}

+ (NSDate*)lastRequestDate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:LAST_REQUEST_DATE_KEY];
}

+ (void)setLastRequestDate:(NSDate*)date {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:date forKey:LAST_REQUEST_DATE_KEY];
}

- (id)init {
    self = [super init];
    if(self) {
        _portionLenght = 20;
        self.ascending = NO;
        self.sortField = @"updated_at";
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(accountDidChanged)
                                                     name:AccountDidChangedNotification
                                                   object:nil];
        [self resubscribeToIQNotifications];
    }
    return self;
}

- (void)setAscending:(BOOL)ascending {
    if (_ascending != ascending) {
        _ascending = ascending;
        NSString * format = (_ascending) ? @"%@" : @"-%@";
        _sort = [NSString stringWithFormat:format, _sortField];
    }
}

- (void)setSortField:(NSString *)sortField {
    if(![_sortField isEqualToString:sortField]) {
        _sortField = sortField;
        NSString * format = (_ascending) ? @"%@" : @"-%@";
        _sort = [NSString stringWithFormat:format, _sortField];
    }
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
        [self clearRemovedTasks];
        [self updateCountersWithCompletion:nil];
        [self tasksUpdatesAfterDateWithCompletion:completion];
    }
}

- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelWithCompletion:completion];
    }
    else {
        NSInteger count = [self numberOfItemsInSection:0];
        NSInteger page = (count > 0) ? count / _portionLenght + 1 : 1;
        
        [[IQService sharedService] tasksBeforeId:nil
                                          folder:self.folder
                                          status:self.statusFilter
                                     communityId:self.communityId
                                            page:@(page)
                                             per:@(_portionLenght)
                                          search:self.search
                                            sort:_sort
                                         handler:^(BOOL success, IQTasksHolder * holder, NSData *responseData, NSError *error) {
                                             if(completion) {
                                                 completion(error);
                                             }
                                             [self loadNextPartSourceControllerWithCompletion:nil];
                                         }];
    }
}

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion {
    [self updateCountersWithCompletion:nil];

    [self reloadSourceControllerWithCompletion:^(NSError *error) {
        if (!error) {
            [self modelDidChanged];
            [self clearRemovedTasks];
        }
    }];
    
    [[IQService sharedService] tasksUpdatedAfter:nil
                                          folder:self.folder
                                          status:self.statusFilter
                                     communityId:self.communityId
                                            page:@(1)
                                             per:@(_portionLenght)
                                          search:self.search
                                            sort:_sort
                                         handler:^(BOOL success, IQTasksHolder * holder, NSData *responseData, NSError *error) {
                                             
                                             //update other folder because task may move from selected folder to another
                                             [self otherFoldersUpdatesWithCompletion:^(NSError *error) {
                                                 if (error) {
                                                     NSLog(@"Archive tasks updates error: %@", error);
                                                 }
                                             }];

                                             if(success) {
                                                 [self reloadSourceControllerWithCompletion:completion];

                                                 if ([_fetchController.fetchedObjects count] < _portionLenght) {
                                                     [self tryLoadFullPartitionWithCompletion:^(NSError *error) {
                                                         if (error) {
                                                             NSLog(@"Archive tasks updates error: %@", error);
                                                         }
                                                     }];
                                                 }
                                             }
                                             else if(completion) {
                                                 completion(error);
                                             }
                                         }];
}

- (void)updateCountersWithCompletion:(void (^)(TasksMenuCounters * counters, NSError * error))completion {
    [[IQService sharedService] tasksMenuCountersWithHandler:^(BOOL success, TasksMenuCounters * object, NSData *responseData, NSError *error) {
        if(success) {
            self.counters = object;
            [self modelCountersDidChanged];
        }
        if(completion) {
            completion(object, error);
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

- (void)clearRemovedTasks {
    NSDate * lastRequestDate = [TasksModel lastRequestDate];
    
    [[IQService sharedService] taskIdsDeletedAfter:lastRequestDate
                                           handler:^(BOOL success, IQTaskDeletedIds * object, NSData *responseData, NSError *error) {
                                               if (success) {
                                                   [TasksModel setLastRequestDate:object.serverDate];
                                                   [self removeLocalTasksWithIds:object.objectIds];
                                               }
                                           }];
}

- (void)removeLocalTasksWithIds:(NSArray*)taskIds {
    if ([taskIds count] > 0) {
        NSManagedObjectContext * context = [IQService sharedService].context;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IQTask"];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"taskId IN %@", taskIds]];
        
        [context executeFetchRequest:fetchRequest completion:^(NSArray *objects, NSError *error) {
            if ([objects count] > 0) {
                for (NSManagedObject * object in objects) {
                    [context deleteObject:object];
                }
                
                NSError * saveError = nil;
                if(![context saveToPersistentStore:&saveError] ) {
                    NSLog(@"Failed save to presistent store after tasks removed");
                }
            }
        }];
    }
}

- (void)tasksUpdatesAfterDate:(NSDate*)lastUpdatedDate page:(NSNumber*)page completion:(void (^)(NSError * error))completion {
    [[IQService sharedService] tasksUpdatedAfter:lastUpdatedDate
                                          folder:self.folder
                                          status:self.statusFilter
                                     communityId:self.communityId
                                            page:page
                                             per:@(_portionLenght)
                                          search:self.search
                                            sort:_sort
                                         handler:^(BOOL success, IQTasksHolder * holder, NSData *responseData, NSError *error) {
                                             if(success && holder.currentPage < holder.totalPages) {
                                                 [self tasksUpdatesAfterDate:lastUpdatedDate
                                                                        page:@([page integerValue] + 1)
                                                                  completion:completion];
                                             }
                                             else if(completion) {
                                                 completion(error);
                                             }
                                         }];
}

- (void)tasksUpdatesAfterDateWithCompletion:(void (^)(NSError * error))completion {
    NSDate * lastUpdatedDate = [self taskLastChangedDateForFolder];
    [self tasksUpdatesAfterDate:lastUpdatedDate
                           page:@(1)
                     completion:completion];
    
    //update other folder because task may move from selected folder to another
    [self otherFoldersUpdatesWithCompletion:^(NSError *error) {
        if (error) {
            NSLog(@"Archive tasks updates error: %@", error);
        }
    }];
}

- (void)otherFoldersUpdatesAfterDate:(NSDate*)lastUpdatedDate page:(NSNumber*)page completion:(void (^)(NSError * error))completion {
    [[IQService sharedService] tasksUpdatedAfter:lastUpdatedDate
                                   excludeFolder:self.folder
                                            page:@(1)
                                             per:@(_portionLenght)
                                          search:self.search
                                            sort:_sort
                                         handler:^(BOOL success, IQTasksHolder * holder, NSData *responseData, NSError *error) {
                                             if(success && holder.currentPage < holder.totalPages) {
                                                 [self otherFoldersUpdatesAfterDate:lastUpdatedDate
                                                                               page:@([page integerValue] + 1)
                                                                         completion:completion];
                                             }
                                             else if(completion) {
                                                 completion(error);
                                             }
                                         }];
}

- (void)otherFoldersUpdatesWithCompletion:(void (^)(NSError * error))completion {
    NSDate * lastUpdatedDate = [self taskLastChangedDate];

    [self otherFoldersUpdatesAfterDate:lastUpdatedDate
                                  page:@(1)
                            completion:^(NSError *error) {
                                if(completion) {
                                    completion(error);
                                }
                            }];
}

- (void)tryLoadFullPartitionWithCompletion:(void (^)(NSError * error))completion {
    NSInteger count = [self numberOfItemsInSection:0];
    NSInteger page = (count > 0) ? count / _portionLenght + 1 : 1;

    [[IQService sharedService] tasksBeforeId:nil
                                      folder:self.folder
                                      status:self.statusFilter
                                 communityId:self.communityId
                                        page:@(page)
                                         per:@(_portionLenght)
                                      search:self.search
                                        sort:_sort
                                     handler:^(BOOL success, IQTasksHolder * holder, NSData *responseData, NSError *error) {
                                         if(completion) {
                                             completion(error);
                                         }
                                     }];
}

- (void)reloadSourceControllerWithCompletion:(void (^)(NSError * error))completion {
    _fetchController.delegate = nil;
    
    [NSFetchedResultsController deleteCacheWithName:CACHE_FILE_NAME];
    _fetchController = nil;
    
    if(!_fetchController && [IQService sharedService].context) {
        NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQTask"];
        [fetchRequest setSortDescriptors:[self makeSortDescriptors]];
        _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                               managedObjectContext:[IQService sharedService].context
                                                                 sectionNameKeyPath:nil
                                                                          cacheName:CACHE_FILE_NAME];
    }
    
    NSError * fetchError = nil;
    [_fetchController.fetchRequest setFetchLimit:_portionLenght];
    [_fetchController.fetchRequest setPredicate:[self makeFilterPredicate]];
    [_fetchController.fetchRequest setSortDescriptors:[self makeSortDescriptors]];
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

/**
 *  Last task id by max/min sort field
 *
 *  @param top If top return max sort field
 *
 *  @return Task id
 */
- (NSNumber*)lastTaskIdFromTop:(BOOL)top {
    NSString * keyPath = [TasksModel propertyNameForSortField:self.sortField];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IQTask"];
    [fetchRequest setPredicate:[self makeFilterPredicate]];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:keyPath ascending:top]];
    [fetchRequest setPropertiesToFetch:@[@"taskId"]];
    [fetchRequest setResultType:NSDictionaryResultType];
    fetchRequest.fetchLimit = 1;
    
    NSError *error = nil;
    
    NSArray *objects = [[IQService sharedService].context executeFetchRequest:fetchRequest error:&error];
    if ([objects count] > 0) {
        return [[objects objectAtIndex:0] valueForKey:@"taskId"];
    }
    return nil;
}

- (NSDate*)taskLastChangedDateForFolder {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IQTask"];
    [fetchRequest setPredicate:[self makeFilterPredicate]];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updatedDate" ascending:NO]];
    fetchRequest.fetchLimit = 1;

    NSError *error = nil;
    
    NSArray *objects = [[IQService sharedService].context executeFetchRequest:fetchRequest error:&error];
    if ([objects count] > 0) {
        IQTask * task = [objects objectAtIndex:0];
        return task.updatedDate;
    }
    return nil;
}

- (NSDate*)taskLastChangedDate {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IQTask"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updatedDate" ascending:NO]];
    fetchRequest.fetchLimit = 1;
    
    NSError *error = nil;
    
    NSArray *objects = [[IQService sharedService].context executeFetchRequest:fetchRequest error:&error];
    if ([objects count] > 0) {
        IQTask * task = [objects objectAtIndex:0];
        return task.updatedDate;
    }
    return nil;
}

- (NSPredicate*)makeFilterPredicate {
    return [self makeFilterPredicateForFolder:self.folder
                                  communityId:self.communityId
                                 statusFilter:self.statusFilter
                                       search:self.search];
}

- (NSPredicate*)makeFilterPredicateForFolder:(NSString*)folder
                                 communityId:(NSNumber*)communityId
                                statusFilter:(NSString*)statusFilter
                                      search:(NSString*)search {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"recipientId == %@", [IQSession defaultSession].userId];
    
    if([folder length] > 0) {
        NSPredicate * folderPredicate = [TasksModel predicateForFolder:folder userId:[IQSession defaultSession].userId];
        if(folderPredicate) {
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, folderPredicate]];
        }
    }
    
    if (communityId) {
        NSPredicate * communityFilter = [NSPredicate predicateWithFormat:@"community.communityId == %@", communityId];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, communityFilter]];
    }
    
    if([statusFilter length] > 0) {
        NSPredicate * statusFilterPredicate = [NSPredicate predicateWithFormat:@"status LIKE[c] %@", statusFilter];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, statusFilterPredicate]];
    }
    
    if([search length] > 0) {
        NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"(user.displayName CONTAINS[cd] $filter) OR (user.email CONTAINS[cd] $filter)"];
        filterPredicate = [filterPredicate predicateWithSubstitutionVariables:@{ @"filter" : search }];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, filterPredicate]];
    }
    
    return predicate;
}

- (NSArray*)makeSortDescriptors {
    NSString * key = [TasksModel propertyNameForSortField:self.sortField];    
    if (key) {
        NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:key
                                                                    ascending:self.ascending];
        
        if (![key isEqualToString:@"taskId"]) {
            NSSortDescriptor * taskIdDescriptor = [[NSSortDescriptor alloc] initWithKey:@"taskId"
                                                                              ascending:self.ascending];
            return @[descriptor, taskIdDescriptor];
        }
        return @[descriptor];
    }
    return nil;
}

- (void)accountDidChanged {
    if([IQSession defaultSession]) {
        [self resubscribeToIQNotifications];
        [self updateCountersWithCompletion:nil];
    }
    else {
        self.ascending = NO;
        self.sortField = @"updated_at";
        self.statusFilter = nil;
        self.communityId = nil;
        
        [self unsubscribeFromIQNotifications];
        [self clearModelData];
        [self modelDidChanged];
    }
}

- (void)resubscribeToIQNotifications {
    [self unsubscribeFromIQNotifications];
    
    __weak typeof(self) weakSelf = self;
    void (^block)(IQCNotification * notf) = ^(IQCNotification * notf) {
        [weakSelf clearRemovedTasks];
        [weakSelf updateCountersWithCompletion:nil];
        [weakSelf tasksUpdatesAfterDateWithCompletion:nil];
    };
    _notfObserver = [[IQNotificationCenter defaultCenter] addObserverForName:IQTasksDidChangedNotification
                                                                       queue:nil
                                                                  usingBlock:block];
}

- (void)unsubscribeFromIQNotifications {
    if(_notfObserver) {
        [[IQNotificationCenter defaultCenter] removeObserver:_notfObserver];
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
    [self unsubscribeFromIQNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
