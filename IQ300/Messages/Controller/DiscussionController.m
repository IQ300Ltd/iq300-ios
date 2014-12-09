//
//  DiscussionController.m
//  IQ300
//
//  Created by Tayphoon on 04.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <SVPullToRefresh/UIScrollView+SVPullToRefresh.h>
#import <MMDrawerController/UIViewController+MMDrawerController.h>
#import <CTAssetsPickerController/CTAssetsPickerController.h>

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

@interface DiscussionController() {
    DiscussionView * _mainView;
    BOOL _enterCommentProcessing;
    ALAsset * _attachment;
    UIDocumentInteractionController * _documentController;
}

@end

@implementation DiscussionController

- (UITableView*)tableView {
    return _mainView.tableView;
}

- (void)loadView {
    _mainView = [[DiscussionView alloc] init];
    self.view = _mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _enterCommentProcessing = NO;
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
    
    [_mainView.titleLabel setText:self.companionName];
    
    [self.leftMenuController setModel:nil];
    [self.leftMenuController reloadMenuWithCompletion:nil];
    
    if([IQSession defaultSession]) {
        [self reloadModel];
    }
    
    [self.model setSubscribedToSystemWakeNotifications:YES];
    
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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.model setSubscribedToSystemWakeNotifications:NO];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    [cell.attachButton addTarget:self
                          action:@selector(attachViewButtonAction:)
                forControlEvents:UIControlEventTouchUpInside];
    [cell.attachButton setTag:indexPath.row];
    
    IQComment * comment = [self.model itemAtIndexPath:indexPath];
    cell.item = comment;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IQComment * comment = [self.model itemAtIndexPath:indexPath];
    NSArray * attachments = [comment.attachments allObjects];
    for (IQAttachment * attachment in attachments) {
        NSLog(@"%@", attachment.originalURL);
    }
}

#pragma mark - UIScroll Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(_enterCommentProcessing && scrollView == self.tableView) {
        [self.tableView setContentOffset:self.tableView.contentOffset animated:YES];
        [self.tableView setScrollEnabled:NO];
        [_mainView.inputView.commentTextView resignFirstResponder];
    }
}

- (void)modelDidChangeContent:(id<IQTableModel>)model {
    [super modelDidChangeContent:model];
    dispatch_after_delay(0.5, dispatch_get_main_queue(), ^{
        [self scrollToBottomAnimated:YES];
    });
}

- (void)modelDidChanged:(id<IQTableModel>)model {
    [super modelDidChanged:model];
    [self scrollToBottomAnimated:NO];
}

#pragma mark - Private methods

- (BOOL)isValidText:(NSString *)text {
    if (text == nil || [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        return NO;
    }
    
    return YES;
}

- (void)updateUserInteraction:(NSString *)text {
    BOOL isSendButtonEnabled = [self isValidText:text];
    [_mainView.inputView.sendButton setEnabled:isSendButtonEnabled];
}


- (void)backButtonAction:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendButtonAction:(UIButton*)sender {
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
                 [_mainView.inputView.attachButton setEnabled:YES];
                 [_mainView.inputView.commentTextView setEditable:YES];
             }];
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
    IQComment * comment = [self.model itemAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    IQAttachment * attachment = [[comment.attachments allObjects] lastObject];
    
    if ([attachment.localURL length] > 0) {
        _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL URLWithString:attachment.localURL]];
        [_documentController setDelegate:(id<UIDocumentInteractionControllerDelegate>)self];
        [_documentController presentOpenInMenuFromRect:[sender frame] inView:self.view animated:YES];
    }
    else if([attachment.unifiedContentType rangeOfString:@"image"].location != NSNotFound &&
            [attachment.originalURL length] > 0) {
        PhotoViewController * controller = [[PhotoViewController alloc] init];
        controller.imageURL = [NSURL URLWithString:attachment.originalURL];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)reloadModel {
    [self.model reloadModelWithCompletion:^(NSError *error) {
        if(!error) {
            [self.tableView reloadData];
            if([self.model numberOfItemsInSection:0] > 0) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionTop
                                              animated:NO];
            }
            else {
                [self.model updateModelWithCompletion:^(NSError *error) {
                    if([self.model numberOfItemsInSection:0] > 0) {
                    }
                }];
            }
        }
        [self scrollToBottomAnimated:NO];
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
    [self scrollToBottomAnimated:NO];
    
    [UIView commitAnimations];
}

#pragma mark - PlaceholderTextViewDelegate Methods

- (void)textViewDidChange:(UITextView *)textView {
    [self updateUserInteraction:textView.text];
    [textView scrollRangeToVisible:textView.selectedRange];
    
    CGSize contentSize = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, FLT_MAX)];
    contentSize = CGSizeMake(contentSize.width,
                             contentSize.height + 5.0f);
    CGFloat messageTextViewHeight = MIN(MAX(contentSize.height + (textView.textContainerInset.top + textView.textContainerInset.bottom)*2.0, MIN_INPUT_VIEW_HEIGHT),
                                        MAX_INPUT_VIEW_HEIGHT);
    
    [_mainView setInputHeight:messageTextViewHeight];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    NSInteger section = [self.tableView numberOfSections];
    
    if (section > 0) {
        NSInteger itemsCount = [self.tableView numberOfRowsInSection:--section];
        
        if (itemsCount > 0) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:itemsCount - 1 inSection:section];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
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
    NSLog(@"Starting to send this item to %@", application);
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    _documentController = nil;
}

@end
