//
//  FeedbackView.h
//  IQ300
//
//  Created by Tayphoon on 30.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IQManagedFeedback;

@interface FeedbackView : UIView

@property (nonatomic, readonly) UILabel * dateLabel;
@property (nonatomic, readonly) UILabel * statusLabel;
@property (nonatomic, readonly) UILabel * feedbackTypeLabel;
@property (nonatomic, readonly) UILabel * feedbackCategoryLabel;
@property (nonatomic, readonly) UILabel * authorLabel;
@property (nonatomic, readonly) UILabel * descriptionLabel;

@property (nonatomic, readonly) NSArray * attachButtons;

+ (CGFloat)heightForFeedback:(IQManagedFeedback*)feedback width:(CGFloat)width;

- (void)updateViewWithFeedback:(IQManagedFeedback*)feedback;

@end
