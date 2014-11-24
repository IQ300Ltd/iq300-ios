//
//  IQRefreshControl.m
//  IQ300
//
//  Created by Tayphoon on 24.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQRefreshControl.h"

@implementation IQRefreshControl

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        [self setValue:[NSValue valueWithUIEdgeInsets:UIEdgeInsetsZero] forKey:@"_appliedInsets"];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    NSLog(@"Frame (%f, %f, %f, %f)", self.frame.origin.x , self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSLog(@"Frame (%f, %f, %f, %f)", self.frame.origin.x , self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

@end
