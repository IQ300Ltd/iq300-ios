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
#import "IQOnlineIndicator.h"

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
    }
    
    id item = [self.model itemAtIndexPath:indexPath];

    
    if ([item isKindOfClass:[IQUser class]]) {
        IQUser *user = item;
        cell.textLabel.text = user.displayName;
        cell.detailTextLabel.text = user.nickName;
        cell.onlineIndicator.online = user.online.boolValue;
        
        if([user.thumbUrl length] > 0) {
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:user.thumbUrl]
                              placeholderImage:[UIImage imageNamed:@"default_avatar.png"]
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                         [cell setNeedsDisplay];
                                     }];
        }
    }
    else if ([item isKindOfClass:[AllUsersObject class]]) {
        AllUsersObject *object = item;
        cell.textLabel.text = object.displayName;
        cell.detailTextLabel.text = object.email;
        [cell.imageView setImage:[UIImage imageNamed:@"default_avatar.png"]];
    }
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self.delegate respondsToSelector:@selector(userPickerController:didPickUsers:)]) {
        id object = [self.model itemAtIndexPath:indexPath];
        if ([object isKindOfClass:[IQUser class]]) {
            [self.delegate userPickerController:self didPickUsers:@[object]];
        }
        else if ([object isKindOfClass:[AllUsersObject class]]) {
            NSPredicate *currentUserPredicate = [NSPredicate predicateWithFormat:@"userId !=%@", [IQSession defaultSession].userId];
            [self.delegate userPickerController:self didPickUsers:[self.model.users filteredArrayUsingPredicate:currentUserPredicate]];
        }
    }

    
}

#pragma mark - Private methods

- (void)backButtonAction:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
