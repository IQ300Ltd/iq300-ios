//
//  CommentCell.h
//  IQ300
//
//  Created by Tayphoon on 04.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

#define COMMENT_CELL_MAX_HEIGHT 86.0f
#define COMMENT_CELL_MIN_HEIGHT 55.0f

@class IQComment;

@interface CommentCell : UITableViewCell {
    UIEdgeInsets _contentInsets;
}

@property (nonatomic, strong) UIView * contentBackgroundView;
@property (nonatomic, strong) UILabel * dateLabel;
@property (nonatomic, strong) UILabel * userNameLabel;
@property (nonatomic, strong) UILabel * descriptionLabel;

@property (nonatomic, strong) IQComment * item;

+ (CGFloat)heightForItem:(IQComment *)item andCellWidth:(CGFloat)cellWidth;

@end
