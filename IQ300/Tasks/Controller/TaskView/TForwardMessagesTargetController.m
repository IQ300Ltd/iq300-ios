//
//  TForwardMessagesTargetController.m
//  IQ300
//
//  Created by Viktor Shabanov on 4/5/17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import "TForwardMessagesTargetController.h"

@interface TForwardMessagesTargetController ()

@end

@implementation TForwardMessagesTargetController

- (NSArray *)showableViewControllersStackFromCurrentStack:(NSArray *)currentStack
                                  forTargetViewController:(UIViewController *)viewController {
    
    NSMutableArray *showableStack = [currentStack subarrayWithRange:NSMakeRange(0, 2)].mutableCopy;
    [showableStack addObject:viewController];
    
    return [showableStack copy];
}

@end
