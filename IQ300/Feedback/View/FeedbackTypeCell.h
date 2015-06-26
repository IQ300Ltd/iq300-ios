//
//  FeedbackTypeCell.h
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQSelectableTextCell.h"

@class IQFeedbackType;

@interface FeedbackTypeCell : IQSelectableTextCell

@property (nonatomic, strong) IQFeedbackType * item;

@end
