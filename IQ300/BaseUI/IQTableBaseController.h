//
//  IQTableBaseController.h
//  IQ300
//
//  Created by Tayphoon on 20.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQTableModel.h"

@interface IQTableBaseController : UIViewController<UITableViewDataSource, UITableViewDelegate, IQTableModelDelegate>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) id<IQTableModel> model;

- (void)reloadDataWithCompletion:(void (^)())completion;

@end
