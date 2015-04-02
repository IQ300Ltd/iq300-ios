//
//  TCommentsController.h
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "CommentsController.h"
#import "TaskTabItemController.h"

@class IQTask;

@interface TCommentsController : CommentsController<TaskTabItemController>

@property (nonatomic, strong) NSNumber * taskId;
@property (nonatomic, strong) NSNumber * discussionId;
@property (nonatomic, strong) NSNumber * badgeValue;
@property (nonatomic, weak) TaskPolicyInspector * policyInspector;

@end
