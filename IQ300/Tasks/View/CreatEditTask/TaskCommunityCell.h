//
//  TaskCommunityCell.h
//  IQ300
//
//  Created by Tayphoon on 17.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQDetailsTextCell.h"

@class IQCommunity;

@interface TaskCommunityCell : IQDetailsTextCell

@property (nonatomic, strong) IQCommunity * item;

+ (CGFloat)heightForItem:(IQCommunity*)item detailTitle:(NSString*)detailTitle width:(CGFloat)width;

@end
