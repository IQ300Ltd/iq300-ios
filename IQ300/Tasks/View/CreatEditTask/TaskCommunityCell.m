//
//  TaskCommunityCell.m
//  IQ300
//
//  Created by Tayphoon on 17.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TaskCommunityCell.h"
#import "IQCommunity.h"

@implementation TaskCommunityCell

@dynamic item;

+ (CGFloat)heightForItem:(IQCommunity*)item detailTitle:(NSString*)detailTitle width:(CGFloat)width {
    NSString * text = item.title;
    return [IQDetailsTextCell heightForItem:text detailTitle:detailTitle width:width];
}

- (void)setItem:(IQCommunity*)item {
    [super setItem:item];
    
    if (item) {
        self.titleTextView.text = item.title;
    }
}

@end
