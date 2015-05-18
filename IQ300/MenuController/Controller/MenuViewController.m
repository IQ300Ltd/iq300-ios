//
//  MenuViewController.m
//  IQ300
//
//  Created by Tayphoon on 06.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <SDWebImage/UIImageView+WebCache.h>

#import "MenuViewController.h"
#import "NSManagedObject+ActiveRecord.h"

#import "MenuConsts.h"
#import "MenuCell.h"
#import "NotificationsMenuModel.h"
#import "ExpandableTableView.h"
#import "MenuSectionHeader.h"
#import "AccountHeaderView.h"
#import "MTableHeaderView.h"
#import "AppDelegate.h"
#import "SuppressWarning.h"
#import "IQService.h"
#import "IQUser.h"

#define SECTION_HEIGHT 39
#define ACCOUNT_HEADER_HEIGHT 64.5
#define TABLE_HEADER_HEIGHT 42.5

CGFloat IQStatusBarHeight()
{
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    return MIN(statusBarSize.width, statusBarSize.height);
}

@interface MenuViewController () <ExpandableTableViewDataSource, ExpandableTableViewDelegate> {
    ExpandableTableView * _tableView;
    AccountHeaderView * _accountHeader;
    NSInteger _selectedSection;
}

@end

@implementation MenuViewController

- (id)init {
    self = [super init];
    if (self) {
        _selectedSection = NSNotFound;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MENU_BACKGROUND_COLOR;
    
    _accountHeader = [[AccountHeaderView alloc] init];
    [_accountHeader.editButton addTarget:self
                                  action:@selector(editButtonAction:)
                        forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_accountHeader];
    
    _tableHaderView = [[MTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, TABLE_HEADER_HEIGHT)];
    
    _tableView = [[ExpandableTableView alloc] init];
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [UIView new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUserAccount)
                                                 name:AccountDidChangedNotification
                                               object:nil];
    [self updateUserAccount];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect actualBounds = self.view.bounds;
    
    _accountHeader.frame = CGRectMake(actualBounds.origin.x,
                                      actualBounds.origin.y,
                                      actualBounds.size.width,
                                      ACCOUNT_HEADER_HEIGHT);
    
    CGFloat tableViewOffset = _accountHeader.frame.origin.y + _accountHeader.frame.size.height;
    _tableView.frame = CGRectMake(0,
                                  tableViewOffset,
                                  MENU_WIDTH,
                                  actualBounds.size.height - tableViewOffset);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)setTableHaderHidden:(BOOL)tableHaderHidden {
    _tableView.tableHeaderView = (!tableHaderHidden) ? _tableHaderView : nil;
}

- (BOOL)isTableHaderHidden {
    return _tableView.tableHeaderView == nil;
}

- (void)setModel:(id<IQMenuModel>)model {
    [_model setDelegate:nil];
    _model = model;
    _tableHaderView.title = _model.title;
    [_tableHaderView setHidden:(_model == nil)];
    _model.delegate = self;
}

- (void)reloadMenuWithCompletion:(void (^)())completion {
    void (^completionBlock)(NSError *error) = ^(NSError *error) {
        if(!error) {
            [_tableView reloadData];
        }
        if (completion) {
            completion();
        }
    };
    
    if(_model) {
        [_model updateModelWithCompletion:completionBlock];
    }
    else {
        completionBlock(nil);
    }
}

#pragma mark - UITableView DataSource

