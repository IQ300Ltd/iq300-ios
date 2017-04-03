//
//  OptionsViewController.m
//  IQ300
//
//  Created by Viktor Sabanov on 03.04.17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import "OptionsViewController.h"

@interface OptionsViewController () {
    
}

@end

@implementation OptionsViewController

@dynamic model;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.model = [[OptionsModel alloc] init];
        
        self.title = NSLocalizedString(@"Options", nil);
    }
    
    return self;
}

- (BOOL)isLeftMenuEnabled {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.model updateModelWithCompletion:^(NSError *error) {
        if (!error) {
            [self.tableView reloadData];
        }
    }];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self layoutTabelView];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    if ([cell conformsToProtocol:@protocol(IQTableCell)]) {
        ((id <IQTableCell>)cell).item = [self.model itemAtIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark - Private methods

- (void)layoutTabelView {
    CGRect actualBounds = self.view.bounds;
    
    self.tableView.frame = CGRectMake(actualBounds.origin.x,
                                      actualBounds.origin.y,
                                      actualBounds.size.width,
                                      actualBounds.origin.y + actualBounds.size.height);
}

#pragma mark - Navigation actions

- (void)backButtonAction:(UIButton*)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
