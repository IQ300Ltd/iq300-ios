//
//  TasksModel.h
//  IQ300
//
//  Created by Tayphoon on 19.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@class IQCounters;

@interface TasksModel : NSObject<IQTableModel>

@property (nonatomic, assign) NSInteger taskaFilter;
@property (nonatomic, weak) id<IQTableModelDelegate> delegate;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, strong) NSString * filter;

/**
 UpdateModelWithCompletion. Load new data.
 
 @param completion handler.
 
 */
- (void)updateModelWithCompletion:(void (^)(NSError * error))completion;

/**
 Load data from history.
 
 @param completion handler.
 
 */
- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion;

- (void)updateCountersWithCompletion:(void (^)(IQCounters * counter, NSError * error))completion;

@end
