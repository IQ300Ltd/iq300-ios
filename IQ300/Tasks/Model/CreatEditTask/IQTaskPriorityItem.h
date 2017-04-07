//
//  IQTaskPriorityItem.h
//  IQ300
//
//  Created by Viktor Shabanov on 4/7/17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import "IQTextItem.h"
#import "IQTaskItemProtocol.h"

@interface IQTaskPriorityItem : IQTextItem <IQTaskItemProtocol>

- (instancetype)initWithTask:(id)task;

@end
