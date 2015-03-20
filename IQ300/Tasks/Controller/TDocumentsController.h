//
//  TDocumentsController.h
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "TAttachmentsModel.h"

@class IQTask;

@interface TDocumentsController : IQTableBaseController

@property (nonatomic, strong) TAttachmentsModel * model;

- (void)setAttachments:(NSArray*)attachments;

@end
