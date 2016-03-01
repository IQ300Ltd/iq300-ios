//
//  TaskComplexityController.m
//  IQ300
//
//  Created by Vladislav Grigoryev on 29/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "TaskComplexityController.h"
#import "UIScrollView+PullToRefreshInsert.h"
#import "TaskComplexityCell.h"
#import "IQComplexity.h"
#import "IQSession.h"
#import "DispatchAfterExecution.h"

@implementation TaskComplexityController

@dynamic model;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Complexity", nil);
        self.model = [[TaskComplexityModel alloc] init];
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
    
    [self.noDataLabel setText:NSLocalizedString(@"No communities", nil)];
    
    __weak typeof(self) weakSelf = self;
    [self.tableView
     insertPullToRefreshWithActionHandler:^{
         [weakSelf reloadDataWithCompletion:^(NSError *error) {
             [self proccessServiceError:error];
             [[weakSelf.tableView pullToRefreshForPosition:SVPullToRefreshPositionTop] stopAnimating];
         }];
     }
     position:SVPullToRefreshPositionTop];
    
    
    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    [self updateModel];

}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskComplexityCell* cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    IQComplexity * item = [self.model itemAtIndexPath:indexPath];
    [cell setItem:item];
    
    BOOL isCellSelected = (_fieldValue == nil && [item.value isEqualToNumber:@(1)]) || (_fieldValue != nil && [item.value isEqualToNumber:_fieldValue.value]);
    [cell setAccessoryType:(isCellSelected) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];
    
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.model.cellWidth = tableView.frame.size.width;
    return [self.model heightForItemAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IQComplexity * complexity = [self.model itemAtIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(taskFieldEditController:didChangeFieldValue:)]) {
        [self.delegate taskFieldEditController:self didChangeFieldValue:complexity];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return ([self.tableView.indexPathForSelectedRow isEqual:indexPath] == NO) ? indexPath : nil;
}

#pragma mark - Activity indicator overrides

- (void)showActivityIndicatorAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [self.tableView setPullToRefreshAtPosition:SVPullToRefreshPositionTop shown:NO];
    
    [super showActivityIndicatorAnimated:YES completion:nil];
}

- (void)hideActivityIndicatorAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [super hideActivityIndicatorAnimated:YES completion:^{
        [self.tableView setPullToRefreshAtPosition:SVPullToRefreshPositionTop shown:YES];
        
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - Private methods

- (void)backButtonAction:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateModel {
    if([IQSession defaultSession]) {
        [self showActivityIndicatorAnimated:YES completion:nil];
        
        [self.model updateModelWithCompletion:^(NSError *error) {
            if(!error) {
                [self.tableView reloadData];
            }
            
            [self updateNoDataLabelVisibility];
            dispatch_after_delay(0.5f, dispatch_get_main_queue(), ^{
                [self hideActivityIndicatorAnimated:YES completion:nil];
            });
        }];
    }
}

@end
