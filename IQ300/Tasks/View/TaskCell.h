//
//  TaskCell.h
//  IQ300
//
//  Created by Tayphoon on 19.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IQTask;

@interface TaskCell : UITableViewCell {
    UIEdgeInsets _contentInsets;
    UIEdgeInsets _contentBackgroundInsets;
}

@property (nonatomic, readonly) UIView * contentBackgroundView;
@property (nonatomic, readonly) UILabel * titleLabel;
@property (nonatomic, readonly) UILabel * taskIDLabel;
@property (nonatomic, readonly) UILabel * fromLabel;
@property (nonatomic, readonly) UILabel * toLabel;
@property (nonatomic, readonly) UIImageView * dueIconImageView;
@property (nonatomic, readonly) UILabel * dueDateLabel;
@property (nonatomic, readonly) UIImageView * communityImageView;
@property (nonatomic, readonly) UILabel * communityNameLabel;
@property (nonatomic, readonly) UIImageView * messagesImageView;
@property (nonatomic, readonly) UILabel * commentsCountLabel;
@property (nonatomic, readonly) UILabel * statusLabel;
@property (nonatomic, readonly) UIView * leftView;

@property (nonatomic, assign) BOOL highlightTasks;

@property (nonatomic, strong) IQTask * item;

+ (CGFloat)heightForItem:(IQTask *)item andCellWidth:(CGFloat)cellWidth;

@end
