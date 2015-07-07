//
//  FeedbacksView.h
//  IQ300
//
//  Created by Tayphoon on 01.07.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "ExTextField.h"

@interface FeedbacksView : UIView

@property (nonatomic, strong) ExTextField * searchBar;
@property (nonatomic, readonly) UIButton * clearTextFieldButton;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, assign) CGFloat tableBottomMargin;

@end
