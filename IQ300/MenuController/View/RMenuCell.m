//
//  RMenuCell.m
//  IQ300
//
//  Created by Tayphoon on 19.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import "IQBadgeView.h"
#import "RMenuCell.h"

@implementation RMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.badgeView.badgeStyle.badgeFrameColor = [UIColor whiteColor];
        self.badgeView.badgeStyle.badgeInsetColor = [UIColor colorWithHexInt:0xe74545];
        self.badgeView.badgeStyle.badgeTextColor = [UIColor whiteColor];
    }
    return self;
}

@end
