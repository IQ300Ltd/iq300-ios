//
//  TaskExecutersCell.m
//  IQ300
//
//  Created by Tayphoon on 17.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TaskExecutersCell.h"
#import "TaskExecutor.h"

@implementation TaskExecutersCell

@dynamic item;

+ (CGFloat)heightForItem:(NSArray*)item detailTitle:(NSString*)detailTitle width:(CGFloat)width {
    NSString * text = [NSString stringWithFormat:@"%@: %lu", NSLocalizedString(detailTitle, nil),
                                                             (unsigned long)[item count]];
    
    return [IQDetailsTextCell heightForItem:text detailTitle:detailTitle width:width];
}

- (void)setItem:(NSArray *)items {
    [super setItem:items];
    
    if ([items count] > 1) {
        self.titleTextView.text = [NSString stringWithFormat:@"%@: %lu", NSLocalizedString(@"Executors", nil),
                                                                         (unsigned long)[items count]];
    }
    else if([items count] == 1) {
        TaskExecutor * executor = [items firstObject];
        self.titleTextView.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Executor", nil),
                                                                        executor.executorName];
    }
}

@end
