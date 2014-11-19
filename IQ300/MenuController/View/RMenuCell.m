//
//  RMenuCell.m
//  IQ300
//
//  Created by Tayphoon on 19.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <JSBadgeView/JSBadgeView.h>

#import "RMenuCell.h"

@implementation RMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.badgeView.badgeBackgroundColor = [UIColor colorWithHexInt:0xe74545];
        self.badgeView.badgeTextColor = [UIColor whiteColor];
        self.badgeView.badgeStrokeWidth = 0.0f;
        
        self.titleLabel.textColor = [UIColor colorWithHexInt:0xe94545];
    }
    return self;
}


@end
