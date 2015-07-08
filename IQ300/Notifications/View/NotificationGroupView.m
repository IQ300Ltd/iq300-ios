//
//  NotificationGroupView.m
//  IQ300
//
//  Created by Tayphoon on 29.01.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "NotificationGroupView.h"

#define HEADER_HEIGHT 52.0f
#define SEPARATOR_COLOR [UIColor colorWithHexInt:0xc0c0c0]

@interface NotificationGroupView() {
    BOOL _headerViewHidden;
}

@end

@implementation NotificationGroupView

- (id)init {
    self = [super init];
    
    if (self) {
        _headerViewHidden = NO;
        _headerView = [[BottomLineView alloc] init];
        _headerView.bottomLineColor = SEPARATOR_COLOR;
        _headerView.bottomLineHeight = 0.5f;
        [_headerView setBackgroundColor:[UIColor whiteColor]];
        
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[UIImage imageNamed:@"backArrow.png"] forState:UIControlStateNormal];
        [[_backButton imageView] setContentMode:UIViewContentModeCenter];
        [_headerView addSubview:_backButton];
        
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:15]];
        [_titleLabel setTextColor:[UIColor colorWithHexInt:0x9f9f9f]];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_headerView addSubview:_titleLabel];
        [self addSubview:_headerView];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect actualBounds = self.bounds;
    if (!_headerViewHidden) {
        _headerView.frame = CGRectMake(actualBounds.origin.x,
                                       actualBounds.origin.y,
                                       actualBounds.size.width,
                                       HEADER_HEIGHT);
        
        CGSize backButtonImageSize = (IS_IPAD) ? CGSizeZero : [_backButton imageForState:UIControlStateNormal].size;
        _backButton.frame = CGRectMake(-4.0f,
                                       (_headerView.frame.size.height - backButtonImageSize.height) / 2,
                                       backButtonImageSize.width,
                                       backButtonImageSize.height);
        
        CGFloat titleX = (IS_IPAD) ? actualBounds.origin.x + 10.0f : CGRectRight(_backButton.frame) - 5.0f;
        _titleLabel.frame = CGRectMake(titleX,
                                       actualBounds.origin.y,
                                       _headerView.frame.size.width - titleX,
                                       _headerView.frame.size.height);
    }
    
    UIEdgeInsets tableInsets = (_headerViewHidden) ? UIEdgeInsetsZero : UIEdgeInsetsMake(HEADER_HEIGHT, 0, 0, 0);
    self.tableView.frame = UIEdgeInsetsInsetRect(actualBounds, tableInsets);
    self.noDataLabel.frame = self.tableView.frame;
}

- (void)setHeaderViewHidden:(BOOL)hidden {
    if (_headerViewHidden != hidden) {
        _headerViewHidden = hidden;
        [self setNeedsLayout];
    }
}

@end
