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
#import "IQTaskDataHolder.h"
#import "ExtendedButton.h"
#import "TaskDescriptionController.h"
#import "CommunitiesController.h"
#import "TaskExecutersController.h"
#import "IQCommunity.h"
#import "NSDate+CupertinoYankee.h"
#import "TaskComplexityController.h"
#import "IQEstimatedTimeCell.h"
#import "IQTask.h"
#import "IQTaskParentAccessItem.h"

#ifdef IPAD
#import "IQDoubleDetailsTextCell.h"
#import "IQComplexityEstimatedTimeDoubleCell.h"
#endif

#import "IQTextCell.h"
#import "IQMultipleCellsCell.h"

#import "IQTaskItems.h"
#import "IQMultipleCellsCell.h"
#import "IQEstimatedTimeCell.h"

#define SEPARATOR_HEIGHT 0.5f
#define SEPARATOR_COLOR [UIColor colorWithHexInt:0xcccccc]
#define BOTTOM_VIEW_HEIGHT 0

@interface TaskController() <IQEstimatedTimeCellDelegate, IQMultipleCellsCellDelegate, IQEstimatedTimeCellDelegate, IQTextCellDelegate> {
    NSIndexPath *_editingIndexPath;
    UITableViewCell *_editingCell;
    id _editingItem;
    
    CGFloat _tableBottomMarging;
}

@end

@implementation TaskController

@dynamic model;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _tableBottomMarging = BOTTOM_VIEW_HEIGHT;
    }
    return self;
}

- (BOOL)isLeftMenuEnabled {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = (self.model.task.taskId == nil) ? (self.model.task.parentTaskId == nil ? NSLocalizedString(@"Creating task", nil) :
                                                                                        NSLocalizedString(@"Creating subtask", nil)) :
                                                   NSLocalizedString(@"Editing task", nil);

    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [UIView new];
    
    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mark_tab_item.png"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(doneButtonAction:)];
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
    
    [self reloadModel];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
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
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    if ([cell respondsToSelector:@selector(setItem:)]) {
        [cell performSelector:@selector(setItem:) withObject:[self.model itemAtIndexPath:indexPath]];
    }

    if ([cell respondsToSelector:@selector(setDelegate:)]) {
        [cell performSelector:@selector(setDelegate:) withObject:self];
    }
    
#ifdef IPAD
    if ([cell isKindOfClass:[IQMultipleCellsCell class]]) {
        IQMultipleCellsCell *multiCell = (IQMultipleCellsCell *)cell;
        for (UITableViewCell *nestedCell in multiCell.cells) {
            if ([nestedCell respondsToSelector:@selector(setDelegate:)]) {
                [nestedCell performSelector:@selector(setDelegate:) withObject:self];
            }
        }
    }
#endif
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    id item = [self.model itemAtIndexPath:indexPath];
    [self performActionForItem:item cell:cell atIndexPath:indexPath];
}

- (void)multipleCellsCell:(IQMultipleCellsCell *)cell didSelectSubcellAtIndex:(NSUInteger)index {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSArray *items = [self.model itemAtIndexPath:indexPath];
    id item = [items objectAtIndex:index];
    UITableViewCell *nestedCell = [cell.cells objectAtIndex:index];
    [self performActionForItem:item cell:nestedCell atIndexPath:indexPath];
}

- (void)performActionForItem:(id)item cell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    if (![_editingCell isEqual:cell]) {
        [_editingCell endEditing:YES];
        
        _editingCell = cell;
        _editingItem = item;
        _editingIndexPath = indexPath;
        
        if ([item isKindOfClass:[IQTaskParentAccessItem class]]) {
            IQTaskParentAccessItem *accessItem = (IQTaskParentAccessItem *)item;
            [self.model updateItem:accessItem atIndexPath:_editingIndexPath withValue:@(!accessItem.selected)];
            _editingCell = nil;
            _editingItem = nil;
            _editingIndexPath = nil;
        }
        else {
            UIViewController <TaskFieldEditController> *controller = [self controllerForItem:item];
            if (controller) {
                controller.task = self.model.task;
                controller.delegate = self;
                [self.navigationController pushViewController:controller animated:YES];
            }
            else if ([item isKindOfClass:[IQTaskStartDateItem class]] ||
                     [item isKindOfClass:[IQTaskEndDateItem class]]){
                [self showDataPicker];
            }

        }
    }
}

#pragma mark - IQTextCellDelegate

- (BOOL)textCell:(IQTextCell *)cell textViewShouldBeginEditing:(UITextView *)textView {
    _editingIndexPath = [self.tableView indexPathForCell:cell];
    if (!_editingIndexPath) {
        IQMultipleCellsCell *multiCell = nil;
        UIView *superview = cell.superview;
        while (![superview isKindOfClass:[IQMultipleCellsCell class]]) {
            superview = superview.superview;
        }
        multiCell = (IQMultipleCellsCell *)superview;
        _editingIndexPath = [self.tableView indexPathForCell:multiCell];
        
        NSArray *items = [self.model itemAtIndexPath:_editingIndexPath];
        _editingItem = [items objectAtIndex:[multiCell.cells indexOfObject:cell]];
    }
    else {
        _editingItem = [self.model itemAtIndexPath:_editingIndexPath];
    }
    _editingCell = cell;
    return YES;
}

