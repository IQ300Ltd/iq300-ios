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

#import "SharingDiscussionController.h"
#import "DiscussionView.h"
#import "CommentCell.h"
#import "IQComment.h"
#import "DispatchAfterExecution.h"
#import "ALAsset+Extension.h"
#import "IQConversation.h"
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
#import "IQManagedAttachment.h"
#import "SharingViewController.h"

#define SECTION_HEIGHT 12

@interface SharingDiscussionController() <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, DiscussionModelDelegate, IQActivityViewControllerDelegate> {
    DiscussionView * _mainView;
    BOOL _enterCommentProcessing;
    UIDocumentInteractionController * _documentController;
    UISwipeGestureRecognizer * _tableGesture;
    CGPoint _tableContentOffset;
    BOOL _blockUpdation;
    
    SharingAttachment *_attachment;
}

@end

@implementation SharingDiscussionController

@dynamic model;

- (instancetype)initWithAttachment:(SharingAttachment *)attachment {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _attachment = attachment;
    }
    return self;
}

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
    
    [_mainView.inputView.sendButton addTarget:self
                                       action:@selector(sendButtonAction:)
                             forControlEvents:UIControlEventTouchUpInside];
    
    [_mainView.inputView.attachButton setImage:[UIImage imageNamed:ATTACHMENT_ADD_IMG]
                                      forState:UIControlStateNormal];

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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

#pragma mark - Private methods

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
    [_mainView.inputView.sendButton setEnabled:NO];
    [_mainView.inputView.attachButton setEnabled:NO];
    [_mainView.inputView.commentTextView setEditable:NO];
    [_mainView.inputView.commentTextView resignFirstResponder];
    
    [self.model sendComment:_mainView.inputView.commentTextView.text attachment:_attachment withCompletion:^(NSError *error) {
        if (!error) {
            [self activityDidFinish:YES];
        }
        else {
            [self proccessServiceError:error];
            [self activityDidFinish:NO];
        }
    }];
}

- (void)activityDidFinish:(BOOL)success {
    NSAssert(_sharingController, @"Sharing contoller not exists");
    [_sharingController finishActivity:success];
}

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

- (UITableViewCell<IQCommentCell>*)cellForView:(UIView*)view {
    BOOL superIsCommentCell = [view.superview isKindOfClass:[UITableViewCell class]] &&
    [view.superview conformsToProtocol:@protocol(IQCommentCell)];
    if (superIsCommentCell || !view.superview) {
        return (UITableViewCell<IQCommentCell>*)view.superview;
    }
    
    return [self cellForView:view.superview];
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
    [self.model setSubscribedToNotifications:NO];
    [self.model setDelegate:nil];
}

@end
