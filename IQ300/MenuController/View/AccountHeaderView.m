//
//  AccountHeaderView.m
//  IQ300
//
//  Created by Tayphoon on 07.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AccountHeaderView.h"
#import "MenuConsts.h"

#define USER_ICON_SEZE 35

@implementation AccountHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _contentInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        self.bottomLineColor = MENU_SEPARATOR_COLOR;
        self.bottomLineHeight = 1.0f;
        [self setBackgroundColor:MENU_BACKGROUND_COLOR];
        
        _userImageView = [[UIImageView alloc] init];
        _userImageView.layer.cornerRadius = USER_ICON_SEZE / 2.0f;
        [_userImageView setImage:[UIImage imageNamed:DEFAULT_AVATAR_IMAGE]];
        [_userImageView setClipsToBounds:YES];
        [self addSubview:_userImageView];
        
        _userNameLabel = [[UILabel alloc] init];
        [_userNameLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:14]];
        [_userNameLabel setTextColor:[UIColor whiteColor]];
        _userNameLabel.textAlignment = NSTextAlignmentLeft;
        _userNameLabel.backgroundColor = [UIColor clearColor];
        _userNameLabel.numberOfLines = 0;
        _userNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _userNameLabel.text = @"Noname";
        [self addSubview:_userNameLabel];
        
        _logoutButton = [[UIButton alloc] init];
        [_logoutButton setTitle:NSLocalizedString(@"Logout", nil) forState:UIControlStateNormal];
        [_logoutButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:12]];
        [_logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _logoutButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self addSubview:_logoutButton];
        
        _onlineIndicator = [[IQOnlineIndicator alloc] init];
        _onlineIndicator.style = IQOnlineIndicatorStyleCurrentUser;
        [self addSubview:_onlineIndicator];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect actualBounds = self.bounds;
    CGRect mainRect = UIEdgeInsetsInsetRect(actualBounds, _contentInsets);
    
    CGSize onlineIndicatorSize = CGSizeMake(10.0f, 10.0f);
    
    _userImageView.frame = CGRectMake(mainRect.origin.x,
                                      (mainRect.size.height - USER_ICON_SEZE) / 2.0f,
                                      USER_ICON_SEZE,
                                      USER_ICON_SEZE);
    
    CGSize userImageViewSize = _userImageView.bounds.size;
    
    CGFloat onlineIndicatorX = MIN(_userImageView.frame.origin.x + (userImageViewSize.width / 2.0f + userImageViewSize.width / 4.0f), CGRectRight(_userNameLabel.frame) - onlineIndicatorSize.width);
    _onlineIndicator.frame = CGRectMake(onlineIndicatorX,
                                        _userImageView.frame.origin.y + (userImageViewSize.height / 2.0f + userImageViewSize.height / 4.0f),
                                        onlineIndicatorSize.width,
                                        onlineIndicatorSize.height);
    
    CGFloat leftOffset = 11;
    CGFloat userNameLabelX = _userImageView.frame.origin.x + _userImageView.frame.size.width + leftOffset;
    _userNameLabel.frame = CGRectMake(userNameLabelX,
                                      _userImageView.frame.origin.y,
                                      mainRect.size.width - userNameLabelX,
                                      17);
    
    _logoutButton.frame = CGRectMake(_userNameLabel.frame.origin.x,
                                   _userNameLabel.frame.origin.y + _userNameLabel.frame.size.height + 7.0f,
                                   54,
                                   9);
}

@end
