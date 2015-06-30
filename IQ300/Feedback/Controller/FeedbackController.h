//
//  FeedbackController.h
//  IQ300
//
//  Created by Tayphoon on 30.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTabBarController.h"

@class IQManagedFeedback;

@interface FeedbackController : IQTabBarController

@property (nonatomic, strong) IQManagedFeedback * feedback;

@end
