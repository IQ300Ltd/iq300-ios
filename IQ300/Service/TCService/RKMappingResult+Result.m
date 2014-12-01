//
//  RKMappingResult+Result.m
//  IQ300
//
//  Created by Tayphoon on 14.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "RKMappingResult+Result.h"

@implementation RKMappingResult (Result)

- (id)result {
    NSArray * result = self.array;
    return ([result count] > 0) ? result : [result firstObject];
}

@end
