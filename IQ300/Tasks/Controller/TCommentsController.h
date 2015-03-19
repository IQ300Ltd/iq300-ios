//
//  TCommentsController.h
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "CommentsController.h"

@class IQTask;

@interface TCommentsController : CommentsController

@property (nonatomic, strong) IQTask * task;

@end
