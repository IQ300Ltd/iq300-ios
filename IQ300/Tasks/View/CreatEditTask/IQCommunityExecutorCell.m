//
//  IQCommunityExecutorCell.m
//  IQ300
//
//  Created by Tayphoon on 19.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQCommunityExecutorCell.h"
#import "IQCommunity.h"
#import "TaskExecutor.h"

@implementation IQCommunityExecutorCell

+ (CGFloat)heightForItem:(id)item detailTitle:(NSString *)detailTitle width:(CGFloat)width {
    if ([item isKindOfClass:[IQCommunity class]]) {
        NSString * text = ((IQCommunity*)item).title;
        return [IQDoubleDetailsTextCell heightForItem:text detailTitle:detailTitle width:width];
    }
    return [IQDoubleDetailsTextCell heightForItem:item detailTitle:detailTitle width:width];
}

- (void)setItem:(NSArray *)items {
    [super setItem:items];
    
    IQCommunity * community = (IQCommunity*)[items firstObject];
    self.titleTextView.text = community.title;
    NSArray * executors = ((NSNull*)[items lastObject] != [NSNull null]) ? [items lastObject] : nil;
    if ([executors count] > 1) {
        self.secondTitleTextView.text = [NSString stringWithFormat:@"%@: %lu", NSLocalizedString(@"Executors", nil),
                                         (unsigned long)[executors count]];
    }
    else if([executors count] == 1) {
        TaskExecutor * executor = [executors firstObject];
        self.secondTitleTextView.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Executor", nil),
                                         executor.executorName];
    }
}

@end
