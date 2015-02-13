//
//  IQGroupCounter.h
//  IQ300
//
//  Created by Tayphoon on 13.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;

@interface IQGroupCounter : NSObject

@property (nonatomic, strong) NSString * sID;
@property (nonatomic, strong) NSNumber * unreadCount;

+ (RKObjectMapping*)objectMapping;

@end
