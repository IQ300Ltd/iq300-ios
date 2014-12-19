//
//  MessagesController.h
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "MessagesModel.h"

@interface MessagesController : IQTableBaseController

@property (nonatomic, strong) MessagesModel * model;

- (void)updateGlobalCounter;

@end
