//
//  TaskComplexityPickerCell.m
//  IQ300
//
//  Created by Vladislav Grigoryev on 29/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "TaskComplexityPickerCell.h"
#import "IQComplexity.h"


@implementation TaskComplexityPickerCell

@dynamic item;

+ (CGFloat)heightForItem:(IQComplexity*)item detailTitle:(NSString*)detailTitle width:(CGFloat)width {
    NSString * text = item.displayName;
    return [IQSelectableTextCell heightForItem:text detailTitle:detailTitle width:width];
}

- (void)setItem:(IQComplexity *)item {
    [super setItem:item];
    
    if (item) {
        self.titleTextView.text = item.displayName;
    }
}

@end
