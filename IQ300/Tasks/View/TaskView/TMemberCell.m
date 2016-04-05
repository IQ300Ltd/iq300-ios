//
//  TMemberCell.m
//  IQ300
//
//  Created by Tayphoon on 25.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>

#import "TMemberCell.h"
#import "IQTaskMember.h"
#import "IQUser.h"
#import "IQOnlineIndicator.h"

#define SELECTED_BBACKGROUND_COLOR [UIColor colorWithHexInt:0x2e4865]
#define TEXT_COLOR [UIColor colorWithHexInt:0x2c74a4]
#define DETAIL_TEXT_COLOR [UIColor colorWithHexInt:0x8e8d8e]
#define SELECTED_TEXT_COLOR [UIColor whiteColor]

@interface TMemberCell() {
    UIView * _selectedBackgroundView;
}

@end

@implementation TMemberCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        UIView * contentView = [super valueForKey:@"_contentCellView"];
        contentView.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor colorWithHexInt:0x3b5b78];
        
        _selectedBackgroundView = [[UIView alloc] init];
        [_selectedBackgroundView setBackgroundColor:SELECTED_BBACKGROUND_COLOR];
        [self setSelectedBackgroundView:_selectedBackgroundView];
        
        self.textLabel.font = [UIFont fontWithName:IQ_HELVETICA size:15];
        self.textLabel.textColor = TEXT_COLOR;
        self.textLabel.backgroundColor = [UIColor whiteColor];
        self.textLabel.highlightedTextColor = [UIColor whiteColor];

        self.detailTextLabel.font = [UIFont fontWithName:IQ_HELVETICA size:12];
        self.detailTextLabel.textColor = DETAIL_TEXT_COLOR;
        self.detailTextLabel.backgroundColor = [UIColor whiteColor];
        self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        
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
    
    _onlineIndicator.frame = CGRectMake(CGRectRight(self.textLabel.frame) + ONLINE_INDICATOR_LEFT_OFFSET,
                                        self.textLabel.frame.origin.y + (self.textLabel.bounds.size.height - ONLINE_INDICATOR_SIZE) / 2.0f,
                                        ONLINE_INDICATOR_SIZE,
                                        ONLINE_INDICATOR_SIZE);

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.textLabel.textColor = (selected) ? SELECTED_TEXT_COLOR : TEXT_COLOR;
    self.detailTextLabel.textColor = (selected) ? SELECTED_TEXT_COLOR : DETAIL_TEXT_COLOR;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.textLabel.textColor = (highlighted) ? SELECTED_TEXT_COLOR : TEXT_COLOR;
    self.detailTextLabel.textColor = (highlighted) ? SELECTED_TEXT_COLOR : DETAIL_TEXT_COLOR;
}

- (void)setItem:(IQTaskMember *)item {
    _item = item;
    
    if([_item.user.thumbUrl length] > 0) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:_item.user.thumbUrl]
                          placeholderImage:[UIImage imageNamed:@"default_avatar.png"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     [self setNeedsDisplay];
                                 }];
    }
    _onlineIndicator.online = _item.user.online.boolValue;

    self.textLabel.text = _item.user.displayName;
    self.detailTextLabel.numberOfLines = 0;
    
    UIFont * font = [UIFont fontWithName:IQ_HELVETICA
                                    size:(IS_IPAD) ? 14.0f : 13.0f];
    NSMutableParagraphStyle * paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.maximumLineHeight = 1000;
    paragraphStyle.minimumLineHeight = 3;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.lineSpacing = 3.0f;
    
    NSMutableDictionary * attributes = @{
                                         NSParagraphStyleAttributeName  : paragraphStyle,
                                         NSForegroundColorAttributeName : [UIColor colorWithHexInt:0x9f9f9f],
                                         NSFontAttributeName            : font
                                         }.mutableCopy ;
    
    NSMutableAttributedString * detailText = [[NSMutableAttributedString alloc] init];
    
    if ([_item.user.email length] > 0) {
        NSAttributedString * emailString = [[NSAttributedString alloc] initWithString:_item.user.email
                                                                           attributes:attributes];
        [detailText appendAttributedString:emailString];
    }
    
    if([_item.taskRoleName length] > 0) {
        [attributes setValue:[UIFont fontWithName:IQ_HELVETICA size:10] forKey:NSFontAttributeName];
        
        NSAttributedString * taskRoleName = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", item.taskRoleName]
                                                                            attributes:attributes];
        [detailText appendAttributedString:taskRoleName];
    }
    self.detailTextLabel.attributedText = detailText;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.textLabel.highlightedTextColor = [UIColor whiteColor];
    self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];

    [self hideUtilityButtonsAnimated:NO];
    [self setRightUtilityButtons:nil];
}

- (void)setAvailableActions:(NSArray *)availableActions {
    _availableActions = availableActions;
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray array];
    if ([_availableActions containsObject:@"destroy"] ||
        [_availableActions containsObject:@"leave"]) {
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexInt:0x3b5b78]
                                                     icon:[UIImage imageNamed:@"delete_ico.png"]];
    }
    [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:68.0f];
}

@end
