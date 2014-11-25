//
//  AccountHeaderView.h
//  IQ300
//
//  Created by Tayphoon on 07.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "BottomLineView.h"

#define DEFAULT_AVATAR_IMAGE @"default_avatar.png"

@interface AccountHeaderView : BottomLineView {
    UIEdgeInsets _contentInsets;
}

@property (nonatomic, readonly) UIImageView * userImageView;
@property (nonatomic, readonly) UILabel * userNameLabel;
@property (nonatomic, readonly) UIButton * editButton;

@end
