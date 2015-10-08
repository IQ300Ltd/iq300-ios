//
//  DiscussionViewController.m
//  IQ300
//
//  Created by Tayphoon on 24.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <MMDrawerController/UIViewController+MMDrawerController.h>
#import <CTAssetsPickerController/CTAssetsPickerController.h>
#import <RestKit/CoreData/NSManagedObjectContext+RKAdditions.h>

#import "UIViewController+LeftMenu.h"
#import "IQSession.h"

#import "CommentsController.h"
#import "CommentsView.h"
#import "CCommentCell.h"
#import "IQComment.h"
#import "DispatchAfterExecution.h"
#import "ALAsset+Extension.h"
#import "IQConversation.h"
#import "PhotoViewController.h"
#import "DownloadManager.h"
#import "UIViewController+ScreenActivityIndicator.h"
#import "IQDrawerController.h"
#import "DispatchAfterExecution.h"
#import "UIScrollView+PullToRefreshInsert.h"

#import "UserPickerController.h"
#import "IQService.h"
#import "UIImage+Extensions.h"
#import "UIActionSheet+Blocks.h"

#define DISPATCH_DELAY 1.0f

@interface CommentsController() <UserPickerControllerDelegate, SWTableViewCellDelegate, UIImagePickerControllerDelegate,
                                 UINavigationControllerDelegate> {
    CommentsView * _mainView;
    BOOL _enterCommentProcessing;
    ALAsset * _attachmentAsset;
    UIImage * _attachmentImage;
    UIDocumentInteractionController * _documentController;
    UISwipeGestureRecognizer * _tableGesture;
    UserPickerController * _userPickerController;
    NSRange _inputWordRange;
    NSString * _curUserNick;
    NSArray * _avalibleNicks;
    dispatch_after_block _cancelBlock;
    CGPoint _tableContentOffset;
}

@end

@implementation CommentsController

@dynamic model;

- (UITableView*)tableView {
    return _mainView.tableView;
}

- (void)loadView {
    _mainView = [[CommentsView alloc] init];
    self.view = _mainView;
}

- (void)setModel:(CommentsModel *)model {
    [super setModel:model];
    
    _avalibleNicks = [[self.model.discussion.users allObjects] valueForKey:@"nickName"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _enterCommentProcessing = NO;
    self.needFullReload = YES;
    
    IQUser * curUser = [IQUser userWithId:[IQSession defaultSession].userId
                                inContext:[IQService sharedService].context];
    _curUserNick = curUser.nickName;
    
    [self setActivityIndicatorBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.3f]];
    [self setActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    _tableGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(handleSwipe:)];
    _tableGesture.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    _tableGesture.delegate = (id<UIGestureRecognizerDelegate>)self;
    
    [self.tableView addGestureRecognizer:_tableGesture];

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
         [weakSelf.model loadNextPartWithCompletion:^(NSError *error) {
             [[weakSelf.tableView pullToRefreshForPosition:SVPullToRefreshPositionTop] stopAnimating];
         }];
     }
     position:SVPullToRefreshPositionTop];
    
    [_mainView.inputView.commentTextView setDelegate:(id<UITextViewDelegate>)self];
    _mainView.tableView.hidden = YES;
}

