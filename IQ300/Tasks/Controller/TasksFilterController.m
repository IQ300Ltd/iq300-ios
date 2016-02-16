//
//  TasksFilterController.m
//  IQ300
//
//  Created by Tayphoon on 26.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "UIViewController+ErrorHandle.h"

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
    UIView * _bottomSeparatorView;
    ExtendedButton * _doneButton;
}

@end

@implementation TasksFilterController

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (BOOL)isLeftMenuEnabled {
    return NO;
}

- (void)setModel:(id<IQTableModel>)model {
    [_model setDelegate:nil];
    _model = model;
    _model.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[ExpandableTableView alloc] init];
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    
    _bottomSeparatorView = [[UIView alloc] init];
    [_bottomSeparatorView setBackgroundColor:SEPARATOR_COLOR];
    [self.view addSubview:_bottomSeparatorView];
    
    _doneButton = [[ExtendedButton alloc] init];
    _doneButton.layer.cornerRadius = 4.0f;
    _doneButton.layer.borderWidth = 0.5f;
    [_doneButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [_doneButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:16]];
    [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [_doneButton setBackgroundColor:IQ_CELADON_COLOR];
    [_doneButton setBackgroundColor:IQ_CELADON_COLOR_HIGHLIGHTED forState:UIControlStateHighlighted];
    [_doneButton setBackgroundColor:IQ_CELADON_COLOR_DISABLED forState:UIControlStateDisabled];
    _doneButton.layer.borderColor = _doneButton.backgroundColor.CGColor;
    [_doneButton setClipsToBounds:YES];
    [_doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_doneButton];
    
    UIBarButtonItem * clearButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reset_filter.png"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(clearButtonAction:)];
    self.navigationItem.rightBarButtonItem = clearButton;
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
    
    CGSize doneButtonSize = CGSizeMake(300, 40);
    _doneButton.frame = CGRectMake(actualBounds.origin.x + (actualBounds.size.width - doneButtonSize.width) / 2.0f,
                                    actualBounds.origin.y + actualBounds.size.height - doneButtonSize.height - 10.0f,
                                    doneButtonSize.width,
                                    doneButtonSize.height);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;

    if(self.model) {
        [self.model updateModelWithCompletion:^(NSError *error) {
            [_tableView reloadData];
            [self proccessServiceError:error];
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
    [cell setItem:item];
    
    BOOL showBootomLine = !(indexPath.row == [_model numberOfItemsInSection:indexPath.section] - 1);
    [cell setBottomLineShown:showBootomLine];
        
    BOOL isCellSelected = [self.model isItemSelectedAtIndexPath:indexPath];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath * selectedIndexPath = [self.model selectedIndexPathForSection:indexPath.section];
    if(indexPath.section != SORT_SECTION) {
        BOOL isItemSelected = [self.model isItemSelectedAtIndexPath:indexPath];
        if(selectedIndexPath && [selectedIndexPath compare:indexPath] != NSOrderedSame) {
            [self.model makeItemAtIndexPath:selectedIndexPath selected:NO];
        }

        [self.model makeItemAtIndexPath:indexPath selected:!isItemSelected];
        [self.model updateModelWithCompletion:^(NSError *error) {
            if(!error) {
                [self modelWillChangeContent:self.model];
                [self model:self.model didChangeSectionAtIndex:STATUS_SECTION forChangeType:NSFetchedResultsChangeUpdate];
                [self model:self.model didChangeSectionAtIndex:COMMUNITY_SECTION forChangeType:NSFetchedResultsChangeUpdate];
                [self modelDidChangeContent:self.model];
            }
            [self proccessServiceError:error];
        }];
    }
    else if((selectedIndexPath && [selectedIndexPath compare:indexPath] != NSOrderedSame) || !selectedIndexPath) {
        [self.model makeItemAtIndexPath:selectedIndexPath selected:NO];
        [self.model makeItemAtIndexPath:indexPath selected:YES];
        [self modelWillChangeContent:self.model];
        [self model:self.model didChangeObject:nil atIndexPath:indexPath forChangeType:NSFetchedResultsChangeUpdate newIndexPath:nil];
        [self model:self.model didChangeObject:nil atIndexPath:selectedIndexPath forChangeType:NSFetchedResultsChangeUpdate newIndexPath:nil];
        [self modelDidChangeContent:self.model];
    }
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
        case NSFetchedResultsChangeUpdate:
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]
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
        BOOL isSectionExpanded = [_tableView.expandedSections containsIndex:section];
        [headerView setExpanded:isSectionExpanded];
        
        [headerView setActionBlock:^(TaskFilterSectionView *header) {
            [_tableView expandCollapseSection:header.section animated:YES];
        }];
    }
    
    BOOL sortAvailable = [self.model isSortActionAvailableAtSection:section];
    if(sortAvailable) {
        headerView.sortAvailable = sortAvailable;
        headerView.ascending = [self.model isSortOrderAscendingForSection:section];
        [headerView setSortActionBlock:^(TaskFilterSectionView *header) {
            [self.model setAscendingSortOrder:header.ascending forSection:header.section];
        }];
    }
    
    return headerView;
}

- (void)backButtonAction:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clearButtonAction:(UIButton*)sender {
    [self.model resetFilters];
    [self.model updateModelWithCompletion:^(NSError *error) {
        if(!error) {
            [_tableView reloadData];
        }
        [self proccessServiceError:error];
    }];
}

- (void)doneButtonAction:(UIButton*)sender {
    if ([self.delegate respondsToSelector:@selector(filterControllerWillFinish:)]) {
        [self.delegate filterControllerWillFinish:self];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
