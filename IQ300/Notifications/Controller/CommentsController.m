//
//  DiscussionViewController.m
//  IQ300
//
//  Created by Tayphoon on 24.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <SVPullToRefresh/UIScrollView+SVPullToRefresh.h>
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

@interface CommentsController() {
    CommentsView * _mainView;
    BOOL _enterCommentProcessing;
    ALAsset * _attachment;
    UIDocumentInteractionController * _documentController;
    BOOL _needFullReload;
}

@end

@implementation CommentsController

- (UITableView*)tableView {
    return _mainView.tableView;
}

- (void)loadView {
    _mainView = [[CommentsView alloc] init];
    self.view = _mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _enterCommentProcessing = NO;
    _needFullReload = YES;
    
    [_mainView.inputView.sendButton setEnabled:NO];
    [_mainView.backButton addTarget:self
                             action:@selector(backButtonAction:)
                   forControlEvents:UIControlEventTouchUpInside];
    [_mainView.inputView.sendButton addTarget:self
                                       action:@selector(sendButtonAction:)
                             forControlEvents:UIControlEventTouchUpInside];
    
    [_mainView.inputView.attachButton addTarget:self
                                         action:@selector(attachButtonAction:)
                               forControlEvents:UIControlEventTouchUpInside];
    
    __weak typeof(self) weakSelf = self;
    [self.tableView
     addPullToRefreshWithActionHandler:^{
         [weakSelf.model updateModelWithCompletion:^(NSError *error) {
             [weakSelf.tableView.pullToRefreshView stopAnimating];
         }];
     }
     position:SVPullToRefreshPositionTop];
    
    [_mainView.inputView.commentTextView setDelegate:(id<UITextViewDelegate>)self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_mainView.titleLabel setText:self.subTitle];
    
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
    if([IQSession defaultSession]) {
        [self reloadModel];
    }
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
    
    NSInteger buttonIndex = 0;
    for (UIButton * attachButton in cell.attachButtons) {
        [attachButton addTarget:self
                         action:@selector(attachViewButtonAction:)
               forControlEvents:UIControlEventTouchUpInside];
        [attachButton setTag:buttonIndex];
        buttonIndex ++;
    }
    
    if(self.highlightedCommentId && [comment.commentId isEqualToNumber:self.highlightedCommentId]) {
        [cell setCommentHighlighted:YES];
    }
  
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - UIScroll Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(_enterCommentProcessing && scrollView == self.tableView) {
        [self.tableView setContentOffset:self.tableView.contentOffset animated:YES];
        [self.tableView setScrollEnabled:NO];
        [_mainView.inputView.commentTextView resignFirstResponder];
    }
}

#pragma mark - DiscussionModelDelegate Delegate

- (void)model:(CommentsModel*)model newComment:(IQComment*)comment {
    CGFloat bottomPosition = self.tableView.contentSize.height - self.tableView.bounds.size.height - 1.0f;
    BOOL isTableScrolledToBottom = (self.tableView.contentOffset.y >= bottomPosition);
    if(isTableScrolledToBottom) {
        [self scrollToBottomAnimated:YES delay:0.5f];
    }
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
    CGFloat bottomPosition = self.tableView.contentSize.height - self.tableView.bounds.size.height - 1.0f;
    BOOL isTableScrolledToBottom = (self.tableView.contentOffset.y >= bottomPosition);
    
    BOOL isTextValid = [self isTextValid:_mainView.inputView.commentTextView.text];
    if(isTextValid) {
        [_mainView.inputView.sendButton setEnabled:NO];
        [_mainView.inputView.attachButton setEnabled:NO];
        [_mainView.inputView.commentTextView setEditable:NO];
        [_mainView.inputView.commentTextView resignFirstResponder];
        
        [self.model sendComment:_mainView.inputView.commentTextView.text
                attachmentAsset:_attachment
                       fileName:[_attachment fileName]
                 attachmentType:[_attachment MIMEType]
                 withCompletion:^(NSError *error) {
                     if(!error) {
                         _mainView.inputView.commentTextView.text = nil;
                         [_mainView.inputView.attachButton setImage:[UIImage imageNamed:ATTACHMENT_IMG]
                                                           forState:UIControlStateNormal];
                         _attachment = nil;
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
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.assetsFilter = [ALAssetsFilter allAssets];
    picker.showsCancelButton = YES;
    picker.delegate = (id<CTAssetsPickerControllerDelegate>)self;
    picker.showsNumberOfAssets = NO;
    [self presentViewController:picker animated:YES completion:nil];
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
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              
                          }];
    }
}

- (void)reloadModel {
    [self.model reloadFirstPartWithCompletion:^(NSError *error) {
        if(!error) {
            [self.tableView reloadData];
        }
        
        if(_needFullReload) {
            [self scrollToCommentWithId:self.highlightedCommentId animated:YES delay:0.5f];
        }
        
        _needFullReload = NO;
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
    keyboardRect = [_mainView.inputView convertRect:keyboardRect fromView:nil];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [_mainView setInputOffset:down ? 0.0f : keyboardRect.origin.y - _mainView.inputView.frame.size.height];
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
    
    [_mainView setInputHeight:messageTextViewHeight];
    if (isTableScrolledToBottom) {
        [self scrollToBottomAnimated:NO delay:0.0f];
    }
}

- (void)scrollToBottomIfNeedAnimated:(BOOL)animated delay:(CGFloat)delay {
    CGFloat bottomPosition = self.tableView.contentSize.height - self.tableView.bounds.size.height - 1.0f;
    BOOL isTableScrolledToBottom = (self.tableView.contentOffset.y >= bottomPosition);
    if(isTableScrolledToBottom || _needFullReload) {
        [self scrollToBottomAnimated:animated delay:delay];
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated delay:(CGFloat)delay {
    NSInteger section = [self.tableView numberOfSections];
    if (section > 0) {
        NSInteger itemsCount = [self.tableView numberOfRowsInSection:section-1];
        
        if (itemsCount > 0) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:itemsCount - 1 inSection:section - 1];
            [self scrollToIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated delay:delay];
        }
    }
}

- (void)scrollToCommentWithId:(NSNumber*)commentId animated:(BOOL)animated delay:(CGFloat)delay {
    NSIndexPath * indexPath = [self.model indexPathForCommentWithId:commentId];
    if(indexPath) {
        [self scrollToIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:animated delay:delay];
    }
}

- (void)scrollToIndexPath:(NSIndexPath*)indexPath atScrollPosition:(UITableViewScrollPosition)position animated:(BOOL)animated delay:(CGFloat)delay {
    NSInteger section = [self.tableView numberOfSections];
    if (section > 0) {
        NSInteger itemsCount = [self.tableView numberOfRowsInSection:section-1];
        
        if (itemsCount > 0 && indexPath.row && section >= indexPath.section) {
            if(delay > 0.0f) {
                dispatch_after_delay(delay, dispatch_get_main_queue(), ^{
                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:position animated:animated];
                });
            }
            else {
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:position animated:animated];
            }
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
    _attachment = asset;
    [_mainView.inputView.sendButton setEnabled:(_attachment != nil)];
    [_mainView.inputView.attachButton setImage:[UIImage imageNamed:ATTACHMENT_ADD_IMG]
                                      forState:UIControlStateNormal];
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

- (void)dealloc {
    [self.model setSubscribedToNotifications:NO];
    [self.model setDelegate:nil];
}

@end