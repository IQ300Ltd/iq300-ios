//
//  CommentCell.h
//  IQ300
//
//  Created by Tayphoon on 04.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQCommentCell.h"
#import "IQTextView.h"

#define COMMENT_CELL_MAX_HEIGHT CGFLOAT_MAX
#define COMMENT_CELL_MIN_HEIGHT 47.0f

@class IQAttachmentsView;
@class IQOnlineIndicator;

@interface CommentCell : UITableViewCell<IQCommentCell> {
    UIEdgeInsets _contentInsets;
}

@property (nonatomic, readonly) UILabel * timeLabel;
@property (nonatomic, readonly) UILabel *forwardInfoLabel;
@property (nonatomic, readonly) UIImageView * userImageView;
@property (nonatomic, readonly) UILabel * userNameLabel;
@property (nonatomic, readonly) IQTextView * descriptionTextView;
@property (nonatomic, strong) IQOnlineIndicator *onlineIndicator;
@property (nonatomic, readonly) UIImageView * statusImageView;
@property (nonatomic, readonly) UIButton * expandButton;
@property (nonatomic, readonly) IQAttachmentsView *attachmentsView;

@property (nonatomic, readonly) NSArray * attachButtons;

@property (nonatomic, strong) IQComment * item;
@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
@property (nonatomic, assign, getter=isExpandable) BOOL expandable;

@property (nonatomic, strong) NSString *currentUserNick;
@property (nonatomic, weak) NSArray *avalibleNicks;

+ (CGFloat)heightForItem:(IQComment *)item expanded:(BOOL)expanded сellWidth:(CGFloat)cellWidth;
+ (BOOL)cellNeedToBeExpandableForItem:(IQComment *)item сellWidth:(CGFloat)cellWidth;

@end
