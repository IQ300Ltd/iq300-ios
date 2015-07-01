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

#define SEPARATOR_HEIGHT 0.5f
#define SEPARATOR_COLOR [UIColor colorWithHexInt:0xcccccc]
#define BOTTOM_VIEW_HEIGHT 65

@interface CreateFeedbackController () {
    CGFloat _tableBottomMarging;
    NSIndexPath * _editableIndexPath;
    UIView * _bottomSeparatorView;
    ExtendedButton * _sendButton;
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
    
    _bottomSeparatorView = [[UIView alloc] init];
    [_bottomSeparatorView setBackgroundColor:SEPARATOR_COLOR];
    [self.view addSubview:_bottomSeparatorView];
    
    _sendButton = [[ExtendedButton alloc] init];
    _sendButton.layer.cornerRadius = 4.0f;
    _sendButton.layer.borderWidth = 0.5f;
    [_sendButton setTitle:NSLocalizedString(@"Send", nil)
                 forState:UIControlStateNormal];
    [_sendButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:16]];
    [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [_sendButton setBackgroundColor:IQ_CELADON_COLOR];
    [_sendButton setBackgroundColor:IQ_CELADON_COLOR_HIGHLIGHTED forState:UIControlStateHighlighted];
    [_sendButton setBackgroundColor:IQ_CELADON_COLOR_DISABLED forState:UIControlStateDisabled];
    _sendButton.layer.borderColor = _sendButton.backgroundColor.CGColor;
    [_sendButton setClipsToBounds:YES];
    [_sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_sendButton];
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
    
    CGRect actualBounds = self.view.bounds;
    
    _bottomSeparatorView.frame = CGRectMake(actualBounds.origin.x,
                                            actualBounds.origin.y + actualBounds.size.height - BOTTOM_VIEW_HEIGHT,
                                            actualBounds.size.width,
                                            SEPARATOR_HEIGHT);
    
    CGSize doneButtonSize = CGSizeMake(300, 40);
    _sendButton.frame = CGRectMake(actualBounds.origin.x + (actualBounds.size.width - doneButtonSize.width) / 2.0f,
                                   actualBounds.origin.y + actualBounds.size.height - doneButtonSize.height - 10.0f,
                                   doneButtonSize.width,
                                   doneButtonSize.height);
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
    textView.text = newString;
    [self.model updateFieldAtIndexPath:_editableIndexPath withValue:newString];
    [self updateCellFrameIfNeed];
    
    return NO;
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
    if ([self.model modelHasChanges]) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                           message:NSLocalizedString(@"Sent feedback?", nil)
                 cancelButtonTitle:NSLocalizedString(@"Сancellation", nil)
                 otherButtonTitles:@[NSLocalizedString(@"Yes", nil), NSLocalizedString(@"No", nil)]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == 1 || buttonIndex == 2) {
                                  if (buttonIndex == 1) {
                                      [self sendButtonAction:_sendButton];
                                  }
                                  else {
                                      [self.navigationController popViewControllerAnimated:YES];
                                  }
                              }
                          }];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)sendButtonAction:(UIButton*)sender {
    if ([self isAllFieldsValid]) {
        [self.model createFeedbackWithCompletion:^(NSError *error) {
            if (!error) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
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
