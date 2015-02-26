//
//  TasksFilterModel.h
//  IQ300
//
//  Created by Tayphoon on 26.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@interface TasksFilterModel : NSObject <IQTableModel>

@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

- (BOOL)canExpandSection:(NSInteger)section;

- (BOOL)isItemSellectedAtIndexPath:(NSIndexPath *)indexPath;
- (void)makeItemAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected;

@end
