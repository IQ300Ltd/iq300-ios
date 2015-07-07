//
//  FeedbackCategoryCell.h
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQSelectableTextCell.h"

@class IQFeedbackCategory;

@interface FeedbackCategoryCell : IQSelectableTextCell

@property (nonatomic, strong) IQFeedbackCategory * item;

@end
