//
//  IQTask.h
//  IQ300
//
//  Created by Tayphoon on 20.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IQTask : NSObject

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSDate   * dueDate;
@property (nonatomic, strong) NSString * fromUser;
@property (nonatomic, strong) NSString * toUser;
@property (nonatomic, strong) NSString * taskID;
@property (nonatomic, strong) NSString * communityName;
@property (nonatomic, strong) NSNumber * unreadMessagesCount;
@property (nonatomic, strong) NSString * status;

+ (IQTask*)randomTask;

@end
