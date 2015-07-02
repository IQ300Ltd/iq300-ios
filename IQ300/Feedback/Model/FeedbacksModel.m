//
//  FeedbacksModel.m
//  IQ300
//
//  Created by Tayphoon on 23.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "FeedbacksModel.h"
#import "IQFeedbacksHolder.h"
#import "IQService+Feedback.h"
#import "FeedbackCell.h"

static NSString * CellReuseIdentifier = @"CellReuseIdentifier";

@interface FeedbacksModel() {
    NSInteger _portionLenght;
}

@end

@implementation FeedbacksModel

- (id)init {
    self = [super init];
    if (self) {
        _portionLenght = 20;
        NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"feedbackId" ascending:NO];
        self.sortDescriptors = @[descriptor];
    }
    return self;
}

- (NSString*)cacheFileName {
    return @"FeedbacksModelCache";
}

- (NSString*)entityName {
    return @"IQManagedFeedback";
}

- (NSManagedObjectContext*)context {
    return [IQService sharedService].context;
}

- (NSPredicate*)fetchPredicate {
    NSPredicate * fetchPredicate = nil;
    if (!fetchPredicate && [IQSession defaultSession]) {
        fetchPredicate = [NSPredicate predicateWithFormat:@"author.userId == %@", [IQSession defaultSession].userId];
    }

    if(fetchPredicate && [_search length] > 0) {
        NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"(feedbackDescription CONTAINS[cd] %@)", _search];
        fetchPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[fetchPredicate, filterPredicate]];
    }

    return fetchPredicate;
}

- (Class)cellClass {
    return [FeedbackCell class];
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    return CellReuseIdentifier;
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    IQManagedFeedback * item = [self itemAtIndexPath:indexPath];
    return [FeedbackCell heightForItem:item andCellWidth:self.cellWidth];
}

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelWithCompletion:completion];
    }
    else {
        [self feedbacksUpdatesAfterDateWithCompletion:completion];
    }
}

- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelWithCompletion:completion];
    }
    else {
        NSNumber * feedbackId = [self lastFeedbackIdFromTop:YES];
        [[IQService sharedService] feedbacksBeforeId:feedbackId
                                                page:@(1)
                                                 per:@(_portionLenght)
                                              search:self.search
                                             handler:^(BOOL success, IQFeedbacksHolder * holder, NSData *responseData, NSError *error) {
                                                 if(completion) {
                                                     completion(error);
                                                 }
                                             }];
    }
}

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion {
    [self reloadModelSourceControllerWithCompletion:completion];
    
    [[IQService sharedService] feedbacksUpdatedAfter:nil
                                                page:@(1)
                                                 per:@(_portionLenght)
                                              search:self.search
                                             handler:^(BOOL success, IQFeedbacksHolder * holder, NSData *responseData, NSError *error) {
                                                 if(success && [_fetchController.fetchedObjects count] < _portionLenght) {
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

#pragma mark - Private methods

- (void)tryLoadFullPartitionWithCompletion:(void (^)(NSError * error))completion {
    NSInteger count = [self numberOfItemsInSection:0];
    NSInteger page = (count > 0) ? count / _portionLenght : 0;
    
    [[IQService sharedService] feedbacksBeforeId:nil
                                            page:@(page)
                                             per:@(_portionLenght)
                                          search:self.search
                                         handler:^(BOOL success, IQFeedbacksHolder * holder, NSData *responseData, NSError *error) {
                                             if(completion) {
                                                 completion(error);
                                             }
                                         }];
}

- (void)feedbacksUpdatesAfterDate:(NSDate*)lastUpdatedDate page:(NSNumber*)page completion:(void (^)(NSError * error))completion {
    [[IQService sharedService] feedbacksUpdatedAfter:lastUpdatedDate
                                                page:page
                                                 per:@(_portionLenght)
                                              search:self.search
                                             handler:^(BOOL success, IQFeedbacksHolder * holder, NSData *responseData, NSError *error) {
                                                 if(success && holder.currentPage < holder.totalPages) {
                                                     [self feedbacksUpdatesAfterDate:lastUpdatedDate
                                                                                page:@([page integerValue] + 1)
                                                                          completion:completion];
                                                 }
                                                 else if(completion) {
                                                     completion(error);
                                                 }
                                             }];
}

- (void)feedbacksUpdatesAfterDateWithCompletion:(void (^)(NSError * error))completion {
    NSDate * lastUpdatedDate = [self feedbackLastChangedDate];
    [self feedbacksUpdatesAfterDate:lastUpdatedDate
                               page:@(1)
                         completion:completion];
}

/**
 *  Last feedback id by max/min sort field
 *
 *  @param top If top return max sort field
 *
 *  @return Feedback id
 */
- (NSNumber*)lastFeedbackIdFromTop:(BOOL)top {
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:self.entityName];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"feedbackId" ascending:top]];
    [fetchRequest setPropertiesToFetch:@[@"feedbackId"]];
    [fetchRequest setResultType:NSDictionaryResultType];
    fetchRequest.fetchLimit = 1;
    
    NSError *error = nil;
    
    NSArray *objects = [[IQService sharedService].context executeFetchRequest:fetchRequest error:&error];
    if ([objects count] > 0) {
        return [[objects objectAtIndex:0] valueForKey:@"feedbackId"];
    }
    return nil;
}

- (NSDate*)feedbackLastChangedDate {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:self.entityName];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updatedDate" ascending:NO]];
    fetchRequest.fetchLimit = 1;
    
    NSError *error = nil;
    
    NSArray *objects = [[IQService sharedService].context executeFetchRequest:fetchRequest error:&error];
    if ([objects count] > 0) {
        IQManagedFeedback * feedback = [objects objectAtIndex:0];
        return feedback.createdDate;
    }
    return nil;
}

- (void)applicationWillEnterForeground {
    if ([IQSession defaultSession]) {
        [self feedbacksUpdatesAfterDateWithCompletion:nil];
    }
}

@end
