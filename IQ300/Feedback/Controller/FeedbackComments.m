//
//  FeedbackComments.m
//  IQ300
//
//  Created by Tayphoon on 30.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <Reachability/Reachability.h>

#import "FeedbackComments.h"
#import "IQService+Messages.h"
#import "IQDiscussion.h"
#import "NSManagedObject+ActiveRecord.h"
#import "UIViewController+ScreenActivityIndicator.h"
#import "IQBadgeIndicatorView.h"
#import "UITabBarItem+CustomBadgeView.h"
#import "TaskTabController.h"

@implementation FeedbackComments

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
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.noDataLabel setText:NSLocalizedString(@"No comments", nil)];
}

- (void)setDiscussionId:(NSNumber*)discussionId {
    if (discussionId && ![_discussionId isEqualToNumber:discussionId]) {
        _discussionId = discussionId;
        self.model = nil; //if discussion id changed remove old model
        [self createModelIfNeed];
    }
}

#pragma mark - Reachability

- (void)startReachabilityCheck {
    // we probably have no internet connection, so lets check with Reachability
    NSURL * serviceUrl = [NSURL URLWithString:[IQService sharedService].serviceUrl];
    Reachability *reachability = [Reachability reachabilityWithHostname:serviceUrl.host];
    
    if (![reachability isReachable]) {
        [reachability setReachableBlock:^(Reachability *reachability) {
            if ([reachability isReachable]) {
                NSLog(@"Internet is now reachable");
                [reachability stopNotifier];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self createModelIfNeed];
                });
            }
        }];
        
        [reachability startNotifier];
    }
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([URL.scheme isEqualToString:APP_URL_SCHEME] &&
        [URL.host isEqualToString:@"tasks"]) {
        NSInteger taskId = [URL.lastPathComponent integerValue];
        if (taskId > 0 && taskId) {
            [self openTaskControllerForTaskId:@(taskId)];
        }
    }
    else {
        NSString * unescapedString = [[URL absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        unescapedString = [unescapedString stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
        NSString * encodeURL = [unescapedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:encodeURL]];
    }
    
    return NO;
}

#pragma mark - Private methods

- (void)openTaskControllerForTaskId:(NSNumber*)taskId {
    [TaskTabController taskTabControllerForTaskWithId:taskId
                                           completion:^(TaskTabController * controller, NSError *error) {
                                               if (controller) {
                                                   [GAIService sendEventForCategory:GAITasksListEventCategory
                                                                             action:GAIOpenTaskEventAction];
                                                   
                                                   controller.hidesBottomBarWhenPushed = YES;
                                                   [self.navigationController pushViewController:controller animated:YES];
                                               }
                                               else {
                                                   [self proccessServiceError:error];
                                               }
                                           }];
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
                                                            [self updateNoDataLabelVisibility];
                                                        }
                                                        
                                                        self.needFullReload = NO;
                                                    }];
                                                    [self.tableView reloadData];
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

@end
