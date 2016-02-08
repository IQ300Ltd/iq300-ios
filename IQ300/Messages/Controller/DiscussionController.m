//
//  DiscussionController.m
//  IQ300
//
//  Created by Tayphoon on 04.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <MMDrawerController/UIViewController+MMDrawerController.h>
#import <CTAssetsPickerController/CTAssetsPickerController.h>
#import <RestKit/CoreData/NSManagedObjectContext+RKAdditions.h>

#import "UIViewController+LeftMenu.h"
#import "IQSession.h"

#import "DiscussionController.h"
#import "DiscussionView.h"
#import "CommentCell.h"
#import "IQComment.h"
#import "DispatchAfterExecution.h"
#import "ALAsset+Extension.h"
#import "IQConversation.h"
#import "PhotoViewController.h"
#import "DownloadManager.h"
#import "UIViewController+ScreenActivityIndicator.h"
#import "CSectionHeaderView.h"
#import "IQDrawerController.h"
#import "UIImage+Extensions.h"
#import "UIActionSheet+Blocks.h"
#import "UIScrollView+PullToRefreshInsert.h"
#import "ContactPickerController.h"
#import "TaskTabController.h"
#import "ConferenceInfoController.h"
#import "IQService.h"
#import "IQService+Messages.h"
#import "IQActivityViewController.h"

#define SECTION_HEIGHT 12

@interface DiscussionController() <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, DiscussionModelDelegate, IQActivityViewControllerDelegate> {
    DiscussionView * _mainView;
    BOOL _enterCommentProcessing;
    ALAsset * _attachmentAsset;
    UIImage * _attachmentImage;
    UIDocumentInteractionController * _documentController;
    UISwipeGestureRecognizer * _tableGesture;
    CGPoint _tableContentOffset;
    BOOL _blockUpdation;
#ifdef IPAD
    UIPopoverController *_popoverController;
#endif
}

@end

@implementation DiscussionController

@dynamic model;

- (UITableView*)tableView {
    return _mainView.tableView;
}

- (void)setModel:(id<IQTableModel>)model {
    if (self.model) {
        self.model.delegate = nil;
        [self.model setSubscribedToNotifications:NO];
        [self.model clearModelData];
    }
    
    [super setModel:model];
}

