//
//  ConferenceInfoController.m
//  IQ300
//
//  Created by Tayphoon on 13.07.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "ConferenceInfoController.h"
#import "ExtendedButton.h"
#import "ContactsSectionView.h"
#import "IQSession.h"
#import "IQEditableTextCell.h"
#import "ContactPickerController.h"
#import "ContactInfoCell.h"
#import "IQNotificationCenter.h"

#define BOTTOM_VIEW_HEIGHT 60

@interface ConferenceInfoController () <SWTableViewCellDelegate> {
    ExtendedButton * _leaveButton;
    CGFloat _tableViewBottomMarging;
    NSIndexPath * _editableIndexPath;
}

@end

@implementation ConferenceInfoController

@dynamic model;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Group info", nil);
        
        self.model = [[ConferenceInfoModel alloc] init];
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
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    _leaveButton = [[ExtendedButton alloc] init];
    _leaveButton.layer.cornerRadius = 4.0f;
    _leaveButton.layer.borderWidth = 0.5f;
    [_leaveButton setTitle:NSLocalizedString(@"Leave group", nil) forState:UIControlStateNormal];
    [_leaveButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:16]];
    [_leaveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [_leaveButton setBackgroundColor:IQ_CELADON_COLOR];
    [_leaveButton setBackgroundColor:IQ_CELADON_COLOR_HIGHLIGHTED forState:UIControlStateHighlighted];
    [_leaveButton setBackgroundColor:IQ_CELADON_COLOR_DISABLED forState:UIControlStateDisabled];
    _leaveButton.layer.borderColor = _leaveButton.backgroundColor.CGColor;
    [_leaveButton setClipsToBounds:YES];
    [_leaveButton addTarget:self action:@selector(leaveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_leaveButton];

    [self updateModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [self updateRightBarButtonItem];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self layoutTableView];
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell<IQTableCell> * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    if ([cell isKindOfClass:[IQEditableTextCell class]]) {
        IQEditableTextCell * editCell = (IQEditableTextCell*)cell;
        editCell.titleTextView.placeholder = [self.model placeholderForItemAtIndexPath:indexPath];
        editCell.titleTextView.delegate = (id<UITextViewDelegate>)self;
        editCell.titleTextView.editable = [self.model isAdministrator];
    }
    else {
        ContactInfoCell * contactCell = (ContactInfoCell *)cell;
        contactCell.delegate = self;
        [contactCell setDeleteEnabled:[self.model isDeleteEnableForForItemAtIndexPath:indexPath]];
    }

    cell.item = [self.model itemAtIndexPath:indexPath];

    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IQEditableTextCell * cell = (IQEditableTextCell*)[tableView cellForRowAtIndexPath:_editableIndexPath];
    if (cell.titleTextView.isFirstResponder && ![indexPath isEqual:_editableIndexPath]) {
        //hide keyboard
        [cell.titleTextView resignFirstResponder];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.model.cellWidth = tableView.frame.size.width;
    return [self.model heightForItemAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section != 0) {
        return [ContactsSectionView heightForTitle:[self.model titleForSection:section]
                                             width:tableView.frame.size.width];
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return (section != 0) ? [self viewForHeaderInSection:section] : nil;
}

#pragma mark - SWTableViewCell Delegate

- (void)swipeableTableViewCell:(ContactInfoCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                       message:NSLocalizedString(@"You agree to remove the user from the chat?", nil)
             cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
             otherButtonTitles:@[NSLocalizedString(@"OK", nil)]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == 1) {
                              [cell hideUtilityButtonsAnimated:NO];
                              NSArray *buttons = cell.rightUtilityButtons;
                              cell.rightUtilityButtons = nil;
                              
                              __weak typeof(cell) weakCell = cell;
                              [self.model removeMember:cell.item completion:^(NSError * error) {
                                  if (error) {
                                      [self proccessServiceError:error];
                                      weakCell.rightUtilityButtons = buttons;
                                  }
                              }];
                          }
                      }];
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    _editableIndexPath = [self indexPathForCellChildView:textView];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //Disable line wrapping text for specific cells
    if (textView.returnKeyType == UIReturnKeyDone && [text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    NSString * newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (([newString length] <= 255)) {
        textView.text = newString;
        [self.model updateTitle:newString];
        [self updateCellFrameIfNeed];
    }
    
    return NO;
}

#pragma mark - Keyboard Helpers

- (void)onKeyboardWillShow:(NSNotification *)notification {
    [self makeInputViewTransitionWithDownDirection:NO notification:notification];
    
    
    if (_editableIndexPath) {
        [self.tableView scrollToRowAtIndexPath:_editableIndexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];
    }
}

- (void)onKeyboardWillHide:(NSNotification *)notification {
    _editableIndexPath = nil;
    [self makeInputViewTransitionWithDownDirection:YES notification:notification];
}

#pragma mark - ContactPickerController delegate

- (void)contactPickerController:(ContactPickerController*)picker didPickContacts:(NSArray*)contacts {
    if ([contacts count] > 0) {
        NSArray * users = [contacts valueForKey:@"user"];
        
        __weak typeof(self) weakSelf = self;
        [self.model addMembersFromUsers:users completion:^(NSError * error) {
            if (!error) {
                [weakSelf.tableView reloadData];
            }
            else {
                [weakSelf proccessServiceError:error];
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }
}

#pragma mark - Private methods

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
    _tableViewBottomMarging = down ? 0 : inset;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [self layoutTableView];
    
    [UIView commitAnimations];
}

- (void)backButtonAction:(UIButton*)sender {
    if ([self.model.conversationTitle isEqualToString:@""]) {
        [UIAlertView showWithTitle:@""
                           message:NSLocalizedString(@"Group name must not be empty", nil)
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:nil];
        return;
    }
    
    if (![self isString:self.model.conversationTitle equalToString:self.model.conversation.title]) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                           message:NSLocalizedString(@"Save the name of the group?", nil)
                 cancelButtonTitle:NSLocalizedString(@"Сancellation", nil)
                 otherButtonTitles:@[NSLocalizedString(@"Yes", nil), NSLocalizedString(@"No", nil)]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == 1 || buttonIndex == 2) {
                                  if (buttonIndex == 1) {
                                      [self.model saveConversationTitleWithCompletion:^(NSError * error) {
                                          if (!error) {
                                              [self.navigationController popViewControllerAnimated:YES];
                                          }
                                          else {
                                              [self proccessServiceError:error];
                                          }
                                      }];
                                  }
                                  [self.navigationController popViewControllerAnimated:YES];
                              }
                          }];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)leaveButtonAction:(UIButton*)sender {
    [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                       message:NSLocalizedString(@"Are you sure you want to leave the chat?", nil)
             cancelButtonTitle:NSLocalizedString(@"No", nil)
             otherButtonTitles:@[NSLocalizedString(@"Yes", nil)]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == 1) {
                              [self.navigationController popToRootViewControllerAnimated:YES];
                              
                              [self.model leaveConversationWithCompletion:^(NSError * error) {
                                  if (error) {
                                      [self proccessServiceError:error];
                                  }
                              }];
                          }
                      }];
}

