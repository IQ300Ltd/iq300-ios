//
//  TasksView.h
//  IQ300
//
//  Created by Tayphoon on 19.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottomLineView.h"

extern NSString * const NoTasksFound;

@interface TasksView : UIView

@property (nonatomic, readonly) BottomLineView * headerView;
@property (nonatomic, readonly) UIButton * backButton;
@property (nonatomic, readonly) UILabel * titleLabel;
@property (nonatomic, readonly) UITableView * tableView;
@property (nonatomic, readonly) UILabel * noDataLabel;

@end
