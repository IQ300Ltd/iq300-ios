//
//  TTodoItemsController.m
//  IQ300
//
//  Created by Tayphoon on 31.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TTodoItemsController.h"
#import "TodoListItemCell.h"
#import "TodoItem.h"

#define MAX_NUMBER_OF_CHARACTERS 255

@interface TTodoItemsController() <SWTableViewCellDelegate, UITextViewDelegate> {
    CGFloat _tableBottomMarging;
    __weak NSIndexPath * _editableIndexPath;
}

@end

@implementation TTodoItemsController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"TodoList", nil);
    }
    return self;
}

- (BOOL)isLeftMenuEnabled {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;

    UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"white_add_ico.png"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(addButtonAction:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
  
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    [self layoutTabelView];
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TodoListItemCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    id<TodoItem> item = [self.model itemAtIndexPath:indexPath];
    cell.item = item;
    cell.delegate = self;
    cell.titleTextView.delegate = self;
    
    BOOL isCellChecked = [self.model isItemCheckedAtIndexPath:indexPath];
    [cell setAccessoryType:(isCellChecked) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];
    if (!isCellChecked) {
        cell.availableActions = @[@"edit", @"delete"];
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.model.cellWidth = tableView.frame.size.width;
    return [self.model heightForItemAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isCellChecked = [self.model isItemCheckedAtIndexPath:indexPath];
    [self.model makeItemAtIndexPath:indexPath checked:!isCellChecked];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_editableIndexPath == nil) {
        return ([self.model isItemSelectableAtIndexPath:indexPath]) ? indexPath : nil;
    }
    return nil;
}

#pragma mark - UITextViewDelegate Methods

- (void)textViewDidChange:(UITextView *)textView {
    TodoListItemCell * cell = (TodoListItemCell*)[self.tableView cellForRowAtIndexPath:_editableIndexPath];
    cell.item.title = textView.text;
    CGFloat cellHeight = [TodoListItemCell heightForItem:cell.item width:self.model.cellWidth];
    
    if (cell.frame.size.height != cellHeight) {
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        [self.tableView scrollToRowAtIndexPath:_editableIndexPath
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];

    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString * newString = [textView.text stringByReplacingCharactersInRange:range withString:text];

    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return ([newString length] < MAX_NUMBER_OF_CHARACTERS);
}

#pragma mark - SWTableViewCell Delegate

- (void)swipeableTableViewCell:(TodoListItemCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    if (index == 0) {
        if (!cell.titleTextView.editable) {
            _editableIndexPath = indexPath;
            [cell hideUtilityButtonsAnimated:YES];
            cell.titleTextView.editable = YES;
            [cell.titleTextView becomeFirstResponder];
            [self.tableView scrollToRowAtIndexPath:indexPath
                                  atScrollPosition:UITableViewScrollPositionTop
                                          animated:YES];
        }
    }
    else {
        [self.model deleteItemAtIndexPath:indexPath];
    }
}

#pragma mark - Keyboard Notifications

- (void)onKeyboardWillShow:(NSNotification *)notification {
    [self makeInputViewTransitionWithDownDirection:NO notification:notification];
}

- (void)onKeyboardWillHide:(NSNotification *)notification {
    if (_editableIndexPath) {
        TodoListItemCell * cell = (TodoListItemCell*)[self.tableView cellForRowAtIndexPath:_editableIndexPath];
        cell.titleTextView.editable = NO;
        _editableIndexPath = nil;
    }

    [self makeInputViewTransitionWithDownDirection:YES notification:notification];
}

#pragma mark - Private methods

- (void)makeInputViewTransitionWithDownDirection:(BOOL)down notification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _tableBottomMarging = down ? 0.0f : MIN(keyboardRect.size.width, keyboardRect.size.height) - 50.0f;
   
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [self layoutTabelView];
    
    [UIView commitAnimations];
}

- (void)backButtonAction:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addButtonAction:(UIButton*)sender {

}

- (void)layoutTabelView {
    CGRect actualBounds = self.view.bounds;
    actualBounds.size.height -= _tableBottomMarging;
    
    self.tableView.frame = actualBounds;
}

@end
