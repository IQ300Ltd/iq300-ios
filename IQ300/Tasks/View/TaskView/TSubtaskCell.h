//
//  TSubtaskCell.h
//  IQ300
//
//  Created by Vladislav Grigoriev on 22/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IQSubtask;

@interface TSubtaskCell : UITableViewCell {
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
@property (nonatomic, readonly) UILabel * statusLabel;
@property (nonatomic, readonly) UIView * leftView;

@property (nonatomic, assign) BOOL highlightTasks;

@property (nonatomic, strong) IQSubtask * item;

+ (CGFloat)heightForItem:(IQSubtask *)item andCellWidth:(CGFloat)cellWidth;

@end
