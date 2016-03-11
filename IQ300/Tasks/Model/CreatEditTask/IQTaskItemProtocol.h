//
//  IQTaskItemProtocol.h
//  IQ300
//
//  Created by Vladislav Grigoriev on 10/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IQTaskItemProtocol <NSObject>

- (BOOL)editable;

- (instancetype)initWithTask:(id)task;

- (void)updateWithTask:(id)task value:(id)value;

- (void)setTask:(id)task;


@end
