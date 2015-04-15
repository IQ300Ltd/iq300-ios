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
#import "ExtendedButton.h"
#import "UIViewController+ScreenActivityIndicator.h"

#define MAX_NUMBER_OF_CHARACTERS 255
#define SEPARATOR_HEIGHT 0.5f
#define SEPARATOR_COLOR [UIColor colorWithHexInt:0xcccccc]
#define BOTTOM_VIEW_HEIGHT 80

@interface TTodoItemsController() <SWTableViewCellDelegate, UITextViewDelegate> {
    CGFloat _tableBottomMarging;
    NSIndexPath * _editableIndexPath;
    UIView * _bottomSeparatorView;
    ExtendedButton * _doneButton;
}

@end

@implementation TTodoItemsController

@dynamic model;

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
    
    [self setActivityIndicatorBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.3f]];
    [self setActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [UIView new];
    
    _bottomSeparatorView = [[UIView alloc] init];
    [_bottomSeparatorView setBackgroundColor:SEPARATOR_COLOR];
    [self.view addSubview:_bottomSeparatorView];
    
    [self.noDataLabel setText:NSLocalizedString(@"Todo list for task is empty", nil)];
    
    _doneButton = [[ExtendedButton alloc] init];
    _doneButton.layer.cornerRadius = 4.0f;
    _doneButton.layer.borderWidth = 0.5f;
    [_doneButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [_doneButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:16]];
    [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [_doneButton setBackgroundColor:IQ_CELADON_COLOR];
    [_doneButton setBackgroundColor:IQ_CELADON_COLOR_HIGHLIGHTED forState:UIControlStateHighlighted];
    [_doneButton setBackgroundColor:IQ_CELADON_COLOR_DISABLED forState:UIControlStateDisabled];
    _doneButton.layer.borderColor = _doneButton.backgroundColor.CGColor;
    [_doneButton setClipsToBounds:YES];
    [_doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_doneButton];
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
    [self updateNoDataLabelVisibility];
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

    CGRect actualBounds = self.view.bounds;

    _bottomSeparatorView.frame = CGRectMake(actualBounds.origin.x,
                                            actualBounds.origin.y + actualBounds.size.height - BOTTOM_VIEW_HEIGHT,
                                            actualBounds.size.width,
                                            SEPARATOR_HEIGHT);
    
    CGSize clearButtonSize = CGSizeMake(300, 40);
    _doneButton.frame = CGRectMake(actualBounds.origin.x + (actualBounds.size.width - clearButtonSize.width) / 2.0f,
                                   actualBounds.origin.y + actualBounds.size.height - clearButtonSize.height - 10.0f,
                                   clearButtonSize.width,
                                   clearButtonSize.height);

    [self layoutTabelView];
    
    self.noDataLabel.frame = self.tableView.frame;
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
    BOOL isCellChecked = ![self.model isItemCheckedAtIndexPath:indexPath];
    [self.model makeItemAtIndexPath:indexPath checked:isCellChecked];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_editableIndexPath == nil) {
        return ([self.model isItemSelectableAtIndexPath:indexPath]) ? indexPath : nil;
    }
    return nil;
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    NSString * newString = [[textView.text stringByReplacingCharactersInRange:range withString:text]
                                           stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    if (([newString length] <= MAX_NUMBER_OF_CHARACTERS)) {
        id<TodoItem> item = [self.model itemAtIndexPath:_editableIndexPath];
        item.title = newString;
        textView.text = newString;
        
        [self updateCellFrameIfNeed];
    }
    
    return NO;
}

#pragma mark - SWTableViewCell Delegate

- (void)swipeableTableViewCell:(TodoListItemCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath * prevEditIndexPath = _editableIndexPath;
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    if (index == 0) {
        if (!cell.titleTextView.editable) {
            _editableIndexPath = indexPath;
            cell.titleTextView.editable = YES;
            [cell.titleTextView becomeFirstResponder];
            [self.tableView scrollToRowAtIndexPath:indexPath
                                  atScrollPosition:UITableViewScrollPositionBottom
                                          animated:YES];
            
            [self endEditeCellAtindexPath:prevEditIndexPath];
        }
        
        [cell hideUtilityButtonsAnimated:NO];
    }
    else {
        [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                           message:NSLocalizedString(@"You agree to remove the selected item?", nil)
                 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                 otherButtonTitles:@[NSLocalizedString(@"OK", nil)]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == 1) {
                                  [self.model deleteItemAtIndexPath:indexPath];
                              }
                          }];
    }
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
    [self endEditeCellAtindexPath:_editableIndexPath];
    _editableIndexPath = nil;

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
    NSIndexPath * prevEditIndexPath = _editableIndexPath;

    __weak typeof(self) weakSelf = self;
    [self.model createItemWithCompletion:^(id<TodoItem> item, NSError *error) {
        if (item) {
            _editableIndexPath = [weakSelf.model indexPathOfObject:item];
            
            [CATransaction begin];
            
            [CATransaction setCompletionBlock: ^{
                TodoListItemCell * cell = (TodoListItemCell*)[weakSelf.tableView cellForRowAtIndexPath:_editableIndexPath];
                [cell hideUtilityButtonsAnimated:NO];
                cell.titleTextView.editable = YES;
                [cell.titleTextView becomeFirstResponder];
                
                [self endEditeCellAtindexPath:prevEditIndexPath];
            }];

            [weakSelf.tableView scrollToRowAtIndexPath:_editableIndexPath
                                  atScrollPosition:UITableViewScrollPositionBottom
                                          animated:NO];
            [CATransaction commit];
        }
    }];
}

- (void)layoutTabelView {
    CGRect actualBounds = self.view.bounds;
    
    CGFloat tableOffset = (_tableBottomMarging > 0) ? _tableBottomMarging : BOTTOM_VIEW_HEIGHT;
    self.tableView.frame = CGRectMake(actualBounds.origin.x,
                                      actualBounds.origin.y,
                                      actualBounds.size.width,
                                      actualBounds.origin.y + actualBounds.size.height - tableOffset);
}

- (void)doneButtonAction:(UIButton*)sender {
    Boolean validationSuccess = YES;
    if ([self.model.items count] > 0) {
        NSArray * todoTitles = [self.model.items valueForKey:@"title"];
        for (NSString * title in todoTitles) {
            if ([NSNull null] == (NSNull*)title || [title length] == 0 ||
                [[title stringByReplacingOccurrencesOfString:@" " withString:@""] length] == 0) {
                
                [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                                   message:NSLocalizedString(@"Item name can not be empty", nil)
                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                         otherButtonTitles:nil
                                  tapBlock:nil];
                validationSuccess = NO;
                break;
            }
        }
    }
    
    if (validationSuccess) {
        if (self.model.hasChanges) {
            [self showActivityIndicator];
            [self.model saveChangesWithCompletion:^(NSError *error) {
                if (!error) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                [self hideActivityIndicator];
            }];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)updateCellFrameIfNeed {
    TodoListItemCell * cell = (TodoListItemCell*)[self.tableView cellForRowAtIndexPath:_editableIndexPath];
    CGFloat cellHeight = [TodoListItemCell heightForItem:cell.item width:self.model.cellWidth];
    
    if (cell.frame.size.height != cellHeight) {
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        [self.tableView scrollToRowAtIndexPath:_editableIndexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];
    }
}

- (void)endEditeCellAtindexPath:(NSIndexPath*)indexPath {
    if (indexPath) {
        TodoListItemCell * cell = (TodoListItemCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.titleTextView.editable = NO;
    }
}

@end