- (BOOL)isLeftMenuEnabled {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
        
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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableView DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.model.cellWidth = tableView.frame.size.width;
    return [self.model heightForItemAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCommentCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    IQComment * comment = [self.model itemAtIndexPath:indexPath];
    cell.item = comment;
    cell.delegate = self;
    cell.descriptionTextView.attributedText = [self formatedTextFromText:comment.body];
    cell.descriptionTextView.delegate = (id<UITextViewDelegate>)self;
    
    cell.expandable = [self.model isCellExpandableAtIndexPath:indexPath];
    cell.expanded = [self.model isItemExpandedAtIndexPath:indexPath];
    
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
    
}

#pragma mark - SWTableViewCell Delegate

- (void)swipeableTableViewCell:(CCommentCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    IQComment * comment = [self.model itemAtIndexPath:indexPath];
    [self.model deleteComment:comment completion:^(NSError *error) {
        [self proccessServiceError:error];
        [cell hideUtilityButtonsAnimated:YES];
    }];
}

#pragma mark - DiscussionModelDelegate Delegate

- (void)model:(CommentsModel*)model newComment:(IQComment*)comment {
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

#pragma mark - Activity indicator overrides

- (void)showActivityIndicatorAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [self.tableView setPullToRefreshAtPosition:SVPullToRefreshPositionTop shown:NO];
    
    [super showActivityIndicatorAnimated:YES completion:nil];
}

- (void)hideActivityIndicatorAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [super hideActivityIndicatorAnimated:YES completion:^{
        [self.tableView setPullToRefreshAtPosition:SVPullToRefreshPositionTop shown:YES];
        
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - Private methods

- (CCommentCell*)cellForView:(UIView*)view {
    if ([view.superview isKindOfClass:[CCommentCell class]] || !view.superview) {
        return (CCommentCell*)view.superview;
    }
    
    return [self cellForView:view.superview];
}

- (BOOL)isTextValid:(NSString *)text {
    if (text == nil || [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        return NO;
    }
    
    return YES;
}

- (void)updateUserInteraction:(NSString *)text {
    BOOL isSendButtonEnabled = [self isTextValid:text];
    [_mainView.inputView.sendButton setEnabled:isSendButtonEnabled];
}

- (void)backButtonAction:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendButtonAction:(UIButton*)sender {
    [self hideUserPickerController];

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
                         BOOL isTaskComment = ([self isKindOfClass:NSClassFromString(@"TCommentsController")]);
                         [GAIService sendEventForCategory:(isTaskComment) ? GAITaskEventCategory : GAIMessagesEventCategory
                                                   action:(isTaskComment) ? @"event_action_task_comment" : GAICreateMessageEventAction];
                         
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
                     _mainView.inputView.sendButton.enabled = ([_mainView.inputView.commentTextView.text length] > 0);
                     if(isTableScrolledToBottom) {
                         [self scrollToBottomAnimated:YES delay:0.5f];
                     }
                 }];
    }
}

- (void)attachButtonAction:(UIButton*)sender {
    [self hideUserPickerController];
    
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
    CCommentCell * cell = [self cellForView:sender];
    
    if(!cell) {
        return;
    }
    
    IQComment * comment = cell.item;
    IQAttachment * attachment = [[comment.attachments allObjects] objectAtIndex:sender.tag];
    
    CGRect rectForAppearing = [sender.superview convertRect:sender.frame toView:self.view];
    if([attachment.contentType rangeOfString:@"image"].location != NSNotFound &&
       [attachment.originalURL length] > 0) {
        PhotoViewController * controller = [[PhotoViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        controller.imageURL = [NSURL URLWithString:attachment.originalURL];
        controller.fileName = attachment.displayName;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if ([attachment.localURL length] > 0) {
        [self showOpenInForURL:attachment.localURL fromRect:rectForAppearing];
    }
    else {
        [self showActivityIndicator];
        NSArray * urlComponents = [attachment.originalURL componentsSeparatedByString:@"?"];
        NSString * fileExtension = [[urlComponents firstObject] pathExtension];
        [[DownloadManager sharedManager] downloadDataFromURL:attachment.originalURL
                                                     success:^(NSOperation *operation, NSString * storedURL, NSData *responseData) {
                                                         NSString * destinationURL = [storedURL stringByAppendingPathExtension:fileExtension];
                                                         [[NSFileManager defaultManager] moveItemAtURL:[NSURL fileURLWithPath:storedURL]
                                                                                                 toURL:[NSURL fileURLWithPath:destinationURL]
                                                                                                 error:nil];
                                                         attachment.localURL = destinationURL;
                                                         
                                                         NSError *saveError = nil;
                                                         if(![attachment.managedObjectContext saveToPersistentStore:&saveError] ) {
                                                             NSLog(@"Save attachment error: %@", saveError);
                                                         }
                                                         [self showOpenInForURL:destinationURL fromRect:rectForAppearing];
                                                     }
                                                     failure:^(NSOperation *operation, NSError *error) {
                                                         [self hideActivityIndicator];
                                                     }];
    }
}

- (void)showOpenInForURL:(NSString*)localURL fromRect:(CGRect)rect {
    [self hideActivityIndicator];
    NSURL * documentURL = [NSURL fileURLWithPath:localURL isDirectory:NO];
    _documentController = [UIDocumentInteractionController interactionControllerWithURL:documentURL];
    [_documentController setDelegate:(id<UIDocumentInteractionControllerDelegate>)self];
    if(![_documentController presentOpenInMenuFromRect:rect inView:self.view animated:YES]) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                           message:NSLocalizedString(@"You do not have an application installed to view files of this type", nil)
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:nil];
    }
}

- (void)expandButtonAction:(UIButton*)sender {
    CCommentCell * cell = [self cellForView:sender];
    if(cell) {
        NSIndexPath * cellIndexPath = [self.tableView indexPathForCell:cell];
        BOOL isExpanded = [self.model isItemExpandedAtIndexPath:cellIndexPath];
        [self.model setItemExpanded:!isExpanded atIndexPath:cellIndexPath];
    }
}

- (void)updateModel {
    if([IQSession defaultSession] && self.model) {
        [self showActivityIndicatorAnimated:YES completion:nil];
        
        [self.model updateModelWithCompletion:^(NSError *error) {
            if(!error) {
                [self.tableView reloadData];
            }
            
            [self scrollToBottomIfNeedAnimated:NO delay:0];
            self.needFullReload = NO;
            
            [self updateNoDataLabelVisibility];
            dispatch_after_delay(0.5f, dispatch_get_main_queue(), ^{
                _mainView.tableView.hidden = NO;
                [self markVisibleItemsAsReaded];
                
                [self hideActivityIndicatorAnimated:YES completion:nil];
            });
        }];
    }
}

- (void)applicationWillEnterForeground {
    [self updateModel];
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

#pragma mark - UITextViewDelegate Methods

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
    [self layoutUserPickerController];
  
    if (isTableScrolledToBottom && inputHeightWillBeChanged) {
        [self scrollToBottomAnimated:NO delay:0.0f];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView == _mainView.inputView.commentTextView) {
        NSString * newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
        [self showAutoCompleationIfNeedForText:newString selectedRange:NSMakeRange((range.length > 0) ? range.location : range.location + 1, 0)];
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if (textView != _mainView.inputView.commentTextView) {
        //This is not me, this is fucking strange url
        NSString * unescapedString = [[URL absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        unescapedString = [unescapedString stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
        NSString * encodeURL = [unescapedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:encodeURL]];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - ScrollView delefates

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self markVisibleItemsAsReaded];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self markVisibleItemsAsReaded];
}

- (void)markVisibleItemsAsReaded {
    if (self.isViewLoaded) {
        if(_cancelBlock) {
            cancel_dispatch_after_block(_cancelBlock);
        }
        
        NSArray * indexPaths = [[self.tableView indexPathsForVisibleRows] copy];
        _cancelBlock = dispatch_after_delay(DISPATCH_DELAY, dispatch_get_main_queue(), ^{
            [self.model markCommentsReadedAtIndexPaths:indexPaths];
        });
    }
}

#pragma mark - Scrolls

- (void)scrollToBottomIfNeedAnimated:(BOOL)animated delay:(CGFloat)delay {
    CGFloat bottomPosition = self.tableView.contentSize.height - self.tableView.bounds.size.height - 1.0f;
    BOOL isTableScrolledToBottom = (self.tableView.contentOffset.y >= bottomPosition);
    if(isTableScrolledToBottom || self.needFullReload) {
        [self scrollToBottomAnimated:animated delay:delay];
    }
}

- (void)scrollToCommentWithId:(NSNumber*)commentId animated:(BOOL)animated delay:(CGFloat)delay {
    NSIndexPath * indexPath = [self.model indexPathForCommentWithId:commentId];
    if(indexPath) {
        if(delay > 0.0f) {
            dispatch_after_delay(delay, dispatch_get_main_queue(), ^{
                [self scrollToCommentWithId:commentId animated:animated delay:0.0f];
            });
        }
        else {
            NSIndexPath * indexPath = [self.model indexPathForCommentWithId:commentId];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:animated];
        }
    }
}

#pragma mark - Assets Picker Delegate

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker isDefaultAssetsGroup:(ALAssetsGroup *)group {
    return ([[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupAll);
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAsset:(ALAsset *)asset {
    // Enable video clips if they are at least 5s
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

#pragma mark - UIDocumentInteractionController Delegate Methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return  self;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
    
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    _documentController = nil;
}

- (void)drawerDidShowNotification:(NSNotification*)notification {
    [_mainView.inputView.commentTextView resignFirstResponder];
}

#pragma mark - User picker methods

- (void)showUserPickerControllerWithFilter:(NSString*)filter {
    if (!_userPickerController) {
        UsersPickerModel * model = [[UsersPickerModel alloc] init];
        model.users = [self.model.discussion.users allObjects];
        
        _userPickerController = [[UserPickerController alloc] init];
        _userPickerController.delegate = self;
        _userPickerController.model = model;
        [_mainView insertSubview:_userPickerController.view aboveSubview:_mainView.tableView];
    }
    
    _userPickerController.filter = filter;
}

- (void)hideUserPickerController {
    if (_userPickerController) {
        _userPickerController.delegate = nil;
        [_userPickerController.view removeFromSuperview];
        _userPickerController = nil;
    }
}

- (void)layoutUserPickerController {
    _userPickerController.view.frame = CGRectMake(0.0f, 0.0f, _mainView.tableView.frame.size.width, _mainView.tableView.frame.size.height);
}

- (void)userPickerController:(UserPickerController*)picker didPickUser:(IQUser*)user {
    if(user) {
        NSString * inputText = _mainView.inputView.commentTextView.text;
        if(_inputWordRange.location != NSNotFound) {
            BOOL needSpace = (_inputWordRange.location + _inputWordRange.length == inputText.length);
            NSString * resultString = (needSpace) ? [NSString stringWithFormat:@"@%@ ", user.nickName] :
                                                    [NSString stringWithFormat:@"@%@", user.nickName];
            
            inputText = [inputText stringByReplacingCharactersInRange:_inputWordRange
                                                           withString:resultString];
            _mainView.inputView.commentTextView.text = inputText;
            _mainView.inputView.commentTextView.selectedRange = NSMakeRange(_inputWordRange.location + [resultString length], 0);
        }
        [self hideUserPickerController];
    }
}

- (void)showAutoCompleationIfNeedForText:(NSString*)text selectedRange:(NSRange)selectedRange {
    if([text length] > 0) {
        NSString * beforeString = [text substringToIndex:selectedRange.location];
        NSString * afterString =  [text substringFromIndex:selectedRange.location];
        
        NSArray * wordArrayBefor = [beforeString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString * wordTypedBefor = [wordArrayBefor lastObject];
        NSArray * wordArrayAfter = [afterString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString * wordTypedAfter = [wordArrayAfter firstObject];
        
        NSString * typedWord = [wordTypedBefor stringByAppendingString:wordTypedAfter];
        if([typedWord length] > 0 && [[typedWord substringToIndex:1] isEqualToString:@"@"]) {
            NSInteger location = selectedRange.location;
            _inputWordRange = NSMakeRange(location - [wordTypedBefor length], [wordTypedBefor length] + [wordTypedAfter length]);
            [self showUserPickerControllerWithFilter:[typedWord substringFromIndex:1]];
        }
        else {
            _inputWordRange = NSMakeRange(0, 0);
            [self hideUserPickerController];
        }
    }
    else {
        _inputWordRange = NSMakeRange(0, 0);
        [self hideUserPickerController];
    }
}

- (NSAttributedString*)formatedTextFromText:(NSString*)text {
    if([text length] > 0) {
        
        NSDictionary * attributes = @{
                                      NSForegroundColorAttributeName : [UIColor colorWithHexInt:0x8b8b8b],
                                      NSFontAttributeName            : DESCRIPTION_LABEL_FONT
                                      };
        
        NSMutableAttributedString * aText = [[NSMutableAttributedString alloc] initWithString:text
                                                                                   attributes:attributes];
        
        NSError *error = nil;
        NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:@"(?:^|\\s)(?:@)(\\w+)" options:0 error:&error];
        NSArray * matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        for (NSTextCheckingResult *match in matches) {
            NSRange wordRange = [match rangeAtIndex:1];
            NSString * nickName = [text substringWithRange:wordRange];
            
            if([_avalibleNicks containsObject:nickName]) {
                BOOL isCurUserNick = ([nickName isEqualToString:_curUserNick]);
                
                wordRange.location = wordRange.location - 1;
                wordRange.length = wordRange.length + 1;
                
                if (!isCurUserNick) {
                    NSDictionary * highlightAttribute = @{ IQNikStrokeColorAttributeName : [UIColor colorWithHexInt:0x2c779d] };
                    [aText addAttributes:@{ IQNikHighlightAttributeName : highlightAttribute,
                                            NSForegroundColorAttributeName : [UIColor colorWithHexInt:0x2c779d] }
                                   range:wordRange];
                }
                else {
                    NSDictionary * highlightAttribute = @{ IQNikBackgroundColorAttributeName : [UIColor colorWithHexInt:0x2c779d] };
                    [aText addAttributes:@{ IQNikHighlightAttributeName : highlightAttribute,
                                            NSForegroundColorAttributeName: [UIColor whiteColor] }
                                   range:wordRange];
                }
            }
        }
        
        //add links to pattern task#taskId
        NSString * pattern = [NSString stringWithFormat:@"%@#\\d+$", NSLocalizedString(@"Task", nil)];
        regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        for (NSTextCheckingResult *match in matches) {
            NSRange wordRange = [match range];
            NSString * taskLink = [text substringWithRange:wordRange];
            NSString * taskId = [[taskLink componentsSeparatedByString:@"#"] lastObject];
            
            if ([taskId length] > 0) {
                [aText addAttribute:NSLinkAttributeName
                              value:[NSString stringWithFormat:@"%@://tasks/%@", APP_URL_SCHEME, taskId]
                              range:wordRange];
            }
        }
        
        return aText;
    }
    
    return nil;
}

- (void)dealloc {
    [self.model setSubscribedToNotifications:NO];
    [self.model setDelegate:nil];
}

@end
