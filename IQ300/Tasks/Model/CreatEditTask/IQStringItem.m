//
//  IQStringItem.m
//  IQ300
//
//  Created by Vladislav Grigoriev on 09/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQStringItem.h"

@implementation IQStringItem

- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    if (self) {
        _string = string;
    }
    return self;
}
@end
