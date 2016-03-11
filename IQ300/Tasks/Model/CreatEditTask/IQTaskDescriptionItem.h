//
//  IQTaskDescriptionItem.h
//  IQ300
//
//  Created by Vladislav Grigoriev on 10/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQTextItem.h"
#import "IQTaskItemProtocol.h"

@interface IQTaskDescriptionItem : IQTextItem <IQTaskItemProtocol>

- (instancetype)initWithTask:(id)task;

@end