- (BOOL)tableView:(UITableView *)tableView canExpandSection:(NSInteger)section {
    return [_model canExpandSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_model numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_model numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuCell * cell = [tableView dequeueReusableCellWithIdentifier:[_model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [_model createCellForIndexPath:indexPath];
    }
    
    id item = [_model itemAtIndexPath:indexPath];
    cell.item = item;
    
    BOOL showBootomLine = !(indexPath.row == [_model numberOfItemsInSection:indexPath.section] - 1);
    [cell setBottomLineShown:showBootomLine];
    
    cell.badgeText = [self.model badgeTextAtIndexPath:indexPath];
    
    NSIndexPath * selectedIndexPath = [self.model indexPathForSelectedItem];
    BOOL isCellSelected = (selectedIndexPath && [selectedIndexPath compare:indexPath] == NSOrderedSame);
    if(isCellSelected) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_model heightForItemAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return SECTION_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self viewForHeaderInSection:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.model selectItemAtIndexPath:indexPath];
    SEL didSelect = @selector(menuController:didSelectMenuItemAtIndexPath:);
    if([self.menuResponder respondsToSelector:didSelect]) {
        SuppressPerformSelectorLeakWarning([self.menuResponder performSelector:didSelect withObject:self withObject:indexPath]);
    }
}

#pragma mark - IQMenuModel Delegate

- (void)modelWillChangeContent:(id<IQMenuModel>)model {
    [_tableView beginUpdates];
}

- (void)model:(id<IQMenuModel>)model didChangeSectionAtIndex:(NSUInteger)sectionIndex forChangeType:(NSUInteger)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [_tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                                    withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [_tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                                    withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)model:(id<IQMenuModel>)model didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSUInteger)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                            withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                            withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeMove:
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                            withRowAnimation:UITableViewRowAnimationAutomatic];
            [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                            withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeUpdate:
            [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                            withRowAnimation:UITableViewRowAnimationNone];
            break;
    }
}

- (void)modelDidChangeContent:(id<IQMenuModel>)model {
    [_tableView endUpdates];
}

- (void)modelDidChanged:(id<IQMenuModel>)model {
    [_tableView reloadData];
}

- (UIView *)viewForHeaderInSection:(NSInteger)section {
    NSString * title = [_model titleForSection:section];
    MenuSectionHeader * headerView = [MenuSectionHeader new];
    headerView.section = section;
    [headerView setTitle:title];
    [headerView setActionBlock:^(MenuSectionHeader *header) {
        NSInteger oldSection = _selectedSection;
        _selectedSection = (header.selected) ? header.section : NSNotFound;
        if(oldSection != NSNotFound && oldSection != header.section) {
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:oldSection]
                      withRowAnimation:UITableViewRowAnimationNone];
        }
        
        BOOL isExpandable = [self tableView:_tableView canExpandSection:header.section];
        if(isExpandable) {
            [_tableView expandCollapseSection:header.section animated:YES];
        }
    }];
    
    BOOL isExpandable = [self tableView:_tableView canExpandSection:section];
    [headerView setExpandable:isExpandable];
    if(isExpandable) {
        BOOL isSectionExpanded = [_tableView.expandedSections containsIndex:section];
        [headerView setExpanded:isSectionExpanded];
    }

    [headerView setSelected:(section == _selectedSection)];
    
    return headerView;
}

- (void)editButtonAction:(UIButton*)sender {
    [AppDelegate logout];
    [[NSNotificationCenter defaultCenter] postNotificationName:AccountDidChangedNotification
                                                        object:nil];
}

- (void)updateUserAccount {
    if([IQSession defaultSession]) {
        [[IQService sharedService] userInfoWithHandler:^(BOOL success, IQUser * user, NSData *responseData, NSError *error) {
            if (error.code == kCFURLErrorNotConnectedToInternet) {
                user = [IQUser userWithId:[IQSession defaultSession].userId
                                inContext:[IQService sharedService].context];
            }
            
            NSString * displayName = ([user.displayName length] > 0) ? user.displayName : @"Noname";
            if (user) {
                [_accountHeader.userNameLabel setText:displayName];
                if([user.mediumUrl length] > 0) {
                    [_accountHeader.userImageView sd_setImageWithURL:[NSURL URLWithString:user.mediumUrl]];
                }
                else {
                    [_accountHeader.userImageView setImage:[UIImage imageNamed:DEFAULT_AVATAR_IMAGE]];
                }
            }
        }];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
