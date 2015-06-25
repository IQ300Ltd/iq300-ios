//
//  FeedbacksModel.m
//  IQ300
//
//  Created by Tayphoon on 23.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "FeedbacksModel.h"

@implementation FeedbacksModel

- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion {
    if (completion) {
        completion(nil);
    }
}

@end
