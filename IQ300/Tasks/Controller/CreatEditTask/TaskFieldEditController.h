//
//  TaskFieldEditController.h
//  IQ300
//
//  Created by Tayphoon on 16.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IQTaskDataHolder;
@protocol TaskFieldEditController;

@protocol TaskFieldEditControllerDelegate <NSObject>

@optional

- (void)taskFieldEditController:(id<TaskFieldEditController>)controller didChangeFieldValue:(id)value;

@end

@protocol TaskFieldEditController <NSObject>

@property (nonatomic, strong) NSIndexPath * fieldIndexPath;
@property (nonatomic, strong) id fieldValue;
@property (nonatomic, strong) IQTaskDataHolder * task;
@property (nonatomic, weak)   id delegate;

@end
