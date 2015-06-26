//
//  FeedbackCategoryCell.m
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "FeedbackCategoryCell.h"
#import "IQFeedbackCategory.h"

@implementation FeedbackCategoryCell

@dynamic item;

- (void)setItem:(IQFeedbackCategory *)item {
    [super setItem:item];
    self.titleTextView.text = item.title;
}

@end
