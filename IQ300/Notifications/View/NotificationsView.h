//
//  NotificationsView.h
//  IQ300
//
//  Created by Tayphoon on 14.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExTextField.h"

@interface NotificationsView : UIView

@property (nonatomic, strong) ExTextField * searchBar;
@property (nonatomic, strong) UITableView * tableView;

@end
