//
//  TaskComplexityPickerCell.h
//  IQ300
//
//  Created by Vladislav Grigoryev on 29/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "TaskComplexityCell.h"

@class IQComplexity;

@interface TaskComplexityPickerCell : IQSelectableTextCell

@property (nonatomic, strong) IQComplexity * item;

+ (CGFloat)heightForItem:(IQComplexity*)item detailTitle:(NSString*)detailTitle width:(CGFloat)width;

@end
