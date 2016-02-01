//
//  DiscussionController.h
//  IQ300
//
//  Created by Tayphoon on 04.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "DiscussionModel.h"

@class IQConversation;
@class IQAttachment;

@interface SharingDiscussionController : IQTableBaseController

@property (nonatomic, strong) DiscussionModel * model;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (instancetype)initWithAttachment:(IQAttachment *)attachment NS_DESIGNATED_INITIALIZER;

@end
