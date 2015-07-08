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

#define SECTION_HEIGHT 12

@interface DiscussionController() <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    DiscussionView * _mainView;
    BOOL _enterCommentProcessing;
    ALAsset * _attachmentAsset;
    UIImage * _attachmentImage;
    UIDocumentInteractionController * _documentController;
    UISwipeGestureRecognizer * _tableGesture;
    CGPoint _tableContentOffset;
}

@end

@implementation DiscussionController

@dynamic model;

- (UITableView*)tableView {
    return _mainView.tableView;
}

- (void)setModel:(id<IQTableModel>)model {
    self.model.delegate = nil;
    [self.model setSubscribedToNotifications:NO];
    [self.model clearModelData];
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
    CommentCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    IQComment * comment = [self.model itemAtIndexPath:indexPath];
    cell.item = comment;

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
    IQComment * comment = [self.model itemAtIndexPath:indexPath];
    if([comment.commentStatus integerValue] == IQCommentStatusSendError) {
        [UIAlertView showWithTitle:@"IQ300"
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
                                          NSLog(@"Resend local comment error");
                                      }
                                  }];
                              }
                          }];
    }
}

#pragma mark - DiscussionModelDelegate Delegate

- (void)model:(DiscussionModel*)model newComment:(IQComment*)comment {
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
                [UIAlertView showWithTitle:@"IQ300"
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
    CommentCell * cell = [self cellForView:sender];
    
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
        [UIAlertView showWithTitle:@"IQ300" message:NSLocalizedString(@"You do not have an application installed to view files of this type", nil)
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:nil];
    }
}

- (void)expandButtonAction:(UIButton*)sender {
    CommentCell * cell = [self cellForView:sender];
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
                
                [self hideActivityIndicatorAnimated:YES completion:nil];
            });
        }];
    }
}

- (void)applicationWillEnterForeground {
    [self.model markDiscussionAsReadedWithCompletion:nil];
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

#pragma mark - UIDocumentInteractionController Delegate Methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return  self;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {

}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    _documentController = nil;
}

- (CommentCell*)cellForView:(UIView*)view {
    if ([view.superview isKindOfClass:[CommentCell class]] || !view.superview) {
        return (CommentCell*)view.superview;
    }
    
    return [self cellForView:view.superview];
}

- (void)drawerDidShowNotification:(NSNotification*)notification {
    [_mainView.inputView.commentTextView resignFirstResponder];
}

- (void)dealloc {
    [self.model setSubscribedToNotifications:NO];
    [self.model setDelegate:nil];
}

@end
