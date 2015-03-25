//
//  TaskController.m
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TInfoController.h"
#import "TInfoHeaderView.h"
#import "TodoListSectionView.h"
#import "IQTask.h"
#import "TodoListItemCell.h"
#import "IQBadgeView.h"
#import "UITabBarItem+CustomBadgeView.h"
#import "IQService+Tasks.h"
#import "TaskPolicyInspector.h"

@interface TInfoController() <TInfoHeaderViewDelegate, UIActionSheetDelegate> {
    TInfoHeaderView * _headerView;
    TodoListModel * _todoListModel;
    TodoListSectionView * _checkListHeader;
}

@end

@implementation TInfoController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Task", nil);

        UIImage * barImage = [[UIImage imageNamed:@"task_info_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        float imageOffset = 6;
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:barImage selectedImage:barImage];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0, -imageOffset, 0);
        
        IQBadgeStyle * style = [IQBadgeStyle defaultStyle];
        style.badgeTextColor = [UIColor whiteColor];
        style.badgeFrameColor = [UIColor whiteColor];
        style.badgeInsetColor = [UIColor colorWithHexInt:0x338cae];
        style.badgeFrame = YES;
        
        IQBadgeView * badgeView = [IQBadgeView customBadgeWithString:nil withStyle:style];
        badgeView.badgeMinSize = 15;
        badgeView.frameLineHeight = 1.0f;
        badgeView.badgeTextFont = [UIFont fontWithName:IQ_HELVETICA size:9];
        
        self.tabBarItem.customBadgeView = badgeView;
        self.tabBarItem.badgeOrigin = CGPointMake(37.5f, 3.5f);

        _todoListModel = [[TodoListModel alloc] init];
        _todoListModel.section = 1;
        self.model = _todoListModel;
    }
    return self;
}

- (NSString*)category {
    return @"details";
}

- (void)setBadgeValue:(NSNumber *)badgeValue {
    self.tabBarItem.badgeValue = BadgTextFromInteger([badgeValue integerValue]);
}

- (NSNumber*)badgeValue {
    return @([self.tabBarItem.badgeValue integerValue]);
}

- (void)setTask:(IQTask *)task {
    _task = task;
    
    self.model.taskId = _task.taskId;
    self.model.items = [_task.todoItems array];

    if (self.isViewLoaded) {
        [_headerView setupByTask:_task];
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.tableView.tableHeaderView = _headerView;
    self.tableView.tableFooterView = [UIView new];
    
    _headerView = [[TInfoHeaderView alloc] init];
    _headerView.delegate = self;
    
    _checkListHeader = [[TodoListSectionView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if([self.policyInspector isActionAvailable:@"update" inCategory:self.category]) {
        UIBarButtonItem * editButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit_white_ico.png"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(editButtonAction:)];
        self.parentViewController.navigationItem.rightBarButtonItem = editButton;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? 0 : [self.model numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TodoListItemCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    IQTodoItem * item = [self.model itemAtIndexPath:indexPath];
    cell.item = item;
    
    BOOL isCellChecked = [self.model isItemCheckedAtIndexPath:indexPath];
    [cell setAccessoryType:(isCellChecked) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];
    
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (section == 0) ? [TInfoHeaderView heightForTask:self.task width:self.tableView.frame.size.width] : 50.0f;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return (section == 0) ? _headerView : _checkListHeader;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isCellChecked = [self.model isItemCheckedAtIndexPath:indexPath];
    [self.model makeItemAtIndexPath:indexPath checked:!isCellChecked];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Enable or disable change checked state
    if([self.policyInspector isActionAvailable:@"change_state" inCategory:@"todoItems"]) {
        return ([self.model isItemSelectableAtIndexPath:indexPath]) ? indexPath : nil;
    }
    return nil;
}

#pragma mark - TInfoHeaderView Delegate

- (void)headerView:(TInfoHeaderView*)headerView tapActionAtIndex:(NSInteger)actionIndex {
    NSArray * actions = [self.task.availableActions allObjects];
    NSString * action = (actionIndex < [actions count]) ? actions[actionIndex] : nil;
    
    if ([action length] > 0) {
        if([action isEqualToString:@"refuse"]) {
            UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:NSLocalizedString(@"Not in my competence", nil),
                                                                              NSLocalizedString(@"Incorrect task time", nil),
                                                                              NSLocalizedString(@"Not enough information", nil), nil];
            [actionSheet showInView:self.view];
        }
        else {
            [[IQService sharedService] changeStatus:action
                                      forTaskWithId:self.task.taskId
                                             reason:nil
                                            handler:^(BOOL success, IQTask * task, NSData *responseData, NSError *error) {
                                                self.task = task;
                                            }];
        }
    }
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    static NSDictionary * reasons = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        reasons = @{
                                @(0) : @"not_in_my_competence",
                                @(1) : @"incorrect_task_time",
                                @(2) : @"not_enough_information"
                                };
    });
    
    NSString * reason = [reasons objectForKey:@(buttonIndex)];
    if(reason) {
        [[IQService sharedService] changeStatus:@"refuse"
                                  forTaskWithId:self.task.taskId
                                         reason:reason
                                        handler:^(BOOL success, IQTask * task, NSData *responseData, NSError *error) {
                                            self.task = task;
                                        }];
    }
}

#pragma mark - Private methods

- (void)editButtonAction:(UIButton*)sender {
    
}

@end
