//
//  NotificationsView.m
//  IQ300
//
//  Created by Tayphoon on 14.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "NotificationsView.h"
#import "BottomLineView.h"

NSString * const NoNotificationFound = @"There are no notifications";
NSString * const NoUnreadNotificationFound = @"There are no unread notifications";

#define SEARCH_HEIGHT 0//44

@interface NotificationsView() {
    BottomLineView * _searchBarContainer;
}

@end

@implementation NotificationsView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        _searchBarContainer = [[BottomLineView alloc] init];
//        _searchBarContainer.backgroundColor = [UIColor colorWithHexInt:0xf1f5f6];
//        _searchBarContainer.bottomLineHeight = 0.5f;
//        _searchBarContainer.bottomLineColor = [UIColor colorWithHexInt:0xe0e1e2];
//        [self addSubview:_searchBarContainer];
//        
//        _searchBar = [[ExTextField alloc] init];
//        _searchBar.backgroundColor = [UIColor clearColor];
//        _searchBar.textAlignment = NSTextAlignmentLeft;
//        _searchBar.placeholderInsets = UIEdgeInsetsMake(0, 10, 0, 0);
//        _searchBar.textInsets = UIEdgeInsetsMake(0, 10, 0, 0);
//        _searchBar.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Search", nil)
//                                                                           attributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexInt:0xa9a9a9]}];
//
//        [_searchBar setFont:[UIFont fontWithName:IQ_HELVETICA size:18]];
//        [_searchBar setTextColor:[UIColor blackColor]];
//        [_searchBarContainer addSubview:_searchBar];
        
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        if([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        if([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_tableView setLayoutMargins:UIEdgeInsetsZero];
        }
        [self addSubview:_tableView];
        
        _noDataLabel = [[UILabel alloc] init];
        [_noDataLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:15]];
        [_noDataLabel setTextColor:[UIColor colorWithHexInt:0xb3b3b3]];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.backgroundColor = [UIColor clearColor];
        _noDataLabel.numberOfLines = 0;
        _noDataLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_noDataLabel setHidden:YES];
        [_noDataLabel setText:NSLocalizedString(NoNotificationFound, nil)];
        [self addSubview:_noDataLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _searchBarContainer.frame = CGRectMake(0, 0, self.bounds.size.width, SEARCH_HEIGHT);
    _searchBar.frame = _searchBarContainer.bounds;
    _tableView.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(SEARCH_HEIGHT, 0, 0, 0));
    _noDataLabel.frame = self.bounds;
}

@end
