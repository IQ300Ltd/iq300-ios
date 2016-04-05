//
//  ContactInfoCell.m
//  IQ300
//
//  Created by Tayphoon on 13.07.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <SDWebImage/UIImageView+WebCache.h>

#import "ContactInfoCell.h"
#import "IQConversationMember.h"
#import "IQUser.h"
#import "IQOnlineIndicator.h"

@implementation ContactInfoCell

+ (CGFloat)heightForItem:(id)item detailTitle:(NSString*)detailTitle width:(CGFloat)width {
    return 68;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        UIView * contentView = [super valueForKey:@"_contentCellView"];
        contentView.backgroundColor = [UIColor whiteColor];
        
        self.textLabel.font = [UIFont fontWithName:IQ_HELVETICA size:15];
        self.textLabel.textColor = [UIColor colorWithHexInt:0x2c74a4];
        self.textLabel.backgroundColor = [UIColor whiteColor];
        self.textLabel.highlightedTextColor = [UIColor whiteColor];
        
        CALayer *cellImageLayer = self.imageView.layer;
        [cellImageLayer setCornerRadius:17.5];
        [cellImageLayer setMasksToBounds:YES];
        
        _onlineIndicator = [[IQOnlineIndicator alloc] init];
        [contentView addSubview:_onlineIndicator];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize textLabelSize = [self.textLabel sizeThatFits:CGSizeMake(self.textLabel.bounds.size.width - ONLINE_INDICATOR_LEFT_OFFSET - ONLINE_INDICATOR_SIZE, self.textLabel.bounds.size.height)];
    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y, textLabelSize.width, self.textLabel.bounds.size.height);
    
    _onlineIndicator.frame = CGRectMake(CGRectRight(self.textLabel.frame) + ONLINE_INDICATOR_LEFT_OFFSET,
                                        self.textLabel.frame.origin.y + (self.textLabel.bounds.size.height - ONLINE_INDICATOR_SIZE) / 2.0f,
                                        ONLINE_INDICATOR_SIZE,
                                        ONLINE_INDICATOR_SIZE);

}


- (void)setItem:(IQConversationMember *)item {
    _item = item;
  
    _onlineIndicator.online = item.online.boolValue;
    
    if([_item.thumbUrl length] > 0) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:_item.thumbUrl]
                          placeholderImage:[UIImage imageNamed:@"default_avatar.png"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     [self setNeedsDisplay];
                                 }];
    }
    
    self.textLabel.text = _item.displayName;
}

- (void)setDeleteEnabled:(BOOL)enabled {
    if (enabled) {
        NSMutableArray *rightUtilityButtons = [NSMutableArray array];
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexInt:0x3b5b78]
                                                     icon:[UIImage imageNamed:@"delete_ico.png"]];
        [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:68.0f];
    }
    else {
        [self hideUtilityButtonsAnimated:NO];
        [self setRightUtilityButtons:nil];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.textLabel.highlightedTextColor = [UIColor whiteColor];
    self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
    
    [self hideUtilityButtonsAnimated:NO];
    [self setRightUtilityButtons:nil];
}

@end
