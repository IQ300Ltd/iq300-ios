//
//  TasksFilterModel.h
//  IQ300
//
//  Created by Tayphoon on 26.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@protocol TaskFilterItem;

@interface TasksFilterModel : NSObject <IQTableModel>

@property (nonatomic, strong) NSString * sortField;
@property (nonatomic, strong) NSString * statusFilter;
@property (nonatomic, strong) NSNumber * communityId;
@property (nonatomic, assign, getter=isAscending) BOOL ascending;

@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

- (id<TaskFilterItem>)itemAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)canExpandSection:(NSInteger)section;

- (BOOL)isSortActionAvailableAtSection:(NSInteger)section;
- (void)setAscendingSortOrder:(BOOL)ascending forSection:(NSInteger)section;
- (BOOL)isSortOrderAscendingForSection:(NSInteger)section;

- (BOOL)isItemSellectedAtIndexPath:(NSIndexPath *)indexPath;
- (void)makeItemAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected;
- (NSArray*)selectedIndexPathsForSection:(NSInteger)section;

- (void)updateFilterParameters;

@end
