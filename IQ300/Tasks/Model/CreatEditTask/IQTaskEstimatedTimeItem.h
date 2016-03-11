//
//  IQTaskEstimatedTimeItem.h
//  IQ300
//
//  Created by Vladislav Grigoriev on 10/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQItem.h"
#import "IQTaskItemProtocol.h"
@interface IQTaskEstimatedTimeItem : IQItem <IQTaskItemProtocol>

@property (nonatomic, strong) NSString *hours;
@property (nonatomic, strong) NSString *minutes;
@property (nonatomic, assign) BOOL editable;

- (instancetype)initWithTask:(id)task;

@end
