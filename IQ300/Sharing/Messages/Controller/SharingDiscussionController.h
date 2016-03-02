//
//  DiscussionController.h
//  IQ300
//
//  Created by Tayphoon on 04.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "DiscussionModel.h"
#import "SharingViewControllerProtocol.h"

@class IQConversation;
@class IQManagedAttachment;
@class SharingViewController;

@interface SharingDiscussionController : IQTableBaseController <SharingViewControllerProtocol>

@property (nonatomic, strong) DiscussionModel * model;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (instancetype)initWithAttachment:(SharingAttachment *)attachment NS_DESIGNATED_INITIALIZER;

@property (nonatomic, weak) SharingViewController *sharingController;

@end
