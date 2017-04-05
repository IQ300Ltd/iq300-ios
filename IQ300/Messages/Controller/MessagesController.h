//
//  MessagesController.h
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "MessagesModel.h"
#import "MessagesView.h"

@interface MessagesController : IQTableBaseController {
 @protected
    MessagesView *_messagesView;
}

@property (nonatomic, strong) MessagesModel * model;

- (void)updateGlobalCounter;

@end