- (UIView *)viewForHeaderInSection:(NSInteger)section {
    ContactsSectionView * sectionView = [[ContactsSectionView alloc] init];
    sectionView.title = [self.model titleForSection:section];
    
    return sectionView;
}

- (void)addUserBarButtonAction:(id)sender {
    ContactsModel * model = [[ContactsModel alloc] init];
    model.excludeUserIds = [self.model.users valueForKey:@"userId"];
    
    ContactPickerController * controller = [[ContactPickerController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.model = model;
    controller.delegate = self;
    [controller setDoneButtonTitle:NSLocalizedString(@"Add", nil)];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)layoutTableView {
    CGRect actualBounds = self.view.bounds;
    
    
    CGFloat tableOffset = (!self.model.isAdministrator) ? BOTTOM_VIEW_HEIGHT : 0.0f;
    
    if (!self.model.isAdministrator) {
        CGSize leaveButtonSize = CGSizeMake(300, 40);
        _leaveButton.frame = CGRectMake(actualBounds.origin.x + (actualBounds.size.width - leaveButtonSize.width) / 2.0f,
                                        actualBounds.origin.y + actualBounds.size.height - leaveButtonSize.height - 10.0f - _tableViewBottomMarging,
                                        leaveButtonSize.width,
                                        leaveButtonSize.height);
    }
    else {
        _leaveButton.frame = CGRectZero;
    }
    
    self.tableView.frame = CGRectMake(actualBounds.origin.x,
                                      actualBounds.origin.y,
                                      actualBounds.size.width,
                                      actualBounds.size.height - _tableViewBottomMarging - tableOffset);
    
    self.noDataLabel.frame = self.tableView.frame;
}

- (void)updateModel {
    if([IQSession defaultSession]) {
        [self.model updateModelWithCompletion:^(NSError *error) {
            if(!error) {                
                [self.tableView reloadData];
            }
            
            [self updateNoDataLabelVisibility];
        }];
    }
}

- (void)updateRightBarButtonItem {
    if (self.model.isAdministrator) {
        UIBarButtonItem * addUserBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add_user_icon.png"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(addUserBarButtonAction:)];
        self.navigationItem.rightBarButtonItem = addUserBarButton;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)applicationWillEnterForeground {
    [self updateModel];
}

- (BOOL)isString:(NSString*)firstString equalToString:(NSString*)secondString {
    BOOL stringsIsEmpty = (firstString == nil && secondString == nil);
    return stringsIsEmpty || (!stringsIsEmpty && [firstString isEqualToString:secondString]);
}

@end
