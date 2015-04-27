//
//  UserPickerController.m
//  IQ300
//
//  Created by Tayphoon on 10.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/CALayer.h>

#import "UserPickerController.h"
#import "DispatchAfterExecution.h"
#import "IQSession.h"
#import "ContactCell.h"
#import "IQUser.h"

#define DISPATCH_DELAY 0.7

@interface UserPickerController () {
}

@end

@implementation UserPickerController

@dynamic model;

- (void)setFilter:(NSString *)filter {
    _filter = filter;
    
    void(^compleationBlock)(NSError * error) = ^(NSError * error) {
        if(!error) {
            [self.tableView reloadData];
            [self updateNoDataLabelVisibility];
        }
    };
    
    [self.model setFilter:filter];
    [self.model updateModelWithCompletion:compleationBlock];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [self.noDataLabel setText:NSLocalizedString(@"No contacts", nil)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if([IQSession defaultSession]) {
        [self.model updateModelWithCompletion:^(NSError *error) {
            [self.tableView reloadData];
            [self updateNoDataLabelVisibility];
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
        
        CALayer *cellImageLayer = cell.imageView.layer;
        [cellImageLayer setCornerRadius:17.5];
        [cellImageLayer setMasksToBounds:YES];
    }
    
    IQUser * user = [self.model itemAtIndexPath:indexPath];
    
    cell.textLabel.text = user.displayName;
    cell.detailTextLabel.text = user.nickName;
    
    if([user.thumbUrl length] > 0) {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:user.thumbUrl]
                          placeholderImage:[UIImage imageNamed:@"default_avatar.png"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [cell setNeedsDisplay];
        }];
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IQUser * user = [self.model itemAtIndexPath:indexPath];
    
    if([self.delegate respondsToSelector:@selector(userPickerController:didPickUser:)]) {
        [self.delegate userPickerController:self didPickUser:user];
    }
}

#pragma mark - Private methods

- (void)backButtonAction:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
