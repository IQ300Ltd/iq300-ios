//
//  TodoItem.h
//  IQ300
//
//  Created by Tayphoon on 31.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TodoItem <NSObject>

@property (nonatomic, strong) NSNumber * itemId;
@property (nonatomic, strong) NSNumber * taskId;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSNumber * completed;
@property (nonatomic, strong) NSNumber * position;
@property (nonatomic, strong) NSDate   * createdDate;
@property (nonatomic, strong) NSDate   * updatedDate;

@end
