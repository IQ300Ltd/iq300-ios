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
#import "ExtendedButton.h"

#define SECTION_HEIGHT 50.0f
#define SEPARATOR_HEIGHT 0.5f
#define SEPARATOR_COLOR [UIColor colorWithHexInt:0xcccccc]
#define BOTTOM_VIEW_HEIGHT 80

@interface TasksFilterController () <ExpandableTableViewDataSource, ExpandableTableViewDelegate> {
    ExpandableTableView * _tableView;
    NSInteger _selectedSection;
    NSMutableIndexSet * _expandedSections;
    UIView * _bottomSeparatorView;
    ExtendedButton * _clearButton;
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
    
    _tableView = [[ExpandableTableView alloc] init];
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _bottomSeparatorView = [[UIView alloc] init];
    [_bottomSeparatorView setBackgroundColor:SEPARATOR_COLOR];
    [self.view addSubview:_bottomSeparatorView];
    
    _clearButton = [[ExtendedButton alloc] init];
    _clearButton.layer.cornerRadius = 4.0f;
    _clearButton.layer.borderWidth = 0.5f;
    [_clearButton setTitle:NSLocalizedString(@"Reset settings", nil) forState:UIControlStateNormal];
    [_clearButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:16]];
    [_clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [_clearButton setBackgroundColor:IQ_CELADON_COLOR];
    [_clearButton setBackgroundColor:IQ_CELADON_COLOR_HIGHLIGHTED forState:UIControlStateHighlighted];
    [_clearButton setBackgroundColor:IQ_CELADON_COLOR_DISABLED forState:UIControlStateDisabled];
    _clearButton.layer.borderColor = _clearButton.backgroundColor.CGColor;
    [_clearButton setClipsToBounds:YES];
    [self.view addSubview:_clearButton];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect actualBounds = self.view.bounds;
    
    _tableView.frame = CGRectMake(0,
                                  0.0f,
                                  actualBounds.size.width,
                                  actualBounds.size.height - BOTTOM_VIEW_HEIGHT);
    
    _bottomSeparatorView.frame = CGRectMake(actualBounds.origin.x,
                                            actualBounds.origin.y + actualBounds.size.height - BOTTOM_VIEW_HEIGHT,
                                            actualBounds.size.width,
                                            SEPARATOR_HEIGHT);
    
    CGSize clearButtonSize = CGSizeMake(300, 40);
    _clearButton.frame = CGRectMake(actualBounds.origin.x + (actualBounds.size.width - clearButtonSize.width) / 2.0f,
                                    actualBounds.origin.y + actualBounds.size.height - clearButtonSize.height - 10.0f,
                                    clearButtonSize.width,
                                    clearButtonSize.height);
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
