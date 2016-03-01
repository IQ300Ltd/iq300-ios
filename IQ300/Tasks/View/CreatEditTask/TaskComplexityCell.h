//
//  TaskComplexityCell.h
//  IQ300
//
//  Created by Vladislav Grigoryev on 29/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQSelectableTextCell.h"

@class IQComplexity;

@interface TaskComplexityCell : IQDetailsTextCell

@property (nonatomic, strong) IQComplexity * item;

+ (CGFloat)heightForItem:(IQComplexity*)item detailTitle:(NSString*)detailTitle width:(CGFloat)width;

@end
