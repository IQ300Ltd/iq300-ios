//
//  CommentCell.h
//  IQ300
//
//  Created by Tayphoon on 04.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

#define COMMENT_CELL_MAX_HEIGHT CGFLOAT_MAX
#define COMMENT_CELL_MIN_HEIGHT 48.0f

@class IQComment;

@interface CommentCell : UITableViewCell {
    UIEdgeInsets _contentInsets;
}

@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UIView * contentBackgroundView;
@property (nonatomic, strong) UILabel * descriptionLabel;
@property (nonatomic, readonly) NSArray * attachButtons;
@property (nonatomic, strong) UIImageView * statusImageView;

@property (nonatomic, strong) IQComment * item;

+ (CGFloat)heightForItem:(IQComment *)item andCellWidth:(CGFloat)cellWidth;

@end
