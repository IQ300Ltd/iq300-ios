//
//  TaskExecutersCell.h
//  IQ300
//
//  Created by Tayphoon on 17.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQDetailsTextCell.h"

@interface TaskExecutersCell : IQDetailsTextCell

@property (nonatomic, strong) NSArray * item;

+ (CGFloat)heightForItem:(NSArray*)item detailTitle:(NSString*)detailTitle width:(CGFloat)width;

@end
