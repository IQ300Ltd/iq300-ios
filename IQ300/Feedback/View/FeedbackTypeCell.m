//
//  FeedbackTypeCell.m
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "FeedbackTypeCell.h"
#import "IQFeedbackType.h"

@implementation FeedbackTypeCell

@dynamic item;

- (void)setItem:(IQFeedbackType*)item {
    [super setItem:item];
    self.titleTextView.text = item.localizedTitle;
}

@end
