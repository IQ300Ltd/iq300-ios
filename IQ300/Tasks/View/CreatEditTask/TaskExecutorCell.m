//
//  TaskExecutorCell.m
//  IQ300
//
//  Created by Tayphoon on 20.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TaskExecutorCell.h"
#import "TaskExecutor.h"
#import "IQOnlineIndicator.h"

@implementation TaskExecutorCell

@dynamic item;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _onlineIndicator = [[IQOnlineIndicator alloc] init];
        [self.contentView addSubview:_onlineIndicator];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize titleSize = [self.titleTextView sizeThatFits:CGSizeMake(self.titleTextView.bounds.size.width - ONLINE_INDICATOR_LEFT_OFFSET - ONLINE_INDICATOR_SIZE, self.titleTextView.bounds.size.height)];
    self.titleTextView.frame = CGRectMake(self.titleTextView.frame.origin.x, self.titleTextView.frame.origin.y, titleSize.width, self.titleTextView.bounds.size.height);
    
    _onlineIndicator.frame = CGRectMake(CGRectRight(self.titleTextView.frame) + ONLINE_INDICATOR_LEFT_OFFSET,
                                        self.titleTextView.frame.origin.y + (self.titleTextView.bounds.size.height - ONLINE_INDICATOR_SIZE) / 2.0f,
                                        ONLINE_INDICATOR_SIZE,
                                        ONLINE_INDICATOR_SIZE);
}

- (void)setItem:(TaskExecutor *)item {
    [super setItem:item];
    
    self.titleTextView.text = item.executorName;
    _onlineIndicator.online = item.online.boolValue;
}


@end
