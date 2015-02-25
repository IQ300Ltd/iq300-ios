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
}

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * taskIDLabel;
@property (nonatomic, strong) UILabel * fromLabel;
@property (nonatomic, strong) UILabel * toLabel;
@property (nonatomic, strong) UIImageView * dueIconImageVIew;
@property (nonatomic, strong) UILabel * dueDateLabel;
@property (nonatomic, strong) UIImageView * communityImageVIew;
@property (nonatomic, strong) UILabel * communityNameLabel;
@property (nonatomic, strong) UIImageView * messagesImageVIew;
@property (nonatomic, strong) UILabel * commentsCountLabel;
@property (nonatomic, strong) UILabel * statusLabel;

@property (nonatomic, strong) IQTask * item;

+ (CGFloat)heightForItem:(IQTask *)item andCellWidth:(CGFloat)cellWidth;

@end
