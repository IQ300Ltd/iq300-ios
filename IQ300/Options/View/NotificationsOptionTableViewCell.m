//
//  NotificationsOptionTableViewCell.m
//  IQ300
//
//  Created by Viktor Sabanov on 03.04.17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import "NotificationsOptionTableViewCell.h"

#ifdef IPAD
#define TEXT_FONT_SIZE 14.f
#else
#define TEXT_FONT_SIZE 13.f
#endif

@implementation NotificationsOptionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = IQ_GRAY_LIGHT_COLOR;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont fontWithName:IQ_HELVETICA size:TEXT_FONT_SIZE];
        _titleLabel.textColor = IQ_FONT_BLACK_COLOR;
        [self.contentView addSubview:_titleLabel];
        
        _notificationsSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_notificationsSwitch];
    }
    
    return self;
}

- (void)setItem:(NotificationsOptionItem *)item {
    _titleLabel.text = item.titleString;
    _notificationsSwitch.on = item.onState;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat horizontalInsets = 12.f;
    
    CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
    _titleLabel.frame = CGRectMake(horizontalInsets,
                                   CGRectGetMidY(self.bounds) - titleSize.height/2.f,
                                   titleSize.width,
                                   titleSize.height);
    
    CGFloat switchMinX = CGRectGetWidth(self.bounds) - horizontalInsets - CGRectGetWidth(_notificationsSwitch.bounds);
    _notificationsSwitch.frame = CGRectMake(switchMinX,
                                            CGRectGetMidY(self.bounds) - CGRectGetHeight(_notificationsSwitch.bounds) / 2.f,
                                            CGRectGetWidth(_notificationsSwitch.bounds),
                                            CGRectGetHeight(_notificationsSwitch.bounds));
}

@end
