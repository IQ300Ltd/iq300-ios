//
//  TDocumentsController.h
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TCCollectionController.h"
#import "TaskAttachmentsModel.h"
#import "TaskTabItemController.h"

@class IQTask;

@interface TDocumentsController : TCCollectionController<TaskTabItemController>

@property (nonatomic, strong) NSNumber * taskId;
@property (nonatomic, strong) TaskAttachmentsModel * model;
@property (nonatomic, strong) NSNumber * badgeValue;
@property (nonatomic, readonly) NSString * category;
@property (nonatomic, weak) TaskPolicyInspector * policyInspector;

@end