- (BOOL)textCell:(IQTextCell *)cell textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    //Disable line wrapping text for specific cells
    if (textView.returnKeyType == UIReturnKeyDone && [text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    NSString * newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (([newString length] <= [self.model maxNumberOfCharactersForPath:_editingIndexPath])) {
        [self.model updateItem:_editingItem atIndexPath:_editingIndexPath withValue:newString];
        return YES;
    }
    
    return NO;
}

- (void)textCell:(IQTextCell *)cell textViewDidChange:(UITextView *)textView {
    UITextRange *range = textView.selectedTextRange;
    textView.text = textView.text;
    textView.selectedTextRange = range;
    [self updateCellFrameIfNeed];
}

#pragma mark - IQEstemetedTimeCellDelegate

- (BOOL)estimatedTimeCell:(IQEstimatedTimeCell *)cell textFieldShouldBeginEditing:(UITextField *)textField {
    _editingIndexPath = [self.tableView indexPathForCell:cell];
    if (!_editingIndexPath) {
        IQMultipleCellsCell *multiCell = nil;
        UIView *superview = cell.superview;
        while (![superview isKindOfClass:[IQMultipleCellsCell class]]) {
            superview = superview.superview;
        }
        multiCell = (IQMultipleCellsCell *)superview;
        _editingIndexPath = [self.tableView indexPathForCell:multiCell];
        
        NSArray *items = [self.model itemAtIndexPath:_editingIndexPath];
        _editingItem = [items objectAtIndex:[multiCell.cells indexOfObject:cell]];
    }
    else {
        _editingItem = [self.model itemAtIndexPath:_editingIndexPath];
    }
    _editingCell = cell;
    return YES;
}

- (BOOL)estimatedTimeCell:(IQEstimatedTimeCell *)cell textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
    {
        return NO;
    }
    NSString *updatedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (updatedText.length > (textField == cell.hoursTextField ? 3 : 2))
    {
        return !string.length;
    }
    
    if (textField == cell.minutesTextField) {
        if (updatedText.integerValue > 59) {
            return NO;
        }
    }
    
    
    if (textField == cell.hoursTextField) {
        [self.model updateItem:_editingItem
                   atIndexPath:_editingIndexPath
                     withValue:@(updatedText.integerValue * 3600 + cell.minutesTextField.text.integerValue * 60)];
    }
    else {
        [self.model updateItem:_editingItem
                   atIndexPath:_editingIndexPath
                     withValue:@(cell.hoursTextField.text.integerValue * 3600 + updatedText.integerValue * 60)];
    }
    return YES;
}
    
#pragma mark - Keyboard Notifications

- (void)onKeyboardWillShow:(NSNotification *)notification {
    [self makeInputViewTransitionWithDownDirection:NO
                                      notification:notification];
    
    if (_editingIndexPath) {
        [self.tableView scrollToRowAtIndexPath:_editingIndexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];
    }
}

- (void)onKeyboardWillHide:(NSNotification *)notification {
    [self makeInputViewTransitionWithDownDirection:YES
                                      notification:notification];
}

#pragma mark - TaskFieldEditController delegate

- (void)taskFieldEditController:(id<TaskFieldEditController>)controller didChangeFieldValue:(id)value {
    [self.model updateItem:_editingItem atIndexPath:_editingIndexPath withValue:value];
    
    _editingIndexPath = nil;
    _editingCell = nil;
    _editingItem = nil;
}

- (void)didCancelTaskFieldEditController:(id<TaskFieldEditController>)controller {
    _editingCell = nil;
    _editingIndexPath = nil;
    _editingItem = nil;
}

#pragma mark - TaskDescriptionController delegate

- (void)descriptionControllerDidChangedText:(TaskDescriptionController*)controller {
    [self.model updateItem:_editingItem atIndexPath:_editingIndexPath withValue:controller.textView.text];
    
    _editingItem = nil;
    _editingIndexPath = nil;
    _editingCell = nil;
}



