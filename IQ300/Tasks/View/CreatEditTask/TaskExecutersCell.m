//
//  TaskExecutersCell.m
//  IQ300
//
//  Created by Tayphoon on 17.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TaskExecutersCell.h"

@implementation TaskExecutersCell

@dynamic item;

+ (CGFloat)heightForItem:(NSArray*)item detailTitle:(NSString*)detailTitle width:(CGFloat)width {
    NSString * text = [NSString stringWithFormat:@"%@: %lu", NSLocalizedString(detailTitle, nil),
                                                             (unsigned long)[item count]];
    
    return [IQDetailsTextCell heightForItem:text detailTitle:detailTitle width:width];
}

- (void)setItem:(NSArray *)items {
    [super setItem:items];
    
    if ([items count] > 0) {
        self.titleTextView.text = [NSString stringWithFormat:@"%@: %lu", NSLocalizedString(self.detailTitle, nil),
                                                                         (unsigned long)[items count]];
    }
}

@end
