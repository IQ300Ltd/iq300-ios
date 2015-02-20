//
//  ViewController.m
//  IQ300
//
//  Created by Tayphoon on 06.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <MMDrawerController/UIViewController+MMDrawerController.h>

#import "TasksController.h"
#import "UIViewController+LeftMenu.h"
#import "TasksView.h"
#import "UITabBarItem+CustomBadgeView.h"
#import "IQBadgeView.h"
#import "TasksMenuModel.h"
#import "IQTask.h"
#import "TaskCell.h"

@interface TasksController () {
    TasksView * _mainView;
    TasksMenuModel * _menuModel;
}

@end

@implementation TasksController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Tasks", nil);
        UIImage * barImage = [[UIImage imageNamed:@"tasks_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage * barImageSel = [[UIImage imageNamed:@"tasks_tab_sel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:barImage selectedImage:barImageSel];
        float imageOffset = 6;
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0, -imageOffset, 0);
        
        IQBadgeStyle * style = [IQBadgeStyle defaultStyle];
        style.badgeTextColor = [UIColor whiteColor];
        style.badgeFrameColor = [UIColor whiteColor];
        style.badgeInsetColor = [UIColor colorWithHexInt:0xe74545];
        style.badgeFrame = YES;
        
        IQBadgeView * badgeView = [IQBadgeView customBadgeWithString:nil withStyle:style];
        badgeView.badgeMinSize = 20;
        badgeView.frameLineHeight = 1.0f;
        badgeView.badgeTextFont = [UIFont fontWithName:IQ_HELVETICA size:9];
        
        self.tabBarItem.customBadgeView = badgeView;
        self.tabBarItem.badgeOrigin = CGPointMake(61.5f, 3.5f);
        
        self.model = [[TasksModel alloc] init];
        _menuModel = [[TasksMenuModel alloc] init];
    }
    return self;
}

- (void)loadView {
    _mainView = [[TasksView alloc] init];
    self.view = _mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_menuModel selectItemAtIndexPath:[NSIndexPath indexPathForRow:0
                                                         inSection:0]];
    
    [self.leftMenuController setMenuResponder:self];
    [self.leftMenuController setTableHaderHidden:YES];
    [self.leftMenuController setModel:_menuModel];
    [self.leftMenuController reloadMenuWithCompletion:nil];
    [self.model updateModelWithCompletion:nil];
}

- (UITableView*)tableView {
    return _mainView.tableView;
}

#pragma mark - Menu Responder Delegate

- (void)menuController:(MenuViewController*)controller didSelectMenuItemAtIndexPath:(NSIndexPath*)indexPath {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    [self.model updateModelWithCompletion:nil];
}


- (void)updateGlobalCounter {
    
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    IQTask * task = [self.model itemAtIndexPath:indexPath];
    cell.item = task;
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


@end
