//
//  FeedbackCell.h
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IQManagedFeedback;

@interface FeedbackCell : UITableViewCell

@property (nonatomic, readonly) UIImageView * typeImageView;
@property (nonatomic, readonly) UILabel * titleLabel;
@property (nonatomic, readonly) UILabel * dateLabel;
@property (nonatomic, readonly) UILabel * descriptionLabel;
@property (nonatomic, readonly) UIImageView * attachImageView;
@property (nonatomic, readonly) UILabel * authorLabel;
@property (nonatomic, readonly) UIImageView * messagesImageView;
@property (nonatomic, readonly) UILabel * commentsCountLabel;
@property (nonatomic, readonly) UILabel * statusLabel;
@property (nonatomic, strong) IQManagedFeedback * item;

+ (CGFloat)heightForItem:(IQManagedFeedback *)item andCellWidth:(CGFloat)cellWidth;

@end
