//
//  IQComplexityEstimatedTimeDoubleCell.h
//  IQ300
//
//  Created by Vladislav Grigoriev on 09/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskComplexityCell.h"
#import "IQEstimatedTimeCell.h"

@class IQComplexity;

@interface IQComplexityEstimatedTimeDoubleCell : UITableViewCell

@property (nonatomic, strong) TaskComplexityCell *complexityCell;
@property (nonatomic, strong) IQEstimatedTimeCell *estimatedCell;


+ (CGFloat)heightForComplexity:(IQComplexity *)compexity estimatedTime:(NSNumber *)esimatedTime widht:(CGFloat)widht;

- (void)setComplexity:(IQComplexity *)complexity estimatedTime:(NSNumber *)estimatedTime;

@end
