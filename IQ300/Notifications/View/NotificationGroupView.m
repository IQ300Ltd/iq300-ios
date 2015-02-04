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

@implementation NotificationGroupView

- (id)init {
    self = [super init];
    
    if (self) {
        _headerView = [[BottomLineView alloc] init];
        _headerView.bottomLineColor = SEPARATOR_COLOR;
        _headerView.bottomLineHeight = 0.5f;
        [_headerView setBackgroundColor:[UIColor clearColor]];
        
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
    _headerView.frame = CGRectMake(actualBounds.origin.x,
                                   actualBounds.origin.y,
                                   actualBounds.size.width,
                                   HEADER_HEIGHT);
    
    CGSize backButtonImageSize = [_backButton imageForState:UIControlStateNormal].size;
    _backButton.frame = CGRectMake(-4.0f,
                                   actualBounds.origin.y + (_headerView.frame.size.height - backButtonImageSize.height) / 2,
                                   backButtonImageSize.width,
                                   backButtonImageSize.height);
    
    CGFloat titleX = CGRectRight(_backButton.frame) - 5.0f;
    _titleLabel.frame = CGRectMake(titleX,
                                   _headerView.frame.origin.y,
                                   _headerView.frame.size.width - titleX,
                                   _headerView.frame.size.height);
    
    self.tableView.frame = UIEdgeInsetsInsetRect(actualBounds, UIEdgeInsetsMake(HEADER_HEIGHT, 0, 0, 0));
    self.noDataLabel.frame = self.tableView.frame;
}

@end
