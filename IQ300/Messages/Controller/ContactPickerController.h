//
//  ContactPickerController.h
//  IQ300
//
//  Created by Tayphoon on 09.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQSelectionController.h"
#import "ContactsModel.h"

@class ContactPickerController;

@protocol ContactPickerControllerDelegate <IQSelectionControllerDelegate>

@optional
- (void)contactPickerController:(ContactPickerController*)picker didPickContacts:(NSArray*)contacts;

@end

@interface ContactPickerController : IQSelectionController

@property (nonatomic, strong) ContactsModel * model;

- (void)setDoneButtonTitle:(NSString*)title;

@end
