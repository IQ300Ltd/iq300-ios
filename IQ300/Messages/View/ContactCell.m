//
//  ContactCell.m
//  IQ300
//
//  Created by Tayphoon on 09.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <SDWebImage/UIImageView+WebCache.h>

#import "ContactCell.h"
#import "IQUser.h"
#import "IQContact.h"

#define SELECTED_BBACKGROUND_COLOR [UIColor colorWithHexInt:0x2e4865]
#define CONTACT_NAME_COLOR [UIColor colorWithHexInt:0x2c74a4]
#define DETAIL_TEXT_COLOR [UIColor colorWithHexInt:0x8e8d8e]
#define SELECTED_CONTACT_NAME_COLOR [UIColor whiteColor]

@interface ContactCell() {
    UIView * _selectedBackgroundView;
}

@end

@implementation ContactCell

@dynamic item;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        self.textLabel.font = [UIFont fontWithName:IQ_HELVETICA size:15];
        self.textLabel.textColor = CONTACT_NAME_COLOR;
        self.textLabel.highlightedTextColor = [UIColor whiteColor];

        self.detailTextLabel.font = [UIFont fontWithName:IQ_HELVETICA size:12];
        self.detailTextLabel.textColor = DETAIL_TEXT_COLOR;
        self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        
        CALayer *cellImageLayer = self.imageView.layer;
        [cellImageLayer setCornerRadius:17.5];
        [cellImageLayer setMasksToBounds:YES];
    }
    
    return self;
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//    self.textLabel.textColor = (selected) ? SELECTED_CONTACT_NAME_COLOR : CONTACT_NAME_COLOR;
//    self.detailTextLabel.textColor = (selected) ? SELECTED_CONTACT_NAME_COLOR : DETAIL_TEXT_COLOR;
//}
//
//- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
//    [super setHighlighted:highlighted animated:animated];
//    self.textLabel.textColor = (highlighted) ? SELECTED_CONTACT_NAME_COLOR : CONTACT_NAME_COLOR;
//    self.detailTextLabel.textColor = (highlighted) ? SELECTED_CONTACT_NAME_COLOR : DETAIL_TEXT_COLOR;
//}

- (void)setItem:(IQContact *)item {
    super.item = item;
    
    self.textLabel.text = item.user.displayName;
    self.detailTextLabel.text = item.user.email;
    
    if([item.user.thumbUrl length] > 0) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:item.user.thumbUrl]
                          placeholderImage:[UIImage imageNamed:@"default_avatar.png"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     [self setNeedsDisplay];
                                 }];
    }
}

@end
