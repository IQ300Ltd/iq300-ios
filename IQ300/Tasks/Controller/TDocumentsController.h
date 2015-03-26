//
//  TDocumentsController.h
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "TAttachmentsModel.h"
#import "TaskTabItemController.h"

@class IQTask;

@interface TDocumentsController : IQTableBaseController<TaskTabItemController>

@property (nonatomic, strong) NSNumber * taskId;
@property (nonatomic, strong) TAttachmentsModel * model;
@property (nonatomic, strong) NSNumber * badgeValue;
@property (nonatomic, readonly) NSString * category;
@property (nonatomic, weak) TaskPolicyInspector * policyInspector;

@end
