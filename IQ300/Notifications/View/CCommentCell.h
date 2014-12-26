//
//  CCommentCell.h
//  IQ300
//
//  Created by Tayphoon on 24.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

#define COMMENT_CELL_MAX_HEIGHT CGFLOAT_MAX
#define COMMENT_CELL_MIN_HEIGHT 55.0f

@class IQComment;

@interface CCommentCell : UITableViewCell {
    UIEdgeInsets _contentInsets;
}

@property (nonatomic, strong) UIView * contentBackgroundView;
@property (nonatomic, strong) UILabel * dateLabel;
@property (nonatomic, strong) UILabel * userNameLabel;
@property (nonatomic, strong) UILabel * descriptionLabel;
@property (nonatomic, readonly) NSArray * attachButtons;

@property (nonatomic, strong) NSString * author;
@property (nonatomic, strong) IQComment * item;
@property (nonatomic, assign, getter=isCommentHighlighted) BOOL commentHighlighted;

+ (CGFloat)heightForItem:(IQComment *)item andCellWidth:(CGFloat)cellWidth;

@end
