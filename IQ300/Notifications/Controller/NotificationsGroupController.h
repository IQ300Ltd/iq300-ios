//
//  NotificationsGroupController.h
//  IQ300
//
//  Created by Tayphoon on 28.01.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "NGroupModel.h"
@interface NotificationsGroupController : IQTableBaseController

@property (nonatomic, strong) NGroupModel * model;

- (void)updateGlobalCounter;

@end