//
//  IQFeedbackController.m
//  IQ300
//
//  Created by Tayphoon on 30.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "FeedbackInfoController.h"
#import "FeedbackView.h"
#import "IQBadgeIndicatorView.h"
#import "UITabBarItem+CustomBadgeView.h"
#import "IQManagedFeedback.h"
#import "IQAttachment.h"
#import "PhotoViewController.h"
#import "UIViewController+ScreenActivityIndicator.h"
#import "DownloadManager.h"
#import "IQService+Feedback.h"
#import "IQActivityViewController.h"
#import "SharingAttachment.h"

@interface FeedbackInfoController() <IQActivityViewControllerDelegate> {
    FeedbackView * _feedbackView;
    UIDocumentInteractionController * _documentController;
#ifdef IPAD
    UIPopoverController *_popoverController;
#endif
}

@end

@implementation FeedbackInfoController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Feedback", nil);

        UIImage * barImage = [[UIImage imageNamed:@"task_info_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        float imageOffset = 6;
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:barImage selectedImage:barImage];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0, -imageOffset, 0);
        
        IQBadgeIndicatorView * badgeView = [[IQBadgeIndicatorView alloc] init];
        badgeView.badgeColor = [UIColor colorWithHexInt:0xe74545];
        badgeView.strokeBadgeColor = [UIColor whiteColor];
        badgeView.frame = CGRectMake(0, 0, 9.0f, 9.0f);
        
        self.tabBarItem.customBadgeView = badgeView;
        self.tabBarItem.badgeOrigin = CGPointMake(6.5f, 10.5f);
    }
    return self;
}

- (void)loadView {
    UIScrollView * scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = [UIColor whiteColor];
    _feedbackView = [[FeedbackView alloc] init];
    [scrollView addSubview:_feedbackView];
    self.view = scrollView;
}

- (void)setFeedback:(IQManagedFeedback *)feedback {
    _feedback = feedback;
    if (self.isViewLoaded) {
        [self updateViewWithFeedback:feedback];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateViewWithFeedback:self.feedback];
    
    NSInteger buttonIndex = 0;
    for (UIButton * attachButton in _feedbackView.attachButtons) {
        [attachButton addTarget:self
                         action:@selector(attachViewButtonAction:)
               forControlEvents:UIControlEventTouchUpInside];
        [attachButton setTag:buttonIndex];
        buttonIndex ++;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = [FeedbackView heightForFeedback:_feedback
                                               width:self.view.bounds.size.width];
    height = MAX(height, self.view.bounds.size.height);
    _feedbackView.frame = CGRectMake(0.0f, 0.0f, width, height);
    [((UIScrollView*)self.view) setContentSize:CGSizeMake(width, height)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [self updateFeedback];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

#pragma mark - Private methods

- (void)updateViewWithFeedback:(IQManagedFeedback*)feedback {
    if (feedback) {
        [_feedbackView updateViewWithFeedback:feedback];
    }
}

- (void)attachViewButtonAction:(UIButton*)sender {
    IQAttachment * attachment = [_feedback.attachments objectAtIndex:sender.tag];
    
    CGRect rectForAppearing = [sender.superview convertRect:sender.frame toView:self.view];
    if([attachment.contentType rangeOfString:@"image"].location != NSNotFound &&
       [attachment.originalURL length] > 0) {
        PhotoViewController * controller = [[PhotoViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        controller.imageURL = [NSURL URLWithString:attachment.originalURL];
        controller.fileName = attachment.displayName;
        controller.contentType = attachment.contentType;
        controller.previewURL = [NSURL URLWithString:attachment.previewURL];
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if ([attachment.localURL length] > 0) {
        [self showActivityViewControllerAttachment:attachment fromRect:rectForAppearing];
    }
    else {
        [self showActivityIndicator];
        [[DownloadManager sharedManager] downloadDataFromURL:attachment.originalURL
                                                    MIMEType:attachment.contentType
                                                     success:^(NSOperation *operation, NSURL * storedURL, NSData *responseData) {
                                                         attachment.localURL = storedURL.path;
                                                         
                                                         NSError *saveError = nil;
                                                         if(![attachment.managedObjectContext saveToPersistentStore:&saveError] ) {
                                                             NSLog(@"Save attachment error: %@", saveError);
                                                         }
                                                         
                                                         [self showActivityViewControllerAttachment:attachment fromRect:rectForAppearing];
                                                     }
                                                     failure:^(NSOperation *operation, NSError *error) {
                                                         [self hideActivityIndicator];
                                                     }];
    }
}

- (void)showActivityViewControllerAttachment:(IQAttachment *)attachment fromRect:(CGRect)rect {
    [self hideActivityIndicator];
    
    IQActivityViewController *controller = [[IQActivityViewController alloc] initWithAttachment:[[SharingAttachment alloc] initWithPath:attachment.localURL
                                                                                                                            displayName:attachment.displayName
                                                                                                                            contentType:attachment.contentType]];
    if (![attachment.contentType hasPrefix:@"video"]) {
        controller.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll];
    }
    controller.delegate = self;
    controller.documentInteractionControllerRect = rect;
    
#ifdef IPAD
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIPopoverPresentationController *popoverController = [controller popoverPresentationController];
        popoverController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        popoverController.sourceView = self.view;
        popoverController.sourceRect = rect;
        
        [self presentViewController:controller animated:YES completion:nil];
    }
    else {
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        _popoverController.delegate = (id<UIPopoverControllerDelegate>)self;
        [_popoverController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
#else
    [self presentViewController:controller animated:YES completion:nil];
#endif
    
}

#ifdef IPAD
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    _popoverController = nil;
}
#endif


- (void)applicationWillEnterForeground {
    [self updateFeedback];
}

- (void)updateFeedback {
    if (self.feedback.feedbackId) {
        [[IQService sharedService] feedbackWithId:self.feedback.feedbackId
                                          handler:^(BOOL success, IQManagedFeedback * feedback, NSData *responseData, NSError *error) {
                                              if (success && feedback) {
                                                  self.feedback = feedback;
                                                  [self.view setNeedsLayout];
                                              }
                                          }];
    }
}

#pragma mark - IQActivityViewControllerDelegate

- (BOOL)willShowDocumentInteractionController {
    return YES;
}
- (void)shouldShowDocumentInteractionController:(UIDocumentInteractionController * _Nonnull)controller fromRect:(CGRect)rect{
    _documentController = controller;
    [_documentController setDelegate:(id<UIDocumentInteractionControllerDelegate>)self];
    if(![_documentController presentOpenInMenuFromRect:rect inView:self.view animated:YES]) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                           message:NSLocalizedString(@"You do not have an application installed to view files of this type", nil)
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:nil];
    }
}

#pragma mark - UIDocumentInteractionController Delegate Methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return  self;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    _documentController = nil;
}


@end
