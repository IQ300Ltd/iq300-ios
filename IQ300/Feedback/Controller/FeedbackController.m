//
//  FeedbackController.m
//  IQ300
//
//  Created by Tayphoon on 30.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "FeedbackController.h"
#import "FeedbackInfoController.h"
#import "FeedbackComments.h"
#import "IQManagedFeedback.h"

@interface FeedbackController() <IQTabBarControllerDelegate> {
    CGFloat _tabbarWidth;
}

@end

@implementation FeedbackController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Feedback", nil);

        self.delegate = self;
        [self setViewControllers:@[[[FeedbackInfoController alloc] init],
                                   [[FeedbackComments alloc] init]
                                   ]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.separatorHeight = 0.5f;
    self.separatorColor = IQ_SEPARATOR_LINE_LIGHT_COLOR;
    self.separatorHidden = NO;
    
    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    self.tabBar.backgroundImage = [UIImage imageNamed:@"tabbar_background.png"];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (_tabbarWidth != self.tabBar.frame.size.width) {
        _tabbarWidth = self.tabBar.frame.size.width;
        CGSize tabItemSize = CGSizeMake(_tabbarWidth / [self.viewControllers count], self.tabBar.frame.size.height);
        self.tabBar.selectionIndicatorImage = [UIImage imageWithColor:IQ_BACKGROUND_P2_COLOR
                                                                 size:tabItemSize];
    }
}

- (void)setFeedback:(IQManagedFeedback *)feedback {
    _feedback = feedback;
    [self updateControllerByFeedback:feedback];
}

#pragma mark - IQTabBarController Delegate

- (void)tabBarController:(IQTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    self.title = viewController.title;
}

#pragma mark - Private methods

- (void)updateControllerByFeedback:(IQManagedFeedback*)feedback {
    FeedbackInfoController * infoController = self.viewControllers[0];
    [infoController setFeedback:feedback];
    
    FeedbackComments * commentsController = self.viewControllers[1];
    [commentsController setDiscussionId:feedback.discussionId];
}

- (BOOL)isLeftMenuEnabled {
    return NO;
}

- (void)backButtonAction:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