#pragma mark - Private methods

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
    if ([self.model modelHasChanges]) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                           message:NSLocalizedString(@"Save changes?", nil)
                 cancelButtonTitle:NSLocalizedString(@"Сancellation", nil)
                 otherButtonTitles:@[NSLocalizedString(@"Yes", nil), NSLocalizedString(@"No", nil)]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == 1 || buttonIndex == 2) {
                                  if (buttonIndex == 1) {
                                      [self doneButtonAction:self.navigationItem.rightBarButtonItem];
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

- (void)doneButtonAction:(UIBarButtonItem*)sender {
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    if ([self.model.task.title length] == 0) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                           message:NSLocalizedString(@"Name can not be empty", nil)
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:nil];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
   }
    else {
        if (self.model.task.taskId == nil) {
            [[IQService sharedService] createTask:self.model.task
                                          handler:^(BOOL success, IQTask * task, NSData *responseData, NSError *error) {
                                              if (success) {
                                                  [GAIService sendEventForCategory:GAITasksListEventCategory
                                                                            action:@"event_action_tasks_list_create_task"];

                                                  [self.navigationController popViewControllerAnimated:YES];
                                              }
                                              else {
                                                  [self proccessServiceError:error];
                                              }
                                              [self.navigationItem.rightBarButtonItem setEnabled:YES];
                                         }];
        }
        else {
            [[IQService sharedService] saveTask:self.model.task
                                        handler:^(BOOL success, IQTask * task, NSData *responseData, NSError *error) {
                                            if (success) {
                                                [GAIService sendEventForCategory:GAITaskEventCategory
                                                                          action:@"event_action_task_edit"];

                                                [self.navigationController popViewControllerAnimated:YES];
                                            }
                                            else {
                                                [self proccessServiceError:error];
                                                [self.navigationItem.rightBarButtonItem setEnabled:YES];
                                            }
                                        }];
        }
    }
}

- (void)layoutTabelView {
    CGRect actualBounds = self.view.bounds;
    
    self.tableView.frame = CGRectMake(actualBounds.origin.x,
                                      actualBounds.origin.y,
                                      actualBounds.size.width,
                                      actualBounds.origin.y + actualBounds.size.height - _tableBottomMarging);
}

- (void)updateCellFrameIfNeed {
    CGFloat cellHeight = [self.model heightForItemAtIndexPath:_editingIndexPath];
    
    if (_editingCell.frame.size.height != cellHeight) {
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        [self.tableView scrollToRowAtIndexPath:_editingIndexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];
    }
}

- (Class)controllerClassForItem:(id)item {
    static NSDictionary * _controllers = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _controllers = @{
#ifndef IPAD
                         NSStringFromClass([IQTaskDescriptionItem class]) : [TaskDescriptionController class],
#endif
                         NSStringFromClass([IQTaskCommunityItem class]) : [CommunitiesController class],
                         NSStringFromClass([IQTaskExecutorsItem class]) : [TaskExecutersController class],
                         NSStringFromClass([IQTaskComplexityItem class]) : [TaskComplexityController class]
                         };
    });
    return  [_controllers objectForKey:NSStringFromClass([item class])];
}

- (UIViewController<TaskFieldEditController>*)controllerForItem:(id)item {
    
    Class controllerClass = [self controllerClassForItem:item];
    if(controllerClass) {
        UIViewController<TaskFieldEditController> * controller = [[controllerClass alloc] init];
        return controller;
    }
    
    return nil;
}

- (void)showDataPicker{
    UIView * showInView = _editingCell;

    BOOL isBeginDateEdit = [_editingItem isKindOfClass:[IQTaskStartDateItem class]];
    NSString * title = [NSString stringWithFormat:@"%@:", NSLocalizedString((isBeginDateEdit) ? @"Begins" : @"Perform to", nil)];
    NSDate * selectedDate = (isBeginDateEdit) ? self.model.task.startDate : self.model.task.endDate;
    
    __weak typeof (self) weakSelf = self;
    ActionDateDoneBlock doneBlock = ^(ActionSheetDatePicker *picker, NSDate * selectedDate, id origin) {
        [weakSelf.model updateItem:_editingItem atIndexPath:_editingIndexPath withValue:selectedDate];
        _editingItem = nil;
        _editingIndexPath = nil;
        _editingCell = nil;
    };
    
    
    
    ActionSheetDatePicker * picker = [[ActionSheetDatePicker alloc] initWithTitle:title
                                                                   datePickerMode:UIDatePickerModeDateAndTime
                                                                     selectedDate:selectedDate
                                                                        doneBlock:doneBlock
                                                                      cancelBlock:^(ActionSheetDatePicker *picker) {
                                                                          _editingCell = nil;
                                                                          _editingIndexPath = nil;
                                                                          _editingItem = nil;
                                                                      } origin:showInView];
    
#ifdef USE_DEFAULT_LOCALIZATION
    picker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
#endif
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    
    if (!isBeginDateEdit) {
        dayComponent.minute = 1;
        picker.minimumDate = [calendar dateByAddingComponents:dayComponent
                                                       toDate:self.model.task.startDate
                                                      options:0];
    }
    
    if (self.model.task.parentTaskId) {
        if (isBeginDateEdit) {
            NSDateComponents *minuteComponents = [[NSDateComponents alloc] init];
            minuteComponents.minute = -1;
            
            picker.minimumDate = _startDateRestriction;
            picker.maximumDate = [calendar dateByAddingComponents:minuteComponents
                                                           toDate:_endDateRestriction
                                                          options:0];
        }
        else {
            picker.maximumDate = _endDateRestriction;
        }
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
