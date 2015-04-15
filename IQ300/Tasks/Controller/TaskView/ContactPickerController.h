//
//  ContactPickerController.h
//  IQ300
//
//  Created by Tayphoon on 20.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "CreateConversationController.h"

@class ContactPickerController;
@class IQUser;

@protocol ContactPickerControllerDelegate <NSObject>

@optional
- (void)contactPickerController:(ContactPickerController*)picker didPickUser:(IQUser*)user;

@end

@interface ContactPickerController : CreateConversationController

@property (nonatomic, weak) id<ContactPickerControllerDelegate> delegate;

@end
