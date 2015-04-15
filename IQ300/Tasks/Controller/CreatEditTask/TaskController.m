//
//  TaskController.m
//  IQ300
//
//  Created by Tayphoon on 14.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <ActionSheetPicker-3.0/ActionSheetDatePicker.h>

#import "TaskController.h"
#import "IQSession.h"
#import "IQService+Tasks.h"
#import "IQEditableTextCell.h"
#import "IQTask.h"
#import "ExtendedButton.h"

#define MAX_NUMBER_OF_CHARACTERS 255
#define SEPARATOR_HEIGHT 0.5f
#define SEPARATOR_COLOR [UIColor colorWithHexInt:0xcccccc]
#define BOTTOM_VIEW_HEIGHT 65

@interface TaskController() {
    CGFloat _tableBottomMarging;
    NSIndexPath * _editableIndexPath;
    UIView * _bottomSeparatorView;
    ExtendedButton * _doneButton;
}

@end

@implementation TaskController

@dynamic model;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Task", nil);
        _editableIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
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
    
    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    _bottomSeparatorView = [[UIView alloc] init];
    [_bottomSeparatorView setBackgroundColor:SEPARATOR_COLOR];
    [self.view addSubview:_bottomSeparatorView];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self reloadModel];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
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
    _doneButton.frame = CGRectMake(actualBounds.origin.x + (actualBounds.size.width - doneButtonSize.width) / 2.0f,
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
    
    NSString * text = [self.model itemAtIndexPath:indexPath];
    cell.titleTextView.text = text;
    cell.titleTextView.delegate = (id<UITextViewDelegate>)self;
    cell.titleTextView.placeholder = [self.model placeholderForItemAtIndexPath:indexPath];
    cell.titleTextView.editable = ([indexPath isEqual:_editableIndexPath]);
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IQEditableTextCell * cell = (IQEditableTextCell*)[tableView cellForRowAtIndexPath:_editableIndexPath];
    if (cell.titleTextView.isFirstResponder && ![indexPath isEqual:_editableIndexPath]) {
        //hide keyboard
        [cell.titleTextView resignFirstResponder];
    }
    
    if (indexPath.row > 3) {
        [self showDataPickerForIndexPath:indexPath];
    }
    else if(indexPath.row != 0) {
        
    }
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString * newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (([newString length] <= MAX_NUMBER_OF_CHARACTERS)) {
        self.model.task.title = newString;
        textView.text = newString;
        [self.model updateModelWithCompletion:nil];
        
        [self updateCellFrameIfNeed];
    }
    
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
    _tableBottomMarging = down ? BOTTOM_VIEW_HEIGHT : MIN(keyboardRect.size.width, keyboardRect.size.height);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [self layoutTabelView];
    
    [UIView commitAnimations];
}

- (void)reloadModel {
    if([IQSession defaultSession]) {
        [self.model updateModelWithCompletion:^(NSError *error) {
            if(!error) {
                [self.tableView reloadData];
            }
        }];
    }
}

- (void)backButtonAction:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonAction:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)layoutTabelView {
    CGRect actualBounds = self.view.bounds;
    
    self.tableView.frame = CGRectMake(actualBounds.origin.x,
                                      actualBounds.origin.y,
                                      actualBounds.size.width,
                                      actualBounds.origin.y + actualBounds.size.height - _tableBottomMarging);
}

- (void)updateCellFrameIfNeed {
    IQEditableTextCell * cell = (IQEditableTextCell*)[self.tableView cellForRowAtIndexPath:_editableIndexPath];
    CGFloat cellHeight = [IQEditableTextCell heightForItem:cell.titleTextView.text
                                                     width:self.model.cellWidth];
    
    if (cell.frame.size.height != cellHeight) {
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        [self.tableView scrollToRowAtIndexPath:_editableIndexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];
    }
}

- (void)showDataPickerForIndexPath:(NSIndexPath*)indexPath {
    BOOL isBeginDateEdit = (indexPath.row == 4);
    NSString * title = [NSString stringWithFormat:@"%@:", NSLocalizedString((isBeginDateEdit) ? @"Begins" : @"Perform to", nil)];
    NSDate * selectedDate = (isBeginDateEdit) ? self.model.task.startDate : self.model.task.endDate;
    
    __weak typeof (self) weakSelf = self;
    ActionDateDoneBlock doneBlock = ^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        if (isBeginDateEdit) {
            weakSelf.model.task.startDate = selectedDate;
        }
        else {
            weakSelf.model.task.endDate = selectedDate;
        }
        [weakSelf.model updateModelWithCompletion:^(NSError *error) {
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
            [weakSelf.tableView endUpdates];
        }];
    };
    
    ActionSheetDatePicker * picker = [[ActionSheetDatePicker alloc] initWithTitle:title
                                                                   datePickerMode:UIDatePickerModeDateAndTime
                                                                     selectedDate:selectedDate
                                                                        doneBlock:doneBlock
                                                                      cancelBlock:nil
                                                                           origin:self.view];
    
#ifdef USE_DEFAULT_LOCALIZATION
    picker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
#endif
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    
    if (isBeginDateEdit) {
        dayComponent.minute = -1;
        picker.maximumDate = [calendar dateByAddingComponents:dayComponent
                                                       toDate:self.model.task.endDate
                                                      options:0];
    }
    else {
        dayComponent.minute = 1;
        picker.minimumDate = [calendar dateByAddingComponents:dayComponent
                                                       toDate:self.model.task.startDate
                                                      options:0];
    }
    [picker setDoneButton:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)
                                                           style:UIBarButtonItemStylePlain
                                                          target:nil
                                                          action:nil]];
    
    [picker setCancelButton:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil)
                                                             style:UIBarButtonItemStylePlain
                                                            target:nil
                                                            action:nil]];
    [picker showActionSheetPicker];
}

@end
