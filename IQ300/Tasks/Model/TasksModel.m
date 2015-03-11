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
#import "IQNotificationCenter.h"

static NSString * CellReuseIdentifier = @"CellReuseIdentifier";

#define CACHE_FILE_NAME @"TasksModelcache"
#define SORT_DIRECTION IQSortDirectionDescending

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
                     @"templates" : @"type LIKE[c] 'TemplateTask' AND ownerId == $userId",
                     @"archive"   : ARCHIVE_FORMAT
                     };
    });
    
    if([_folders objectForKey:folder]) {
        NSString * format = [_folders objectForKey:folder];
        NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:format];
        filterPredicate = [filterPredicate predicateWithSubstitutionVariables:@{ @"userId" : userId,
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


- (id)init {
    self = [super init];
    if(self) {
        _portionLenght = 20;
        self.sortField = @"updated_at";
        self.ascending = NO;
        
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
        [self updateCountersWithCompletion:nil];
        [self tasksUpdatesAfterDateWithCompletion:completion];
    }
}

- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelWithCompletion:completion];
    }
    else {
        NSNumber * taskId = [self getLastTaskIdFromTop:!self.ascending];
        [[IQService sharedService] tasksBeforeId:taskId
                                          folder:self.folder
                                          status:self.statusFilter
                                     communityId:self.communityId
                                            page:@(1)
                                             per:@(_portionLenght)
                                          search:self.search
                                            sort:_sort
                                         handler:^(BOOL success, IQTasksHolder * holder, NSData *responseData, NSError *error) {
                                             if(completion) {
                                                 completion(error);
                                             }
                                         }];
    }
}

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion {
    [self reloadSourceControllerWithCompletion:completion];
   
    NSDate * lastUpdatedDate = [self getLastChangedDate];
    
    [self updateCountersWithCompletion:nil];
    [[IQService sharedService] tasksUpdatedAfter:lastUpdatedDate
                                          folder:self.folder
                                          status:self.statusFilter
                                     communityId:self.communityId
                                            page:@(1)
                                             per:@(_portionLenght)
                                          search:self.search
                                            sort:_sort
                                         handler:^(BOOL success, IQTasksHolder * holder, NSData *responseData, NSError *error) {
                                             if(success && lastUpdatedDate && [_fetchController.fetchedObjects count] < _portionLenght) {
                                                 [self tryLoadFullPartitionWithCompletion:^(NSError *error) {
                                                     if(completion) {
                                                         completion(error);
                                                     }
                                                 }];
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
    NSDate * lastUpdatedDate = [self getLastChangedDate];
    [self tasksUpdatesAfterDate:lastUpdatedDate
                           page:@(1)
                     completion:completion];
}

- (void)tryLoadFullPartitionWithCompletion:(void (^)(NSError * error))completion {
    NSNumber * lastLoadedId = [self getLastTaskIdFromTop:self.ascending];
    
    [[IQService sharedService] tasksBeforeId:lastLoadedId
                                      folder:self.folder
                                      status:self.statusFilter
                                 communityId:self.communityId
                                        page:@(1)
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
    [_fetchController.fetchRequest setPredicate:[self makeFilterPredicate]];
    [_fetchController.fetchRequest setSortDescriptors:[self makeSortDescriptors]];
    [_fetchController setDelegate:self];
    [_fetchController performFetch:&fetchError];
    
    if(completion) {
        completion(fetchError);
    }
}

/**
 *  Get task id by max/min sort field
 *
 *  @param top If top return max sort field
 *
 *  @return Task id
 */
- (NSNumber*)getLastTaskIdFromTop:(BOOL)top {
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

- (NSDate*)getLastChangedDate {
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

- (NSPredicate*)makeFilterPredicate {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"recipientId == %@", [IQSession defaultSession].userId];
    
    if([self.folder length] > 0) {
        NSPredicate * folderPredicate = [TasksModel predicateForFolder:self.folder userId:[IQSession defaultSession].userId];
        if(folderPredicate) {
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, folderPredicate]];
        }
    }
    
    if (self.communityId) {
        NSPredicate * communityFilter = [NSPredicate predicateWithFormat:@"community.communityId == %@", self.communityId];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, communityFilter]];
    }
    
    if(self.statusFilter) {
        NSPredicate * statusFilter = [NSPredicate predicateWithFormat:@"status LIKE[c] %@", self.statusFilter];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, statusFilter]];
    }
    
    if([self.search length] > 0) {
        NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"(user.displayName CONTAINS[cd] $filter) OR (user.email CONTAINS[cd] $filter)"];
        filterPredicate = [filterPredicate predicateWithSubstitutionVariables:@{ @"filter" : self.search }];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, filterPredicate]];
    }

    return predicate;
}

- (NSArray*)makeSortDescriptors {
    NSString * key = [TasksModel propertyNameForSortField:self.sortField];    
    if (key) {
        NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:key
                                                                    ascending:self.ascending];
        
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
        self.sortField = @"updated_at";
        self.ascending = NO;
        self.statusFilter = nil;
        self.communityId = nil;
        
        [self unsubscribeFromIQNotifications];
        [self clearModelData];
        [self modelDidChanged];
    }
}

- (void)applicationWillEnterForeground {
    [self updateCountersWithCompletion:nil];
    [self tasksUpdatesAfterDateWithCompletion:nil];
}

- (void)resubscribeToIQNotifications {
    [self unsubscribeFromIQNotifications];
    
    __weak typeof(self) weakSelf = self;
    void (^block)(IQCNotification * notf) = ^(IQCNotification * notf) {
        [weakSelf updateCountersWithCompletion:nil];
        [weakSelf tasksUpdatesAfterDateWithCompletion:nil];
    };
    _notfObserver = [[IQNotificationCenter defaultCenter] addObserverForName:IQTasksDidChanged
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
    [[IQNotificationCenter defaultCenter] removeObserver:_notfObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
