//
//  TaskExecutersController.m
//  IQ300
//
//  Created by Tayphoon on 20.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TaskExecutersController.h"
#import "ExecutersGroupSection.h"
#import "IQSelectableTextCell.h"
#import "TaskExecutor.h"
#import "IQSession.h"
#import "IQTaskDataHolder.h"
#import "IQCommunity.h"
#import "ExtendedButton.h"
#import "ExTextField.h"
#import "BottomLineView.h"
#import "UIScrollView+PullToRefreshInsert.h"

#define SEPARATOR_HEIGHT 0.5f
#define SEPARATOR_COLOR [UIColor colorWithHexInt:0xcccccc]
#define BOTTOM_VIEW_HEIGHT 60
#define HEADER_HEIGHT 50.0f
#define DISPATCH_DELAY 0.0

@interface TaskExecutersController () {
    UIView * _bottomSeparatorView;
    ExtendedButton * _doneButton;
    ExecutersGroupSection * _headerView;
    ExTextField * _userNameTextField;
    BottomLineView * _containerView;
    UIEdgeInsets _userNameInset;
    CGFloat _tableViewBottomMarging;
}

@end

@implementation TaskExecutersController

@dynamic model;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Communities", nil);
        
        _userNameInset = UIEdgeInsetsMake(0.0f, 13.0f, 0.0f, 13.0f);
        self.model = [[TaskExecutorsModel alloc] init];
    }
    return self;
}

- (BOOL)isLeftMenuEnabled {
    return NO;
}

- (void)setFieldValue:(NSArray *)fieldValue {
    _fieldValue = fieldValue;
    self.model.executors = _fieldValue;
}

- (void)setTask:(IQTaskDataHolder *)task {
    _task = task;
    self.model.communityId = _task.community.communityId;
    self.model.editingMode = (_task.taskId != nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexInt:0xf6f6f6];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    _bottomSeparatorView = [[UIView alloc] init];
    [_bottomSeparatorView setBackgroundColor:SEPARATOR_COLOR];
    [self.view addSubview:_bottomSeparatorView];

    _doneButton = [[ExtendedButton alloc] init];
    _doneButton.layer.cornerRadius = 4.0f;
    _doneButton.layer.borderWidth = 0.5f;
    [_doneButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [_doneButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:16]];
    [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [_doneButton setBackgroundColor:IQ_CELADON_COLOR];
    [_doneButton setBackgroundColor:IQ_CELADON_COLOR_HIGHLIGHTED forState:UIControlStateHighlighted];
    [_doneButton setBackgroundColor:IQ_CELADON_COLOR_DISABLED forState:UIControlStateDisabled];
    _doneButton.layer.borderColor = _doneButton.backgroundColor.CGColor;
    [_doneButton setClipsToBounds:YES];
    [_doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_doneButton];
    
    _headerView = [[ExecutersGroupSection alloc] init];
    _headerView.title = NSLocalizedString(@"Select all", nil);
    _headerView.selected = self.model.isAllSelected;
    _headerView.bottomLineColor = SEPARATOR_COLOR;
    _headerView.showLeftView = NO;
    
    __weak typeof(self) weakSelf = self;
    [_headerView setActionBlock:^(ExecutersGroupSection *header) {
        weakSelf.model.selectAll = !header.selected;
    }];
    [self.view addSubview:_headerView];
    
    _containerView = [[BottomLineView alloc] init];
    _containerView.bottomLineColor = SEPARATOR_COLOR;
    _containerView.bottomLineHeight = 0.5f;
    [_containerView setBackgroundColor:[UIColor clearColor]];

    _userNameTextField = [[ExTextField alloc] init];
    _userNameTextField.font = [UIFont fontWithName:IQ_HELVETICA size:16];
    _userNameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _userNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"User name", nil)
                                                                               attributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexInt:0x8d8c8d]}];
    [_userNameTextField addTarget:self
                           action:@selector(textFieldDidChange:)
                 forControlEvents:UIControlEventEditingChanged];
    
    _userNameTextField.delegate = (id<UITextFieldDelegate>)self;

    [_containerView addSubview:_userNameTextField];
    [self.view addSubview:_containerView];
    
    [self.tableView
     insertPullToRefreshWithActionHandler:^{
         [weakSelf reloadDataWithCompletion:^(NSError *error) {
             [[weakSelf.tableView pullToRefreshForPosition:SVPullToRefreshPositionTop] stopAnimating];
         }];
     }
     position:SVPullToRefreshPositionTop];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    if([IQSession defaultSession]) {
        [self.model updateModelWithCompletion:^(NSError *error) {
            if(!error) {
                _headerView.selected = self.model.selectAll;
                [self.tableView reloadData];
            }
        }];
    }
    [self.model setSubscribedToNotifications:YES];
    _headerView.hidden = (self.task.taskId != nil);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.model setSubscribedToNotifications:NO];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect actualBounds = self.view.bounds;
    
    CGRect containerRect = CGRectMake(actualBounds.origin.x,
                                      actualBounds.origin.y,
                                      actualBounds.size.width,
                                      40.0f);
    _containerView.frame = UIEdgeInsetsInsetRect(containerRect, _userNameInset);
    CGFloat fieldHeight = 19;
    _userNameTextField.frame = CGRectMake(0.0f,
                                          _containerView.frame.size.height - fieldHeight,
                                          _containerView.frame.size.width,
                                          fieldHeight);

    CGRect headerRect = CGRectMake(actualBounds.origin.x,
                                   CGRectBottom(_containerView.frame),
                                   actualBounds.size.width,
                                   (self.task.taskId == nil) ? HEADER_HEIGHT : 0.0f);
    _headerView.frame = headerRect;
    
    [self layoutTableView];
}


