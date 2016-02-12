//
//  IQTableBaseController.h
//  IQ300
//
//  Created by Tayphoon on 20.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQTableModel.h"
#import "UIViewController+ErrorHandle.h"

@interface IQTableBaseController : UIViewController<UITableViewDataSource, UITableViewDelegate, IQTableModelDelegate>

@property (nonatomic, readonly) UITableView * tableView;
@property (nonatomic, strong) UILabel * noDataLabel;
@property (nonatomic, strong) id<IQTableModel> model;
@property (nonatomic, assign) BOOL needFullReload;
@property (nonatomic, readonly) BOOL isActivityIndicatorShown;

- (void)reloadDataWithCompletion:(void (^)(NSError *error))completion;

- (void)scrollToBottomAnimated:(BOOL)animated delay:(CGFloat)delay;
- (void)scrollToTopAnimated:(BOOL)animated delay:(CGFloat)delay;

- (void)updateNoDataLabelVisibility;

- (void)showActivityIndicatorAnimated:(BOOL)animated completion:(void (^)(void))completion;

- (void)hideActivityIndicatorAnimated:(BOOL)animated completion:(void (^)(void))completion;

@end