- (void)loadView {
    _mainView = [[DiscussionView alloc] init];
    self.view = _mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _enterCommentProcessing = NO;
    self.needFullReload = YES;
    
    _tableGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(handleSwipe:)];
    _tableGesture.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    _tableGesture.delegate = (id<UIGestureRecognizerDelegate>)self;

    [self.tableView addGestureRecognizer:_tableGesture];
    
    [self setActivityIndicatorBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.3f]];
    [self setActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [_mainView.inputView.sendButton setEnabled:NO];

    [_mainView.inputView.sendButton addTarget:self
                                       action:@selector(sendButtonAction:)
                             forControlEvents:UIControlEventTouchUpInside];

    [_mainView.inputView.attachButton addTarget:self
                                       action:@selector(attachButtonAction:)
                             forControlEvents:UIControlEventTouchUpInside];

    __weak typeof(self) weakSelf = self;
    [self.tableView
     insertPullToRefreshWithActionHandler:^{
         void (^completiation)(NSError * error) = ^(NSError * error) {
             if (error) {
                 NSInteger httpStatusCode = [error.userInfo[TCHttpStatusCodeKey] integerValue];
                 if (httpStatusCode == 403) {
                     [weakSelf proccessUserRemovedFromConversation];
                 }
                 else {
                     [self proccessServiceError:error];
                 }
             }
             else {
                 [self proccessUserAddToConversation];
             }
             
             [[weakSelf.tableView pullToRefreshForPosition:SVPullToRefreshPositionTop] stopAnimating];
         };
         [weakSelf.model loadNextPartWithCompletion:completiation];
     }
     position:SVPullToRefreshPositionTop];
    
    [_mainView.inputView.commentTextView setDelegate:(id<UITextViewDelegate>)self];
    _mainView.tableView.hidden = YES;
    
    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    NSString *imageName = [self.model isDiscussionConference] ? @"edit_conference_icon.png" : @"add_user_icon.png";
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(rightBarButtonAction:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (BOOL)isLeftMenuEnabled {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.leftMenuController setModel:nil];
    [self.leftMenuController reloadMenuWithCompletion:nil];
    
    [self.model setSubscribedToNotifications:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(drawerDidShowNotification:)
                                                 name:IQDrawerDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateModel];
    [self updateTitle];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self hideActivityIndicator];
    
    [self.model setSubscribedToNotifications:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableView DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.model.cellWidth = tableView.frame.size.width;
    return [self.model heightForItemAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return SECTION_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CSectionHeaderView * sectionView = [[CSectionHeaderView alloc] init];
    sectionView.title = [self.model titleForSection:section];
    
    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell<IQCommentCell> * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    IQComment * comment = [self.model itemAtIndexPath:indexPath];
    cell.item = comment;

    cell.expandable = [self.model isCellExpandableAtIndexPath:indexPath];
    cell.expanded = [self.model isItemExpandedAtIndexPath:indexPath];
    cell.descriptionTextView.delegate = self;

    if(cell.expandable) {
        [cell.expandButton addTarget:self
                              action:@selector(expandButtonAction:)
                    forControlEvents:UIControlEventTouchUpInside];
    }
    
    NSInteger buttonIndex = 0;
    for (UIButton * attachButton in cell.attachButtons) {
        [attachButton addTarget:self
                         action:@selector(attachViewButtonAction:)
               forControlEvents:UIControlEventTouchUpInside];
        [attachButton setTag:buttonIndex];
        buttonIndex ++;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IQComment * comment = [self.model itemAtIndexPath:indexPath];
    if([comment.commentStatus integerValue] == IQCommentStatusSendError) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                           message:NSLocalizedString(@"Message has not been sent. Send again?", nil)
                 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                 otherButtonTitles:@[NSLocalizedString(@"OK", nil)]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if(buttonIndex == 1) {
                                  [self.model resendLocalComment:comment withCompletion:^(NSError *error) {
                                      if(!error) {
                                          [self.model deleteLocalComment:comment];
                                      }
                                      else {
                                          [self proccessServiceError:error];
                                      }
                                  }];
                              }
                          }];
    }
}

#pragma mark - DiscussionModelDelegate Delegate

- (void)model:(DiscussionModel *)model newComment:(IQComment*)comment {
    CGFloat bottomPosition = self.tableView.contentSize.height - self.tableView.bounds.size.height - 1.0f;
    BOOL isTableScrolledToBottom = (self.tableView.contentOffset.y >= bottomPosition);
    if(isTableScrolledToBottom) {
        [self scrollToBottomAnimated:YES delay:1.0f];
    }
}

- (void)modelDidChanged:(id<IQTableModel>)model {
    [super modelDidChanged:model];
    
    CGFloat bottomPosition = self.tableView.contentSize.height - self.tableView.bounds.size.height - 1.0f;
    BOOL isTableScrolledToBottom = (self.tableView.contentOffset.y >= bottomPosition);
    
    if(isTableScrolledToBottom) {
        [self scrollToBottomIfNeedAnimated:YES delay:1.0f];
    }
}

- (void)model:(DiscussionModel *)model conversationTitleDidChanged:(NSString *)newTitle {
    self.title = newTitle;
}

- (void)model:(DiscussionModel *)model didAddMemberWith:(NSNumber*)userId {
    if ([IQSession defaultSession].userId && [[IQSession defaultSession].userId isEqualToNumber:userId]) {
        [self proccessUserAddToConversation];
    }
}

- (void)model:(DiscussionModel *)model memberDidRemovedWithId:(NSNumber *)userId {
    if ([IQSession defaultSession].userId && [[IQSession defaultSession].userId isEqualToNumber:userId]) {
        [self proccessUserRemovedFromConversation];
    }
}

#pragma mark - Scroll Gesture Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return _enterCommentProcessing && gestureRecognizer.view == self.tableView;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)gestureRecognizer {
    [self.tableView setContentOffset:self.tableView.contentOffset animated:YES];
    [self.tableView setScrollEnabled:NO];
    [_mainView.inputView.commentTextView resignFirstResponder];
}

#pragma mark - Activity indicator overrides