#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IQSelectableTextCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    TaskExecutor * item = [self.model itemAtIndexPath:indexPath];
    cell.titleTextView.text = item.executorName;
    
    BOOL isCellSelected = [self.model isItemSelectedAtIndexPath:indexPath];
    [cell setAccessoryType:(isCellSelected) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];
    
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.model.cellWidth = tableView.frame.size.width;
    return [self.model heightForItemAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [ExecutersGroupSection heightForTitle:[self.model titleForSection:section]
                                           width:tableView.frame.size.width];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self viewForHeaderInSection:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isItemSelected = [self.model isItemSelectedAtIndexPath:indexPath];
    [self.model makeItemAtIndexPath:indexPath selected:!isItemSelected];
}

#pragma mark - IQTableModel Delegate

- (void)modelDidChangeContent:(TaskExecutorsModel*)model {
    [super modelDidChangeContent:model];
    
    _headerView.selected = model.isAllSelected;
}

- (void)modelDidChanged:(TaskExecutorsModel*)model {
    [super modelDidChanged:model];
    
    _headerView.selected = model.isAllSelected;
}

#pragma mark - Keyboard Helpers

- (void)onKeyboardWillShow:(NSNotification *)notification {
    [self makeInputViewTransitionWithDownDirection:NO notification:notification];
}

- (void)onKeyboardWillHide:(NSNotification *)notification {
    [self makeInputViewTransitionWithDownDirection:YES notification:notification];
}

#pragma mark - TextField Delegate

- (void)textFieldDidChange:(UITextField *)textField {
    [self filterWithText:textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Private methods

- (void)makeInputViewTransitionWithDownDirection:(BOOL)down notification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _tableViewBottomMarging = down ? 0 : MIN(keyboardRect.size.width, keyboardRect.size.height);
  
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [self layoutTableView];
    
    [UIView commitAnimations];
}

- (void)backButtonAction:(UIButton*)sender {
    BOOL selectionIsEmpty = (_fieldValue == nil && self.model.executors == nil);
    if ([_fieldValue count] != [self.model.executors count] ||
        (!selectionIsEmpty && ![_fieldValue isEqualToArray:self.model.executors])) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                           message:NSLocalizedString(@"Save changes?", nil)
                 cancelButtonTitle:NSLocalizedString(@"Сancellation", nil)
                 otherButtonTitles:@[NSLocalizedString(@"Yes", nil), NSLocalizedString(@"No", nil)]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == 1 || buttonIndex == 2) {
                                  if (buttonIndex == 1) {
                                      [self saveChanges];
                                  }
                                  [self.navigationController popViewControllerAnimated:YES];
                              }
                          }];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)doneButtonAction:(UIButton*)sender {
    [self saveChanges];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveChanges {
    NSArray * items = ([self.model.executors count] > 0) ? self.model.executors : nil;
    if ([self.delegate respondsToSelector:@selector(taskFieldEditController:didChangeFieldValue:)]) {
        [self.delegate taskFieldEditController:self didChangeFieldValue:items];
    }
}

- (UIView *)viewForHeaderInSection:(NSInteger)section {
    ExecutersGroupSection * sectionView = [[ExecutersGroupSection alloc] init];
    sectionView.title = [self.model titleForSection:section];
    sectionView.selected = [self.model isSectionSelected:section];
    
    __weak typeof(self) weakSelf = self;
    [sectionView setActionBlock:^(ExecutersGroupSection *header) {
        [weakSelf.model makeSection:section selected:!header.isSelected];
        header.selected = [weakSelf.model isSectionSelected:section];
    }];
    
    return sectionView;
}

- (void)layoutTableView {
    CGRect actualBounds = self.view.bounds;
    
    _bottomSeparatorView.frame = CGRectMake(actualBounds.origin.x,
                                            actualBounds.origin.y + actualBounds.size.height - BOTTOM_VIEW_HEIGHT - _tableViewBottomMarging,
                                            actualBounds.size.width,
                                            SEPARATOR_HEIGHT);
    
    CGSize clearButtonSize = CGSizeMake(300, 40);
    _doneButton.frame = CGRectMake(actualBounds.origin.x + (actualBounds.size.width - clearButtonSize.width) / 2.0f,
                                   actualBounds.origin.y + actualBounds.size.height - clearButtonSize.height - 10.0f - _tableViewBottomMarging,
                                   clearButtonSize.width,
                                   clearButtonSize.height);

    
    CGFloat tableY = CGRectBottom(_headerView.frame);
    self.tableView.frame = CGRectMake(actualBounds.origin.x,
                                      tableY,
                                      actualBounds.size.width,
                                      actualBounds.size.height - BOTTOM_VIEW_HEIGHT - tableY - _tableViewBottomMarging);
    
    self.noDataLabel.frame = self.tableView.frame;
}

- (void)filterWithText:(NSString *)text {
    [self.model setFilter:text];
}

@end
