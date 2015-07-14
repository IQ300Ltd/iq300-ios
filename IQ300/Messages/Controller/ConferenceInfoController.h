//
//  ConferenceInfoController.h
//  IQ300
//
//  Created by Tayphoon on 13.07.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "ConferenceInfoModel.h"

@interface ConferenceInfoController : IQTableBaseController

@property (nonatomic, strong) ConferenceInfoModel * model;
@property (nonatomic, strong) NSNumber * conversationId;
@property (nonatomic, strong) NSString * conversationTitle;

@end
