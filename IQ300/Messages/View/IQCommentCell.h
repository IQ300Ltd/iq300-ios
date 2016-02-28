//
//  IQCommentCell.h
//  IQ300
//
//  Created by Tayphoon on 27.07.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IQComment;

@protocol IQCommentCell <NSObject>

@property (nonatomic, readonly) UITextView * descriptionTextView;
@property (nonatomic, readonly) UIButton * expandButton;
@property (nonatomic, readonly) NSArray * attachButtons;

@property (nonatomic, strong) IQComment * item;
@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
@property (nonatomic, assign, getter=isExpandable) BOOL expandable;

@property (nonatomic, strong) NSString *currentUserNick;
@property (nonatomic, weak) NSArray *avalibleNicks;

+ (CGFloat)heightForItem:(IQComment *)item expanded:(BOOL)expanded сellWidth:(CGFloat)cellWidth;
+ (BOOL)cellNeedToBeExpandableForItem:(IQComment *)item сellWidth:(CGFloat)cellWidth;

@end
