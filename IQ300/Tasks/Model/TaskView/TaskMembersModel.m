//
//  TaskMembersModel.m
//  IQ300
//
//  Created by Tayphoon on 23.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/CoreData/NSManagedObjectContext+RKAdditions.h>

#import "TaskMembersModel.h"
#import "IQService+Tasks.h"
#import "TMemberCell.h"
#import "IQTaskMember.h"
#import "TChangesCounter.h"
#import "IQNotificationCenter.h"

#define CACHE_FILE_NAME @"TMembersModelCache"
#define SORT_DIRECTION IQSortDirectionAscending

static NSString * ReuseIdentifier = @"MReuseIdentifier";

@interface TaskMembersModel() <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController * _fetchController;
    __weak id _notfObserver;
}

@end

@implementation TaskMembersModel

- (id)init {
    self = [super init];
    if (self) {
        _sectionNameKeyPath = nil;
        
        NSSortDescriptor * roleDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"taskRole"
                                                                          ascending:YES];
        
        NSSortDescriptor * nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"user.displayName"
                                                                          ascending:SORT_DIRECTION == IQSortDirectionAscending];
        
        _sortDescriptors = @[roleDescriptor, nameDescriptor];
        
        [self resubscribeToIQNotifications];
    }
    
    return self;
}

- (NSString*)category {
    return @"users";
}

- (NSArray*)members {
    return [_fetchController fetchedObjects];
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
    Class cellClass = [TMemberCell class];
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleSubtitle
                            reuseIdentifier:ReuseIdentifier];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    return 68;
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
        [[IQService sharedService] membersByTaskId:self.taskId
                                           handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                                               if(completion) {
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
    
    [[IQService sharedService] membersByTaskId:self.taskId
                                       handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                                           if(completion) {
                                               completion(error);
                                           }
                                       }];
}

- (void)addMemberWithUserId:(NSNumber*)userId completion:(void (^)(NSError * error))completion {
    [[IQService sharedService] addMemberWithUserId:userId
                                      inTaskWithId:self.taskId
                                           handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                                               if(completion) {
                                                   completion(error);
                                               }
                                           }];
}

- (void)removeMemberWithId:(NSNumber*)memberId completion:(void (^)(NSError * error))completion {
    [[IQService sharedService] removeMemberWithId:memberId
                                   fromTaskWithId:self.taskId
                                          handler:^(BOOL success, NSData *responseData, NSError *error) {
                                              if (success) {
                                                  NSError * removeError = nil;
                                                  if(![self removeLocalMemeberWithId:memberId error:&removeError]) {
                                                      NSLog(@"Failed to delete member with id %@ from task with id %@", memberId, self.taskId);
                                                  }
                                              }
                                              if(completion) {
                                                  completion(error);
                                              }
                                          }];
}

- (void)leaveTaskWithMemberId:(NSNumber*)memberId completion:(void (^)(NSError * error))completion {
    [[IQService sharedService] leaveTaskWithId:self.taskId
                                       handler:^(BOOL success, NSData *responseData, NSError *error) {
                                           if (success) {
                                               NSError * removeError = nil;
                                               if(memberId && ![self removeLocalMemeberWithId:memberId error:&removeError]) {
                                                   NSLog(@"Failed to delete member with id %@ from task with id %@ error: %@", memberId, self.taskId, removeError);
                                               }
                                           }
                                           if(completion) {
                                               completion(error);
                                           }
                                       }];
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
        NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQTaskMember"];
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

- (void)updateCountersWithCompletion:(void (^)(TChangesCounter * counters, NSError * error))completion {
    [[IQService sharedService] taskChangesCounterById:self.taskId
                                              handler:^(BOOL success, TChangesCounter * counter, NSData *responseData, NSError *error) {
        if(success) {
            self.unreadCount = counter.users;
            [self modelCountersDidChanged];
        }
        if(completion) {
            completion(counter, error);
        }
    }];
}

- (BOOL)removeLocalMemeberWithId:(NSNumber*)memberId error:(NSError**)error {
    NSManagedObjectContext * context = [IQService sharedService].context;
    NSFetchRequest * fRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQTaskMember"];
    [fRequest setPredicate:[NSPredicate predicateWithFormat:@"memberId == %@", memberId]];
    [fRequest setFetchLimit:1];
    
    NSError * fetchError = nil;
    IQTaskMember * memeber = [[context executeFetchRequest:fRequest error:&fetchError] lastObject];
    if (memeber) {
        [memeber.managedObjectContext deleteObject:memeber];
        
        NSError *saveError = nil;
        if([[IQService sharedService].context saveToPersistentStore:&saveError] ) {
            return YES;
        }
        else if(error) {
            *error = saveError;
        }
    }
    else if(error) {
        *error = fetchError;
    }

    return NO;
}

- (void)resubscribeToIQNotifications {
    [self unsubscribeFromIQNotifications];
    
    __weak typeof(self) weakSelf = self;
    void (^block)(IQCNotification * notf) = ^(IQCNotification * notf) {
        NSArray * tasks = notf.userInfo[IQNotificationDataKey];
        NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"task_id == %@", weakSelf.taskId];
        NSDictionary * curTask = [[tasks filteredArrayUsingPredicate:filterPredicate] lastObject];

        if(curTask) {
            [weakSelf updateModelWithCompletion:nil];
            
            NSNumber * count = curTask[@"counter"];
            if(![weakSelf.unreadCount isEqualToNumber:count]) {
                if (weakSelf.resetReadFlagAutomatically) {
                    [weakSelf resetReadFlagWithCompletion:nil];
                }
                else {
                    weakSelf.unreadCount = count;
                    [weakSelf modelCountersDidChanged];
                }
            }
        }
    };
    _notfObserver = [[IQNotificationCenter defaultCenter] addObserverForName:IQTaskMembersDidChangedNotification
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
