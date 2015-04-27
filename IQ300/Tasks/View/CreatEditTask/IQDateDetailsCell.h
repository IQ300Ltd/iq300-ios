//
//  IQDateDetailsCell.h
//  IQ300
//
//  Created by Tayphoon on 17.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQDetailsTextCell.h"

@interface IQDateDetailsCell : IQDetailsTextCell

@property (nonatomic, strong) NSDate * item;

+ (CGFloat)heightForItem:(NSDate*)item detailTitle:(NSString*)detailTitle width:(CGFloat)width;

@end