- (void)showActivityIndicatorAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [self.tableView setPullToRefreshAtPosition:SVPullToRefreshPositionTop shown:NO];
    
    CGFloat bottomPosition = self.tableView.contentSize.height - self.tableView.bounds.size.height - 1.0f;
    BOOL isTableScrolledToBottom = (self.tableView.contentOffset.y >= bottomPosition);
    if (isTableScrolledToBottom) {
        _tableContentOffset = self.tableView.contentOffset;
    }
    
    [super showActivityIndicatorAnimated:YES completion:nil];
}

- (void)hideActivityIndicatorAnimated:(BOOL)animated completion:(void (^)(void))completion {
    if (!CGPointEqualToPoint(_tableContentOffset, CGPointZero)) {
        [self.tableView setContentOffset:_tableContentOffset animated:YES];
    }

    [super hideActivityIndicatorAnimated:YES completion:^{
        [self.tableView setPullToRefreshAtPosition:SVPullToRefreshPositionTop shown:YES];
        
        if (completion) {
            completion();
        }
    }];
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

- (BOOL)isTextValid:(NSString *)text {
    if (text == nil || [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        return NO;
    }
    
    return YES;
}

- (void)updateUserInteraction:(NSString *)text {
    BOOL isSendButtonEnabled = [self isTextValid:text] || _attachmentAsset || _attachmentImage;
    [_mainView.inputView.sendButton setEnabled:isSendButtonEnabled];
}

- (void)backButtonAction:(id)sender {
    [self.model unlockConversation];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBarButtonAction:(id)sender {
    if ([self.model isDiscussionConference]) {
        ConferenceInfoController *controller = [[ConferenceInfoController alloc] init];
        controller.model.conversation = self.model.discussion.conversation;
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else {
        ContactsModel * model = [[ContactsModel alloc] init];
        model.excludeUserIds = [self.model.discussion.users valueForKey:@"userId"];

        ContactPickerController * controller = [[ContactPickerController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        controller.model = model;
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)sendButtonAction:(UIButton*)sender {
    CGFloat bottomPosition = self.tableView.contentSize.height - self.tableView.bounds.size.height - 1.0f;
    BOOL isTableScrolledToBottom = (self.tableView.contentOffset.y >= bottomPosition);
    
    BOOL isTextValid = [self isTextValid:_mainView.inputView.commentTextView.text];
    if(isTextValid || (_attachmentAsset || _attachmentImage)) {
        [_mainView.inputView.sendButton setEnabled:NO];
        [_mainView.inputView.attachButton setEnabled:NO];
        [_mainView.inputView.commentTextView setEditable:NO];
        [_mainView.inputView.commentTextView resignFirstResponder];
        
        NSString * fileName = (_attachmentAsset != nil) ? [_attachmentAsset fileName] : @"IMG.png";
        NSString * mimeType = (_attachmentAsset != nil) ? [_attachmentAsset MIMEType] : @"image/png";
        id attachment = (_attachmentAsset != nil) ? _attachmentAsset : _attachmentImage;

        [self.model sendComment:_mainView.inputView.commentTextView.text
                     attachment:attachment
                       fileName:fileName
                       mimeType:mimeType
                 withCompletion:^(NSError *error) {
                     if(!error) {
                         _mainView.inputView.commentTextView.text = nil;
                         [_mainView.inputView.attachButton setImage:[UIImage imageNamed:ATTACHMENT_IMG]
                                                           forState:UIControlStateNormal];
                         _attachmentAsset = nil;
                         _attachmentImage = nil;
                         [_mainView setInputHeight:MIN_INPUT_VIEW_HEIGHT];
                     }
                     else {
                         [self proccessServiceError:error];
                     }
                     
                     [_mainView.inputView.commentTextView setEditable:YES];
                     [_mainView.inputView.attachButton setEnabled:YES];
                     if(isTableScrolledToBottom) {
                         [self scrollToBottomAnimated:YES delay:0.5f];
                     }
                 }];
    }
}

- (void)attachButtonAction:(UIButton*)sender {
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:NSLocalizedString(@"Take a picture", nil),
                                                                       NSLocalizedString(@"Photos", nil), nil];
    
    [actionSheet setDidDismissBlock:^(UIActionSheet * __nonnull actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                _tableContentOffset = self.tableView.contentOffset;
                
                UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
                [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
                [imagePicker setCameraDevice:UIImagePickerControllerCameraDeviceRear];
                [imagePicker setAllowsEditing:NO];
                [imagePicker setShowsCameraControls:YES];
                [imagePicker setDelegate:self];
                imagePicker.hidesBottomBarWhenPushed = YES;
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
            else {
                [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                                   message:NSLocalizedString(@"The camera is not available", nil)
                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                         otherButtonTitles:nil
                                  tapBlock:nil];
            }
        }
        else if (buttonIndex == 1) {
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            picker.assetsFilter = [ALAssetsFilter allAssets];
            picker.showsCancelButton = YES;
            picker.delegate = (id<CTAssetsPickerControllerDelegate>)self;
            picker.showsNumberOfAssets = NO;
            [self presentViewController:picker animated:YES completion:nil];
        }
    }];
    
    [actionSheet showInView:self.view];
}

- (void)attachViewButtonAction:(UIButton*)sender {
    UITableViewCell<IQCommentCell> * cell = [self cellForView:sender];
    
    if(!cell) {
        return;
    }
    
    IQComment * comment = cell.item;
    IQAttachment * attachment = [[comment.attachments allObjects] objectAtIndex:sender.tag];
    
    CGRect rectForAppearing = [sender.superview convertRect:sender.frame toView:self.view];
    if([attachment.contentType rangeOfString:@"image"].location != NSNotFound &&
       [attachment.originalURL length] > 0) {
        PhotoViewController * controller = [[PhotoViewController alloc] init];
        controller.imageURL = [NSURL URLWithString:attachment.originalURL];
        controller.fileName = attachment.displayName;
        controller.contentType = attachment.contentType;
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
                                                         NSString * message = IsNetworUnreachableError(error) ? NSLocalizedString(INTERNET_UNREACHABLE_MESSAGE, nil) :
                                                                                                                NSLocalizedString(@"File download failed", nil);
                                                         [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                                                                            message:message
                                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                                  otherButtonTitles:nil
                                                                           tapBlock:nil];

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

- (void)expandButtonAction:(UIButton*)sender {
    UITableViewCell<IQCommentCell> * cell = [self cellForView:sender];
    if(cell) {
        NSIndexPath * cellIndexPath = [self.tableView indexPathForCell:cell];
        BOOL isExpanded = [self.model isItemExpandedAtIndexPath:cellIndexPath];
        [self.model setItemExpanded:!isExpanded atIndexPath:cellIndexPath];
    }
}

- (void)updateModel {
    if([IQSession defaultSession] && self.model && !_blockUpdation) {
        [self showActivityIndicatorAnimated:YES completion:nil];
        
        [self.model updateModelWithCompletion:^(NSError *error) {
            if(!error) {
                [self proccessUserAddToConversation];
            }
            else {
                NSInteger httpStatusCode = [error.userInfo[TCHttpStatusCodeKey] integerValue];
                if (httpStatusCode == 403) {
                    [self proccessUserRemovedFromConversation];
                }
            }
            
            [self scrollToBottomIfNeedAnimated:NO delay:0];
            self.needFullReload = NO;
            
            [self updateNoDataLabelVisibility];
            dispatch_after_delay(0.5f, dispatch_get_main_queue(), ^{
                _mainView.tableView.hidden = NO;
                
                [self hideActivityIndicatorAnimated:YES completion:nil];
            });
        }];
    }
}

- (void)applicationWillEnterForeground {
    [self.model markDiscussionAsReadedWithCompletion:nil];
    [self checkConversationAvailable];
}

- (void)checkConversationAvailable {
    [[IQService sharedService] conversationWithId:self.model.discussion.conversation.conversationId
                                          handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                                              NSInteger httpStatusCode = [error.userInfo[TCHttpStatusCodeKey] integerValue];
                                              if (!success && httpStatusCode == 403) {
                                                  [self proccessUserRemovedFromConversation];
                                              }
                                              else {
                                                  [self proccessUserAddToConversation];
                                                  [self updateModel];
                                              }
                                          }];
}

#pragma mark - Keyboard Helpers

- (void)onKeyboardWillShow:(NSNotification *)notification {
   [self makeInputViewTransitionWithDownDirection:NO notification:notification];
    _enterCommentProcessing = YES;
}

- (void)onKeyboardWillHide:(NSNotification *)notification {
    _enterCommentProcessing = NO;
    [self makeInputViewTransitionWithDownDirection:YES notification:notification];
}

- (void)onKeyboardDidHide:(NSNotification*)notification {
    [self.tableView setScrollEnabled:YES];
}

- (void)makeInputViewTransitionWithDownDirection:(BOOL)down notification:(NSNotification *)notification {
    CGFloat bottomPosition = self.tableView.contentSize.height - self.tableView.bounds.size.height - 1.0f;
    BOOL isTableScrolledToBottom = (self.tableView.contentOffset.y >= bottomPosition);
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGFloat inset = MIN(keyboardRect.size.height, keyboardRect.size.width);
    [_mainView setInputOffset:down ? 0.0f : -inset];
    if(isTableScrolledToBottom) {
        [self scrollToBottomAnimated:NO delay:0.0f];
    }
    
    [UIView commitAnimations];
}

#pragma mark - PlaceholderTextViewDelegate Methods

- (void)textViewDidChange:(UITextView *)textView {
    CGFloat bottomPosition = self.tableView.contentSize.height - self.tableView.bounds.size.height - 1.0f;
    BOOL isTableScrolledToBottom = (self.tableView.contentOffset.y >= bottomPosition);

    [self updateUserInteraction:textView.text];
    [textView scrollRangeToVisible:textView.selectedRange];
    
    CGSize contentSize = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, FLT_MAX)];
    contentSize = CGSizeMake(contentSize.width,
                             contentSize.height + 5.0f);
    CGFloat messageTextViewHeight = MIN(MAX(contentSize.height + (textView.textContainerInset.top + textView.textContainerInset.bottom)*2.0, MIN_INPUT_VIEW_HEIGHT),
                                        MAX_INPUT_VIEW_HEIGHT);
    
    BOOL inputHeightWillBeChanged = (_mainView.inputHeight != messageTextViewHeight);
    [_mainView setInputHeight:messageTextViewHeight];
    
    if (isTableScrolledToBottom && inputHeightWillBeChanged) {
        [self scrollToBottomAnimated:NO delay:0.0f];
    }
}

- (void)scrollToBottomIfNeedAnimated:(BOOL)animated delay:(CGFloat)delay {
    CGFloat bottomPosition = self.tableView.contentSize.height - self.tableView.bounds.size.height - 1.0f;
    BOOL isTableScrolledToBottom = (self.tableView.contentOffset.y >= bottomPosition);
    if(isTableScrolledToBottom || self.needFullReload) {
        [self scrollToBottomAnimated:animated delay:delay];
    }
}

#pragma mark - UIImagePickerController delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //Fix offset changed by image picker
    if (!CGPointEqualToPoint(_tableContentOffset, self.tableView.contentOffset)) {
        self.tableView.contentOffset = _tableContentOffset;
    }
    _tableContentOffset = CGPointZero;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage * image = info[UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        //Fix offset changed by image picker
        if (!CGPointEqualToPoint(_tableContentOffset, self.tableView.contentOffset)) {
            self.tableView.contentOffset = _tableContentOffset;
        }
        _tableContentOffset = CGPointZero;
        
        if (image) {
            NSString * title = @"You can reduce the image size by scaling it to one of the following sizes";
            UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(title, nil)
                                                                      delegate:nil
                                                             cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                        destructiveButtonTitle:nil
                                                             otherButtonTitles:NSLocalizedStringWithFormat(@"Small (%ld%%)", 30, nil),
                                                                               NSLocalizedStringWithFormat(@"Medium (%ld%%)", 50, nil),
                                                                               NSLocalizedStringWithFormat(@"Large (%ld%%)", 80, nil),
                                                                               NSLocalizedString(@"Actual", nil), nil];
            
            [actionSheet setDidDismissBlock:^(UIActionSheet * __nonnull actionSheet, NSInteger buttonIndex) {
                if (buttonIndex <= 2) {
                    CGFloat scale = 1.0f;
                    switch (buttonIndex) {
                        case 0:
                            scale = 0.3f;
                            break;
                            
                        case 1:
                            scale = 0.5f;
                            break;
                            
                        case 2:
                            scale = 0.8f;
                            break;
                            
                        default:
                            break;
                    }
                    CGSize scaledSize = CGSizeMake(image.size.width * scale,
                                                   image.size.height * scale);
                    UIImage * scaledImage = [image imageWithFixedOrientation];
                    _attachmentImage = [UIImage scaleImage:scaledImage size:scaledSize];
                }
                else if(buttonIndex != actionSheet.cancelButtonIndex) {
                    _attachmentImage = [image imageWithFixedOrientation];
                }
                
                if (_attachmentImage != nil) {
                    _attachmentAsset = nil;
                    [_mainView.inputView.sendButton setEnabled:YES];
                    [_mainView.inputView.attachButton setImage:[UIImage imageNamed:ATTACHMENT_ADD_IMG]
                                                      forState:UIControlStateNormal];
                }
            }];
            
            [actionSheet showInView:self.view];
        }
    }];
}

#pragma mark - Assets Picker Delegate

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker isDefaultAssetsGroup:(ALAssetsGroup *)group {
    return ([[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupAll);
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAsset:(ALAsset *)asset {
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
        NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        return lround(duration) >= 5;
    }
    return YES;
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didSelectAsset:(ALAsset *)asset {
    _attachmentAsset = asset;
    if (_attachmentAsset != nil) {
        _attachmentImage = nil;
        [_mainView.inputView.sendButton setEnabled:YES];
        [_mainView.inputView.attachButton setImage:[UIImage imageNamed:ATTACHMENT_ADD_IMG]
                                          forState:UIControlStateNormal];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (UITableViewCell<IQCommentCell>*)cellForView:(UIView*)view {
    BOOL superIsCommentCell = [view.superview isKindOfClass:[UITableViewCell class]] &&
                              [view.superview conformsToProtocol:@protocol(IQCommentCell)];
    if (superIsCommentCell || !view.superview) {
        return (UITableViewCell<IQCommentCell>*)view.superview;
    }
    
    return [self cellForView:view.superview];
}

- (void)drawerDidShowNotification:(NSNotification*)notification {
    [_mainView.inputView.commentTextView resignFirstResponder];
}

#pragma mark - Conversation Notification

- (void)proccessUserRemovedFromConversation {
    if(!_blockUpdation) {
        _blockUpdation = YES;

        [self.navigationController popToViewController:self animated:YES];
        
        [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                           message:NSLocalizedString(@"Administrator deleted You from this chat", nil)
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:nil];
        
        [self.tableView setPullToRefreshAtPosition:SVPullToRefreshPositionTop shown:NO];
        
        [self.model lockConversation];
        
        _mainView.inputView.sendButton.enabled = NO;
        _mainView.inputView.attachButton.enabled = NO;
        _mainView.inputView.commentTextView.editable = NO;
        
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)proccessUserAddToConversation {
    if (_blockUpdation) {
        [self.model unlockConversation];
        
        _mainView.inputView.sendButton.enabled = YES;
        _mainView.inputView.attachButton.enabled = YES;
        _mainView.inputView.commentTextView.editable = YES;
        
        NSString *imageName = [self.model isDiscussionConference] ? @"edit_conference_icon.png" : @"add_user_icon.png";
        UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(rightBarButtonAction:)];
        self.navigationItem.rightBarButtonItem = rightBarButton;
        _blockUpdation = NO;
    }
}

#pragma mark - ContactPickerController delegate

- (void)updateTitle {
    self.title = self.model.discussion.conversation.title;
}

- (void)contactPickerController:(ContactPickerController*)picker didPickContacts:(NSArray*)contacts {
    if ([contacts count] > 0) {
        NSArray * users = [contacts valueForKey:@"user"];
        NSArray * userIds = [users valueForKey:@"userId"];
        
        [DiscussionModel conferenceFromConversationWithId:self.model.discussion.conversation.conversationId
                                                  userIds:userIds
                                               completion:^(IQConversation * conversation, NSError *error) {
                                                   if (conversation) {
                                                       DiscussionModel * model = [[DiscussionModel alloc] initWithDiscussion:conversation.discussion];
                                                       self.model = model;
                                                       
                                                       self.title = conversation.title;
                                                       [self.tableView reloadData];
                                                       [self.navigationController popViewControllerAnimated:YES];
                                                   }
                                               }];
    }
}

- (void)dealloc {
    [self.tableView removeGestureRecognizer:_tableGesture];
    _tableGesture.delegate = nil;

    [self.model setSubscribedToNotifications:NO];
    [self.model setDelegate:nil];
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
