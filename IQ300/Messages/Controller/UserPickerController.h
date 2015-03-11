//
//  UserPickerController.h
//  IQ300
//
//  Created by Tayphoon on 10.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "UsersPickerModel.h"

@class UserPickerController;
@class IQUser;

@protocol UserPickerControllerDelegate <NSObject>

@optional
- (void)userPickerController:(UserPickerController*)picker didPickUser:(IQUser*)user;

@end

@interface UserPickerController : IQTableBaseController

@property (nonatomic, strong) UsersPickerModel * model;
@property (nonatomic, strong) NSString * filter;
@property (nonatomic, weak) id<UserPickerControllerDelegate> delegate;

@end
