//
//  CommentCell.h
//  IQ300
//
//  Created by Tayphoon on 04.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

#define COMMENT_CELL_MAX_HEIGHT CGFLOAT_MAX
#define COLLAPSED_COMMENT_CELL_MAX_HEIGHT 182.0f
#define COMMENT_CELL_MIN_HEIGHT 47.0f

@class IQComment;

@interface CommentCell : UITableViewCell {
    UIEdgeInsets _contentInsets;
}

@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UIView * contentBackgroundView;
@property (nonatomic, strong) UITextView * descriptionTextView;
@property (nonatomic, strong) UIImageView * statusImageView;
@property (nonatomic, strong) UIButton * expandButton;
@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
@property (nonatomic, assign, getter=isExpandable) BOOL expandable;
@property (nonatomic, readonly) NSArray * attachButtons;

@property (nonatomic, strong) IQComment * item;

+ (CGFloat)heightForItem:(IQComment *)item expanded:(BOOL)expanded;
+ (BOOL)cellNeedToBeExpandableForItem:(IQComment *)item;

@end
