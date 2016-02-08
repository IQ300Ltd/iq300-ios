//
//  FeedbackController.m
//  IQ300
//
//  Created by Tayphoon on 23.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "CreateFeedbackController.h"
#import "IQDetailsTextCell.h"
#import "ExtendedButton.h"
#import "FeedbackCategoriesModel.h"
#import "FeedbackTypesModel.h"
#import "IQSelectionController.h"
#import "DispatchAfterExecution.h"

#define BOTTOM_VIEW_HEIGHT 0

@interface CreateFeedbackController () {
    CGFloat _tableBottomMarging;
    NSIndexPath * _editableIndexPath;
    FeedbackCategoriesModel * _categoriesModel;
    FeedbackTypesModel * _typesModel;
}

@end

@implementation CreateFeedbackController

@dynamic model;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        _tableBottomMarging = BOTTOM_VIEW_HEIGHT;
        
        _categoriesModel = [[FeedbackCategoriesModel alloc] init];
        _typesModel = [[FeedbackTypesModel alloc] init];
        
        self.title = NSLocalizedString(@"New feedback", nil);
    }
    
    return self;
}

- (BOOL)isLeftMenuEnabled {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;

    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mark_tab_item.png"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(sendButtonAction:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutTabelView];
}

#pragma mark - UITableView DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.model.cellWidth = tableView.frame.size.width;
    return [self.model heightForItemAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IQEditableTextCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    cell.detailTitle = [self.model detailTitleForItemAtIndexPath:indexPath];
    cell.titleTextView.placeholder = [self.model placeholderForItemAtIndexPath:indexPath];
    cell.titleTextView.delegate = (id<UITextViewDelegate>)self;
    cell.item = [self.model itemAtIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IQEditableTextCell * cell = (IQEditableTextCell*)[tableView cellForRowAtIndexPath:_editableIndexPath];
    if (cell.titleTextView.isFirstResponder && ![indexPath isEqual:_editableIndexPath]) {
        //hide keyboard
        [cell.titleTextView resignFirstResponder];
    }
    
    if (indexPath.row < 2) {
        IQSelectionController * controller = [self controllerForItemIndexPath:indexPath];
        controller.title = [self.model placeholderForItemAtIndexPath:indexPath];
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    _editableIndexPath = [self indexPathForCellChildView:textView];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString * newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    [self.model updateFieldAtIndexPath:_editableIndexPath withValue:newString];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    UITextRange *range = textView.selectedTextRange;
    textView.text = textView.text;
    textView.selectedTextRange = range;
    [self updateCellFrameIfNeed];
}

#pragma mark - Keyboard Notifications

- (void)onKeyboardWillShow:(NSNotification *)notification {
    [self makeInputViewTransitionWithDownDirection:NO
                                      notification:notification];
    
    if (_editableIndexPath) {
        [self.tableView scrollToRowAtIndexPath:_editableIndexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];
    }
}

- (void)onKeyboardWillHide:(NSNotification *)notification {
    _editableIndexPath = nil;
    [self makeInputViewTransitionWithDownDirection:YES
                                      notification:notification];
}

#pragma mark - SelectionController delegate

- (void)selectionControllerController:(IQSelectionController*)controller didSelectItem:(id)item {
    NSIndexPath * editIndexPath = [NSIndexPath indexPathForItem:controller.view.tag inSection:0];
    [self.model updateFieldAtIndexPath:editIndexPath
                             withValue:item];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private methods

- (void)backButtonAction:(UIButton*)sender {
    if (_editableIndexPath) {
        IQEditableTextCell * cell = (IQEditableTextCell*)[self.tableView cellForRowAtIndexPath:_editableIndexPath];
        [cell.titleTextView resignFirstResponder];
    }
    
    if ([self.model modelHasChanges]) {
        dispatch_after_delay(0.5f, dispatch_get_main_queue(), ^{
            [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                               message:NSLocalizedString(@"Sent feedback?", nil)
                     cancelButtonTitle:NSLocalizedString(@"Сancellation", nil)
                     otherButtonTitles:@[NSLocalizedString(@"Yes", nil), NSLocalizedString(@"No", nil)]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == 1 || buttonIndex == 2) {
                                      if (buttonIndex == 1) {
                                          [self sendButtonAction:self.navigationItem.rightBarButtonItem];
                                      }
                                      else {
                                          [self.navigationController popViewControllerAnimated:YES];
                                      }
                                  }
                              }];
        });
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)sendButtonAction:(UIBarButtonItem *)sender {
    if (_editableIndexPath) {
        IQEditableTextCell * cell = (IQEditableTextCell*)[self.tableView cellForRowAtIndexPath:_editableIndexPath];
        [cell.titleTextView resignFirstResponder];
    }

    if ([self isAllFieldsValid]) {
        dispatch_after_delay(0.5f, dispatch_get_main_queue(), ^{
            [self.model createFeedbackWithCompletion:^(NSError *error) {
                if (!error) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                [self proccessServiceError:error];
            }];
        });
    }
}

- (NSIndexPath*)indexPathForCellChildView:(UIView*)childView {
    if ([childView.superview isKindOfClass:[UITableViewCell class]] || !childView.superview) {
        UITableViewCell * cell = (UITableViewCell*)childView.superview;
        return [self.tableView indexPathForCell:cell];
    }
    
    return [self indexPathForCellChildView:childView.superview];
}

- (void)updateCellFrameIfNeed {
    IQEditableTextCell * cell = (IQEditableTextCell*)[self.tableView cellForRowAtIndexPath:_editableIndexPath];
    CGFloat cellHeight = [IQEditableTextCell heightForItem:cell.titleTextView.text
                                               detailTitle:cell.detailTitle
                                                     width:self.model.cellWidth];
    
    if (cell.frame.size.height != cellHeight) {
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        [self.tableView scrollToRowAtIndexPath:_editableIndexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];
    }
}

- (void)makeInputViewTransitionWithDownDirection:(BOOL)down notification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat inset = MIN(keyboardRect.size.height, keyboardRect.size.width);
    _tableBottomMarging = down ? BOTTOM_VIEW_HEIGHT : inset;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [self layoutTabelView];
    
    [UIView commitAnimations];
}

- (void)layoutTabelView {
    CGRect actualBounds = self.view.bounds;
    
    self.tableView.frame = CGRectMake(actualBounds.origin.x,
                                      actualBounds.origin.y,
                                      actualBounds.size.width,
                                      actualBounds.origin.y + actualBounds.size.height - _tableBottomMarging);
}

- (IQSelectionController*)controllerForItemIndexPath:(NSIndexPath*)indexPath {
    IQSelectionController * controller = [[IQSelectionController alloc] init];
    controller.model = (indexPath.row == 0) ? _typesModel : _categoriesModel;
    controller.view.tag = indexPath.row;
    return controller;
}

- (BOOL)isAllFieldsValid {
    NSError * validationError = nil;
    if (![self.model isAllFieldsValidWithError:&validationError]) {
        [self showErrorAlertWithMessage:validationError.localizedDescription];
        return NO;
    }
    return YES;
}
@end
