//
//  TasksModel.h
//  IQ300
//
//  Created by Tayphoon on 19.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@class TasksMenuCounters;

@interface TasksModel : NSObject<IQTableModel>

@property (nonatomic, assign) NSInteger taskaFilter;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, strong) NSString * search;
@property (nonatomic, strong) NSString * folder;
@property (nonatomic, strong) NSString * sortField;
@property (nonatomic, strong) NSString * statusFilter;
@property (nonatomic, strong) NSNumber * communityId;
@property (nonatomic, strong) NSString * communityDescription;
@property (nonatomic, assign, getter=isAscending) BOOL ascending;

@property (nonatomic, strong) TasksMenuCounters * counters;

@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion;

/**
 Load data updates.
 
 @param completion handler.
 
 */
- (void)updateModelWithCompletion:(void (^)(NSError * error))completion;

/**
 Load data from history.
 
 @param completion handler.
 
 */
- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion;

- (void)updateCountersWithCompletion:(void (^)(TasksMenuCounters * counters, NSError * error))completion;

@end
