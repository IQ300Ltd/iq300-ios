//
//  CCommentCell.h
//  IQ300
//
//  Created by Tayphoon on 24.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <SWTableViewCell/SWTableViewCell.h>

#import "IQTextView.h"

#define COMMENT_CELL_MAX_HEIGHT CGFLOAT_MAX
#ifdef IPAD
#define COMMENT_CELL_MIN_HEIGHT 63.5f
#define DESCRIPTION_LABEL_FONT [UIFont fontWithName:IQ_HELVETICA size:14]
#define COLLAPSED_COMMENT_CELL_MAX_HEIGHT 198.0f
#else
#define COMMENT_CELL_MIN_HEIGHT 55.0f
#define DESCRIPTION_LABEL_FONT [UIFont fontWithName:IQ_HELVETICA size:13]
#define COLLAPSED_COMMENT_CELL_MAX_HEIGHT 195.0f
#endif

@class IQComment;

@interface CCommentCell : SWTableViewCell {
    UIEdgeInsets _contentInsets;
    UIEdgeInsets _contentBackgroundInsets;
}

@property (nonatomic, strong) UIView * contentBackgroundView;
@property (nonatomic, strong) UILabel * dateLabel;
@property (nonatomic, strong) UILabel * userNameLabel;
@property (nonatomic, strong) IQTextView * descriptionTextView;
@property (nonatomic, strong) UIButton * expandButton;
@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
@property (nonatomic, assign, getter=isExpandable) BOOL expandable;
@property (nonatomic, assign, getter=isCommentHighlighted) BOOL commentHighlighted;
@property (nonatomic, readonly) NSArray * attachButtons;

@property (nonatomic, strong) NSString * author;
@property (nonatomic, strong) IQComment * item;

+ (CGFloat)heightForItem:(IQComment *)item expanded:(BOOL)expanded andCellWidth:(CGFloat)cellWidth;
+ (BOOL)cellNeedToBeExpandableForItem:(IQComment *)item andCellWidth:(CGFloat)cellWidth;

@end
