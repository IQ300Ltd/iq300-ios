//
//  IQFieldSelectionControllerViewController.m
//  IQ300
//
//  Created by Tayphoon on 24.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQSelectionController.h"
#import "IQSelectableTextCell.h"
#import "UIScrollView+PullToRefreshInsert.h"
#import "IQSession.h"

@interface IQSelectionController ()

@end

@implementation IQSelectionController

@dynamic model;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
        
    __weak typeof(self) weakSelf = self;
    [self.tableView
     insertPullToRefreshWithActionHandler:^{
         [weakSelf.model updateModelWithCompletion:^(NSError *error) {
             [[weakSelf.tableView pullToRefreshForPosition:SVPullToRefreshPositionTop] stopAnimating];
         }];
     }
     position:SVPullToRefreshPositionTop];
    
    
    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [self updateModel];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IQSelectableTextCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    cell.item = [self.model itemAtIndexPath:indexPath];
    
    BOOL isCellSelected = [self.model isItemSelectedAtIndexPath:indexPath];
    [cell setAccessoryType:(isCellSelected) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];
    
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.model.cellWidth = tableView.frame.size.width;
    return [self.model heightForItemAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath * selectedIndexPath = [self.model selectedIndexPathForSection:indexPath.section];
    if (self.model.allowsMultipleSelection) {
        BOOL isItemSelected = [self.model isItemSelectedAtIndexPath:indexPath];
        [self.model makeItemAtIndexPath:indexPath selected:!isItemSelected];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        if ([self.delegate respondsToSelector:@selector(selectionControllerController:didSelectItems:)]) {
            [self.delegate selectionControllerController:self didSelectItems:[self.model selectedItems]];
        }
    }
    else if((selectedIndexPath && [selectedIndexPath compare:indexPath] != NSOrderedSame) || !selectedIndexPath) {
        [self.model makeItemAtIndexPath:selectedIndexPath selected:NO];
        [self.model makeItemAtIndexPath:indexPath selected:YES];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        if (selectedIndexPath) {
            [self.tableView reloadRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self.tableView endUpdates];
        
        id item = [self.model itemAtIndexPath:indexPath];
        if ([self.delegate respondsToSelector:@selector(selectionControllerController:didSelectItem:)]) {
            [self.delegate selectionControllerController:self didSelectItem:item];
        }
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL selectionDisabled = (!self.model.allowsDeselection && [self.model isItemSelectedAtIndexPath:indexPath]);
    return (!selectionDisabled) ? indexPath : nil;
}

#pragma mark - Private methods

- (void)backButtonAction:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)applicationWillEnterForeground {
    [self updateModel];
}

@end
