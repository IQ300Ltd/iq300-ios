//
//  MenuViewController.m
//  IQ300
//
//  Created by Tayphoon on 06.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "MenuViewController.h"

#import "MenuConsts.h"
#import "MenuCell.h"
#import "MenuModel.h"
#import "ExpandableTableView.h"
#import "MenuSectionHeader.h"
#import "AccountHeaderView.h"
#import "MTableHeaderView.h"

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
    UIView * _tableHaderView;
}

@end

@implementation MenuViewController

- (id)init {
    self = [super init];
    if (self) {
        _model = [[MenuModel alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MENU_BACKGROUND_COLOR;
    
    _accountHeader = [[AccountHeaderView alloc] init];
    [self.view addSubview:_accountHeader];
    
    _tableHaderView = [[MTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, TABLE_HEADER_HEIGHT)];

    _tableView = [[ExpandableTableView alloc] init];
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableHeaderView = _tableHaderView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
                                  265,
                                  actualBounds.size.height - tableViewOffset);
}

- (void)setModel:(id<IQMenuModel>)model {
    [_model setDelegate:nil];
    _model = model;
    _model.delegate = self;
}

- (void)reloadDataWithHandler:(void (^)())handler {
    [_model updateModelWithCompletion:^(NSError *error) {
        if (handler) {
            handler();
        }
    }];
}

- (BOOL)tableView:(UITableView *)tableView canExpandSection:(NSInteger)section {
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_model numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_model numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuCell * cell = [tableView dequeueReusableCellWithIdentifier:[_model reuseIdentifierForSection:indexPath.section]];
    
    if (!cell) {
        cell = [_model createCellForSection:indexPath.section];
    }
    
    id item = [_model itemAtIndexPath:indexPath];
    cell.item = item;
    
    BOOL showBootomLine = !(indexPath.row == [_model numberOfItemsInSection:indexPath.section] - 1);
    [cell setBottomLineShown:showBootomLine];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - IQMenuModel Delegate

- (void)modelWillChangeContent:(id<IQMenuModel>)model {
    [_tableView beginUpdates];
}

- (void)model:(id<IQMenuModel>)model didChangeSectionAtIndex:(NSUInteger)sectionIndex forChangeType:(IQModelChangeType)type {
    switch(type) {
        case IQModelChangeInsert:
            [_tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                                    withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case IQModelChangeDelete:
            [_tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                                    withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)model:(id<IQMenuModel>)model didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(IQModelChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
        case IQModelChangeInsert:
            [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                            withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case IQModelChangeDelete:
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                            withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case IQModelChangeMove:
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                            withRowAnimation:UITableViewRowAnimationAutomatic];
            [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                            withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case IQModelChangeUpdate:
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
        [_tableView expandCollapseSection:header.section animated:YES];
    }];
    
    return headerView;
}

@end
