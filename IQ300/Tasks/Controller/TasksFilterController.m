//
//  TasksFilterController.m
//  IQ300
//
//  Created by Tayphoon on 26.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TasksFilterController.h"
#import "ExpandableTableView.h"
#import "TaskFilterCell.h"
#import "TaskFilterSectionView.h"
#import "TaskFilterItem.h"

#define SECTION_HEIGHT 50.0f

@interface TasksFilterController () <ExpandableTableViewDataSource, ExpandableTableViewDelegate> {
    ExpandableTableView * _tableView;
    NSInteger _selectedSection;
    NSMutableIndexSet * _expandedSections;
}

@end

@implementation TasksFilterController

- (id)init {
    self = [super init];
    if (self) {
        _selectedSection = NSNotFound;
        _expandedSections = [[NSMutableIndexSet alloc] init];
    }
    return self;
}

- (BOOL)showMenuBarItem {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
//    _accountHeader = [[AccountHeaderView alloc] init];
//    [_accountHeader.editButton addTarget:self
//                                  action:@selector(editButtonAction:)
//                        forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_accountHeader];
//    
//    _tableHaderView = [[MTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, TABLE_HEADER_HEIGHT)];
    
    _tableView = [[ExpandableTableView alloc] init];
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect actualBounds = self.view.bounds;
    
//    _accountHeader.frame = CGRectMake(actualBounds.origin.x,
//                                      actualBounds.origin.y,
//                                      actualBounds.size.width,
//                                      ACCOUNT_HEADER_HEIGHT);
//    
//    CGFloat tableViewOffset = _accountHeader.frame.origin.y + _accountHeader.frame.size.height;
    _tableView.frame = CGRectMake(0,
                                  0.0f,
                                  actualBounds.size.width,
                                  actualBounds.size.height);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
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
    TaskFilterCell * cell = [tableView dequeueReusableCellWithIdentifier:[_model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [_model createCellForIndexPath:indexPath];
    }
    
    id<TaskFilterItem> item = [self.model itemAtIndexPath:indexPath];
    cell.titleLabel.text = item.title;
    
    BOOL showBootomLine = !(indexPath.row == [_model numberOfItemsInSection:indexPath.section] - 1);
    [cell setBottomLineShown:showBootomLine];
        
    BOOL isCellSelected = [self.model isItemSellectedAtIndexPath:indexPath];
    [cell setAccessoryType:(isCellSelected) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];
    
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
    BOOL isItemSelected = ![self.model isItemSellectedAtIndexPath:indexPath];
    
    //Deselect previous cells
    NSArray * sectionSelectedIndexPaths = [self.model selectedIndexPathsForSection:indexPath.section];
    for (NSIndexPath * selectedIndexPath in sectionSelectedIndexPaths) {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:selectedIndexPath];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [self.model makeItemAtIndexPath:selectedIndexPath selected:NO];
    }
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:(isItemSelected) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];

    [self.model makeItemAtIndexPath:indexPath selected:isItemSelected];
}

#pragma mark - IQMenuModel Delegate

- (void)modelWillChangeContent:(id<IQTableModel>)model {
    [_tableView beginUpdates];
}

- (void)model:(id<IQTableModel>)model didChangeSectionAtIndex:(NSUInteger)sectionIndex forChangeType:(NSUInteger)type {
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

- (void)model:(id<IQTableModel>)model didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSUInteger)type newIndexPath:(NSIndexPath *)newIndexPath {
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

- (void)modelDidChangeContent:(id<IQTableModel>)model {
    [_tableView endUpdates];
}

- (void)modelDidChanged:(id<IQTableModel>)model {
    [_tableView reloadData];
}

- (UIView *)viewForHeaderInSection:(NSInteger)section {
    NSString * title = [_model titleForSection:section];
    TaskFilterSectionView * headerView = [[TaskFilterSectionView alloc] init];
    headerView.section = section;
    [headerView setTitle:title];
    [headerView setSeparatorHidden:section == 0];
    
    BOOL isExpandable = [self tableView:_tableView canExpandSection:section];
    [headerView setExpandable:isExpandable];
    if(isExpandable) {
        [headerView setExpanded:[_expandedSections containsIndex:section]];
        
        [headerView setActionBlock:^(TaskFilterSectionView *header) {
            if(header.isExpanded) {
                [_expandedSections addIndex:section];
            }
            else {
                [_expandedSections removeIndex:section];
            }
            [_tableView expandCollapseSection:header.section animated:YES];
        }];
    }
    
    BOOL sortAvailable = [self.model isSortActionAvailableAtSection:section];
    headerView.sortAvailable = sortAvailable;
    if(sortAvailable) {
        [headerView setSortActionBlock:^(TaskFilterSectionView *header) {
            [self.model setAscendingSortOrder:header.ascending forSection:header.section];
        }];
    }
    
    return headerView;
}

- (void)backButtonAction:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
