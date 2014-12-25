//
//  MenuCell.h
//  IQ300
//
//  Created by Tayphoon on 06.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQMenuItem.h"

@class IQBadgeView;

@interface MenuCell : UITableViewCell {
    UIView * _cellContentView;
    UIEdgeInsets _contentInsets;
}

@property (nonatomic, strong) IQMenuItem * item;
@property (nonatomic, strong) NSString * badgeText;

@property (nonatomic, readonly) IQBadgeView * badgeView;
@property (nonatomic, readonly) UILabel * titleLabel;

@property (nonatomic, assign, setter = setBottomLineShown:) BOOL isBottomLineShown;

@end
