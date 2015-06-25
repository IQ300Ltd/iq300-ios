//
//  FeedbacksController.m
//  IQ300
//
//  Created by Tayphoon on 23.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "FeedbacksController.h"
#import "CreateFeedbackController.h"
#import "UIScrollView+PullToRefreshInsert.h"

@interface FeedbacksController ()

@end

@implementation FeedbacksController

@dynamic model;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.needFullReload = YES;
        
        self.model = [[FeedbacksModel alloc] init];
        
        self.title = NSLocalizedString(@"Feedback", nil);
    }
    
    return self;
}

- (BOOL)isLeftMenuEnabled {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] init];

    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;

    __weak typeof(self) weakSelf = self;
    [self.tableView
     insertPullToRefreshWithActionHandler:^{
         [weakSelf.model updateModelWithCompletion:^(NSError *error) {
             [[weakSelf.tableView pullToRefreshForPosition:SVPullToRefreshPositionTop] stopAnimating];
         }];
     }
     position:SVPullToRefreshPositionTop];
    
    [self.tableView
     insertPullToRefreshWithActionHandler:^{
         [weakSelf.model loadNextPartWithCompletion:^(NSError *error) {
             [[weakSelf.tableView pullToRefreshForPosition:SVPullToRefreshPositionBottom] stopAnimating];
         }];
     }
     position:SVPullToRefreshPositionBottom];
    
    [self.noDataLabel setText:NSLocalizedString(@"No feedbacks", nil)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"createNewMessage.png"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(createNewAction:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

#pragma mark - Private methods

- (void)createNewAction:(id)sender {
    CreateFeedbackModel * model = [[CreateFeedbackModel alloc] init];
    CreateFeedbackController * controller = [[CreateFeedbackController alloc] init];
    controller.model = model;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)backButtonAction:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
