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

@interface TInfoController () {
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
        
        _todoListModel = [[TodoListModel alloc] init];
        _todoListModel.section = 1;
        self.model = _todoListModel;
    }
    return self;
}

- (void)setTask:(IQTask *)task {
    _task = task;
    
    self.model.items = [self.task.todoItems array];

    if (self.isViewLoaded) {
        [_headerView setupByTask:self.task];
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.tableView.tableHeaderView = _headerView;
    self.tableView.tableFooterView = [UIView new];
    
    _headerView = [[TInfoHeaderView alloc] init];
    _checkListHeader = [[TodoListSectionView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem * editButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit_white_ico.png"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(editButtonAction:)];
    self.parentViewController.navigationItem.rightBarButtonItem = editButton;
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

#pragma mark - Private methods

- (void)editButtonAction:(UIButton*)sender {
    
}

@end
