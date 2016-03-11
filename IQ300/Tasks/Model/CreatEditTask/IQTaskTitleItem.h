//
//  IQTaskTitleItem.h
//  IQ300
//
//  Created by Vladislav Grigoriev on 09/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQTextItem.h"
#import "IQTaskItemProtocol.h"

@interface IQTaskTitleItem : IQTextItem <IQTaskItemProtocol>

- (instancetype)initWithTask:(id)task;

- (void)updateWithTask:(id)task value:(id)value;

@end
