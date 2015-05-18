//
//  TCommentsController.m
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <Reachability/Reachability.h>

#import "TCommentsController.h"
#import "IQService+Messages.h"
#import "UIViewController+ScreenActivityIndicator.h"
#import "IQTask.h"
#import "IQBadgeIndicatorView.h"
#import "UITabBarItem+CustomBadgeView.h"
#import "TaskPolicyInspector.h"
#import "IQService+Tasks.h"
#import "TChangesCounter.h"
#import "IQNotificationCenter.h"
#import "NSManagedObject+ActiveRecord.h"
#import "IQDiscussion.h"

@interface TCommentsController () {
    __weak id _notfObserver;
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
        
        IQBadgeIndicatorView * badgeView = [[IQBadgeIndicatorView alloc] init];
        badgeView.badgeColor = [UIColor colorWithHexInt:0xe74545];
        badgeView.strokeBadgeColor = [UIColor whiteColor];
        badgeView.frame = CGRectMake(0, 0, 9.0f, 9.0f);
        
        self.tabBarItem.customBadgeView = badgeView;
        self.tabBarItem.badgeOrigin = CGPointMake(8.0f, 10.5f);

        [self resubscribeToIQNotifications];
    }
    return self;
}

- (void)setBadgeValue:(NSNumber *)badgeValue {
    if(!self.resetReadFlagAutomatically) {
        self.tabBarItem.badgeValue = BadgTextFromInteger([badgeValue integerValue]);
    }
}

- (NSNumber*)badgeValue {
    return @([self.tabBarItem.badgeValue integerValue]);
}

- (void)setDiscussionId:(NSNumber*)discussionId {
    if (discussionId && ![_discussionId isEqualToNumber:discussionId]) {
        _discussionId = discussionId;
        self.model = nil; //if discussion id changed remove old model
        [self createModelIfNeed];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.noDataLabel setText:NSLocalizedString(@"No comments", nil)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    self.resetReadFlagAutomatically = YES;
    [self resetReadFlag];
    [self updateNoDataLabelVisibility];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];

    self.resetReadFlagAutomatically = NO;
}

#pragma mark - Reachability

- (void)startReachabilityCheck {
    // we probably have no internet connection, so lets check with Reachability
    NSURL * serviceUrl = [NSURL URLWithString:[IQService sharedService].serviceUrl];
    Reachability *reachability = [Reachability reachabilityWithHostname:serviceUrl.host];
    
    if (![reachability isReachable]) {
        [reachability setReachableBlock:^(Reachability *reachability) {
            if ([reachability isReachable]) {
                DNSLog(@"Internet is now reachable");
                [reachability stopNotifier];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self createModelIfNeed];
                });
            }
        }];
        
        [reachability startNotifier];
    }
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
                                                    self.tabBarItem.badgeValue = BadgTextFromInteger(0);
                                                }
                                            }];
}

- (NSString*)category {
    return @"comments";
}

- (void)applicationWillEnterForeground {
    if (self.resetReadFlagAutomatically) {
        [self resetReadFlag];
    }
}

- (void)createModelIfNeed {
    if (!self.model) {
        [[IQService sharedService] discussionWithId:self.discussionId
                                            handler:^(BOOL success, IQDiscussion * discussion, NSData *responseData, NSError *error) {
                                                if(!discussion) {
                                                    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"discussionId == %@", self.discussionId];
                                                    discussion = [IQDiscussion objectWithPredicate:predicate
                                                                                         inContext:[IQService sharedService].context];
                                                }
                                                
                                                if (discussion) {
                                                    CommentsModel * model = [[CommentsModel alloc] initWithDiscussion:discussion];
                                                    self.model = model;
                                                    [self.model reloadModelWithCompletion:^(NSError *error) {
                                                        if(!error) {
                                                            [self.tableView reloadData];
                                                            [self scrollToBottomAnimated:NO delay:0.0f];
                                                            [self.tableView setHidden:NO];
                                                            [self markVisibleItemsAsReaded];
                                                        }
                                                        
                                                        self.needFullReload = NO;
                                                    }];
                                                    [self.tableView reloadData];
                                                    [self updateNoDataLabelVisibility];
                                                }
                                                else {
                                                    [self hideActivityIndicator];

                                                    if(error.code == kCFURLErrorNotConnectedToInternet) {
                                                        [self startReachabilityCheck];
                                                    }
                                                }
                                            }];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unsubscribeFromIQNotifications];
}

@end
