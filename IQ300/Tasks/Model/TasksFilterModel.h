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

@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

- (id<TaskFilterItem>)itemAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)canExpandSection:(NSInteger)section;

- (BOOL)isSortActionAvailableAtSection:(NSInteger)section;
- (void)setAscendingSortOrder:(BOOL)ascending forSection:(NSInteger)section;

- (BOOL)isItemSellectedAtIndexPath:(NSIndexPath *)indexPath;
- (void)makeItemAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected;
- (NSArray*)selectedIndexPathsForSection:(NSInteger)section;

@end
