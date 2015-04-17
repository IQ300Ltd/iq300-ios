//
//  CommunitiesController.h
//  IQ300
//
//  Created by Tayphoon on 15.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "CommunitiesModel.h"
#import "TaskFieldEditController.h"

@class IQCommunity;

@interface CommunitiesController : IQTableBaseController<TaskFieldEditController>

@property (nonatomic, strong) NSIndexPath * fieldIndexPath;
@property (nonatomic, strong) IQCommunity * fieldValue;

@property (nonatomic, strong) CommunitiesModel * model;
@property (nonatomic, weak) id delegate;

@end
