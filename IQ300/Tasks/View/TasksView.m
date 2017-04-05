//
//  TasksView.m
//  IQ300
//
//  Created by Tayphoon on 19.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TasksView.h"

#define HEADER_HEIGHT 52.0f
#define SEPARATOR_COLOR IQ_SEPARATOR_LINE_COLOR

NSString * const NoTasksFound = @"There are no tasks";

@interface TasksView() {
    UIEdgeInsets _headerContentInsets;
}

@end

@implementation TasksView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        _headerContentInsets = UIEdgeInsetsHorizontalMake(11.f);
        
        _headerView = [[BottomLineView alloc] init];
        _headerView.bottomLineColor = SEPARATOR_COLOR;
        _headerView.bottomLineHeight = 0.5f;
        [_headerView setBackgroundColor:IQ_GRAY_LIGHT_COLOR];
        
        _filterButton = [[UIButton alloc] init];
        [_filterButton setImage:[UIImage imageNamed:@"next_header_button.png"] forState:UIControlStateNormal];
        [[_filterButton imageView] setContentMode:UIViewContentModeCenter];
        [_headerView addSubview:_filterButton];
        
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:15]];
        [_titleLabel setTextColor:IQ_FONT_GRAY_COLOR];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_headerView addSubview:_titleLabel];
        [self addSubview:_headerView];

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
        [_noDataLabel setTextColor:IQ_FONT_GRAY_COLOR];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.backgroundColor = [UIColor clearColor];
        _noDataLabel.numberOfLines = 0;
        _noDataLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_noDataLabel setText:NSLocalizedString(NoTasksFound, nil)];
        [self addSubview:_noDataLabel];
        [self bringSubviewToFront:_headerView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect actualBounds = self.bounds;
    _headerView.frame = CGRectMake(actualBounds.origin.x,
                                   actualBounds.origin.y,
                                   actualBounds.size.width,
                                   HEADER_HEIGHT);
    
    CGRect headerContentRect = UIEdgeInsetsInsetRect(_headerView.frame, _headerContentInsets);
    CGSize backButtonImageSize = [_filterButton imageForState:UIControlStateNormal].size;
    _filterButton.frame = CGRectMake(CGRectRight(headerContentRect) - backButtonImageSize.width,
                                   (headerContentRect.size.height - backButtonImageSize.height) / 2,
                                   backButtonImageSize.width,
                                   backButtonImageSize.height);
    
    _titleLabel.frame = CGRectMake(headerContentRect.origin.x,
                                   headerContentRect.origin.y,
                                   _filterButton.frame.origin.x - 5.0f,
                                   headerContentRect.size.height);
    
    _tableView.frame = UIEdgeInsetsInsetRect(actualBounds, UIEdgeInsetsMake(HEADER_HEIGHT, 0, 0, 0));
    _noDataLabel.frame = self.tableView.frame;
}

@end
