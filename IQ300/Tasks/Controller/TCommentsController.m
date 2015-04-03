//
//  TCommentsController.m
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TCommentsController.h"
#import "IQService+Messages.h"
#import "UIViewController+ScreenActivityIndicator.h"
#import "IQTask.h"
#import "IQBadgeView.h"
#import "UITabBarItem+CustomBadgeView.h"
#import "TaskPolicyInspector.h"
#import "IQService+Tasks.h"
#import "TChangesCounter.h"
#import "IQNotificationCenter.h"

@interface TCommentsController () {
    __weak id _notfObserver;
    UILabel * _noDataLabel;
}

@property (nonatomic, assign) BOOL resetReadFlagAutomatically;

@end

@implementation TCommentsController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Discussion", nil);

        UIImage * barImage = [[UIImage imageNamed:@"task_comments_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        float imageOffset = 6;
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:barImage selectedImage:barImage];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0, -imageOffset, 0);
        
        IQBadgeStyle * style = [IQBadgeStyle defaultStyle];
        style.badgeTextColor = [UIColor whiteColor];
        style.badgeFrameColor = [UIColor whiteColor];
        style.badgeInsetColor = [UIColor colorWithHexInt:0x338cae];
        style.badgeFrame = YES;
        
        IQBadgeView * badgeView = [IQBadgeView customBadgeWithString:nil withStyle:style];
        badgeView.badgeMinSize = 15;
        badgeView.frameLineHeight = 1.0f;
        badgeView.badgeTextFont = [UIFont fontWithName:IQ_HELVETICA size:9];
        
        self.tabBarItem.customBadgeView = badgeView;
        self.tabBarItem.badgeOrigin = CGPointMake(38.5f, 3.5f);

        [self resubscribeToIQNotifications];
    }
    return self;
}

- (void)setBadgeValue:(NSNumber *)badgeValue {
    self.tabBarItem.badgeValue = BadgTextFromInteger([badgeValue integerValue]);
}

- (NSNumber*)badgeValue {
    return @([self.tabBarItem.badgeValue integerValue]);
}

- (void)setDiscussionId:(NSNumber*)discussionId {
    if (discussionId && ![_discussionId isEqualToNumber:discussionId]) {
        _discussionId = discussionId;
        
        [[IQService sharedService] discussionWithId:discussionId
                                            handler:^(BOOL success, IQDiscussion * discussion, NSData *responseData, NSError *error) {
                                                if(success) {
                                                    CommentsModel * model = [[CommentsModel alloc] initWithDiscussion:discussion];
                                                    self.model = model;
                                                    [self.model reloadModelWithCompletion:^(NSError *error) {
                                                        if(!error) {
                                                            [self.tableView reloadData];
                                                            [self scrollToBottomAnimated:NO delay:0.0f];
                                                            [self.tableView setHidden:NO];
                                                        }
                                                        
                                                        self.needFullReload = NO;
                                                        [self hideActivityIndicator];
                                                    }];
                                                    [self.tableView reloadData];
                                                }
                                            }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _noDataLabel = [[UILabel alloc] init];
    [_noDataLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:15]];
    [_noDataLabel setTextColor:[UIColor colorWithHexInt:0xb3b3b3]];
    _noDataLabel.textAlignment = NSTextAlignmentCenter;
    _noDataLabel.backgroundColor = [UIColor clearColor];
    _noDataLabel.numberOfLines = 0;
    _noDataLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [_noDataLabel setHidden:YES];
    [_noDataLabel setText:NSLocalizedString(@"No comments", nil)];
    
    if (self.tableView) {
        [self.view insertSubview:_noDataLabel belowSubview:self.tableView];
    }
    else {
        [self.view addSubview:_noDataLabel];
    }
    
    [self updateNoDataLabelVisibility];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
    
    self.resetReadFlagAutomatically = YES;
    [self resetReadFlag];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.resetReadFlagAutomatically = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _noDataLabel.frame = self.tableView.frame;
}

#pragma mark - IQTableModel Delegate

- (void)modelDidChangeContent:(id<IQTableModel>)model {
    [super modelDidChangeContent:model];
    [self updateNoDataLabelVisibility];
}

- (void)modelDidChanged:(id<IQTableModel>)model {
    [super modelDidChanged:model];
    [self updateNoDataLabelVisibility];
}

#pragma mark - Private methods

- (void)resubscribeToIQNotifications {
    [self unsubscribeFromIQNotifications];
    
    __weak typeof(self) weakSelf = self;
    void (^block)(IQCNotification * notf) = ^(IQCNotification * notf) {
        NSArray * tasks = notf.userInfo[IQNotificationDataKey];
        NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"task_id == %@", weakSelf.taskId];
        NSDictionary * curTask = [[tasks filteredArrayUsingPredicate:filterPredicate] lastObject];

        if(curTask) {
            NSNumber * count = curTask[@"counter"];
            if(![weakSelf.badgeValue isEqualToNumber:count]) {
                if (weakSelf.resetReadFlagAutomatically) {
                    [weakSelf resetReadFlag];
                }
                else {
                    weakSelf.badgeValue = count;
                }
            }
        }
    };
    _notfObserver = [[IQNotificationCenter defaultCenter] addObserverForName:IQTaskCommentsDidChangedNotification
                                                                       queue:nil
                                                                  usingBlock:block];
}

- (void)unsubscribeFromIQNotifications {
    if(_notfObserver) {
        [[IQNotificationCenter defaultCenter] removeObserver:_notfObserver];
    }
}

- (void)resetReadFlag {
    [[IQService sharedService] markCategoryAsReaded:[self category]
                                             taskId:self.taskId
                                            handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                if (success) {
                                                    self.badgeValue = @(0);
                                                }
                                            }];
}

- (NSString*)category {
    return @"comments";
}

- (void)updateNoDataLabelVisibility {
    [_noDataLabel setHidden:([self.model numberOfItemsInSection:0] > 0)];
}

- (void)dealloc {
    [self unsubscribeFromIQNotifications];
}

@end
