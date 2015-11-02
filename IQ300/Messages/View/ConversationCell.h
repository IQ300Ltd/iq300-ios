//
//  ConversationCell.h
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IQBadgeView;
@class IQConversation;
@class IQUser;

#define CONVERSATION_CELL_MAX_HEIGHT 86.0f
#define CONVERSATION_CELL_MIN_HEIGHT 55.0f

@interface ConversationCell : UITableViewCell {
    UIEdgeInsets _contentInsets;
    UIEdgeInsets _contentBackgroundInsets;
}

@property (nonatomic, strong) UIView * contentBackgroundView;
@property (nonatomic, strong) UIImageView * userImageView;
@property (nonatomic, strong) UILabel * dateLabel;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * descriptionLabel;
@property (nonatomic, strong) UIButton * attachButton;
@property (nonatomic, readonly) IQBadgeView * badgeView;

@property (nonatomic, strong) IQConversation * item;

@property (nonatomic, readonly) IQUser * companion;

+ (CGFloat)heightForItem:(IQConversation *)item andCellWidth:(CGFloat)cellWidth;

@end
