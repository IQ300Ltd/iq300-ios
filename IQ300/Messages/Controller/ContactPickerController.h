//
//  ContactPickerController.h
//  IQ300
//
//  Created by Tayphoon on 09.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "ContactsModel.h"

@class ContactPickerController;
@class IQUser;

@protocol ContactPickerControllerDelegate <NSObject>

@optional
- (void)contactPickerController:(ContactPickerController*)picker didPickUser:(IQUser*)user;

@end

@interface ContactPickerController : IQTableBaseController

@property (nonatomic, strong) ContactsModel * model;
@property (nonatomic, weak) id<ContactPickerControllerDelegate> delegate;

@end
