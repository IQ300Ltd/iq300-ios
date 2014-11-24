//
//  NotificationsContoller.m
//  IQ300
//
//  Created by Tayphoon on 11.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "NotificationsContoller.h"
#import "NotificationsView.h"
#import "NotificationsMenuModel.h"
#import "UIViewController+LeftMenu.h"
#import "NotificationsModel.h"
#import "IQNotification.h"
#import "NotificationCell.h"
//#import "UITableView+BottomRefreshControl.h"
//#import "IQRefreshControl.h"

@interface NotificationsContoller() <UITableViewDelegate, UITableViewDataSource> {
    NotificationsView * _mainView;
}

@end

@implementation NotificationsContoller

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        UIImage * barImage = [[UIImage imageNamed:@"notif_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage * barImageSel = [[UIImage imageNamed:@"notif_tab_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Notifications", nil) image:barImage selectedImage:barImageSel];
        self.model = [[NotificationsModel alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
//    IQRefreshControl *bottomRefreshControl = [IQRefreshControl new];
//    [bottomRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
//    self.tableView.bottomRefreshControl = bottomRefreshControl;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mark_tab_item.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self action:@selector(markSelectedReaded:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    NotificationsMenuModel * model = [[NotificationsMenuModel alloc] init];
    [self.leftMenuController setMenuResponder:self];
    [self.leftMenuController setTableHaderHidden:YES];
    [self.leftMenuController setModel:model];
    [self.leftMenuController reloadMenuWithCompletion:nil];
    
    [self reloadDataWithCompletion:nil];
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    IQNotification * notification = [self.model itemAtIndexPath:indexPath];
    cell.item = notification;
    
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 105;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    IQNotification * notification = [self.model itemAtIndexPath:indexPath];
  
}

#pragma mark - Menu Responder Delegate

- (void)menuController:(MenuViewController*)controller didSelectMenuItemAtIndexPath:(NSIndexPath*)indexPath {
    
}

#pragma mark - Private methods

- (void)markSelectedReaded:(id)sender {
    
}

- (void)refresh {
    [self reloadDataWithCompletion:nil];
}

@end
