//
//  IQTaskCommunityItem.m
//  IQ300
//
//  Created by Vladislav Grigoriev on 10/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQTaskCommunityItem.h"
#import "IQTask.h"
#import "IQCommunity.h"

@implementation IQTaskCommunityItem

- (instancetype)initWithTask:(id)task {
    NSAssert(task, @"Task expected");
    NSAssert([task respondsToSelector:@selector(community)], @"Task dont respond to description selector");
    IQCommunity *community = [task community];
    NSString *placeholder = NSLocalizedString(@"Community", nil);
    
    self = [super initWithText:community.title placeholder:placeholder];
    if (self) {
        self.accessoryImageName = @"right_gray_arrow.png";
        self.enabled = [task taskId] == nil;
    }
    return self;
}

- (void)setTask:(id)task {
    IQCommunity *community = [task community];
    self.text = community.title;
    self.enabled = [task taskId] == nil;
}

- (void)updateWithTask:(id)task value:(id)value {
    [task setCommunity:value];
    [self setTask:task];
}

@end
