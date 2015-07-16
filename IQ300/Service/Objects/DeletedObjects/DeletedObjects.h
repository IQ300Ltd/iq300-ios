//
//  DeletedObjects.h
//  IQ300
//
//  Created by Tayphoon on 24.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;

@interface DeletedObjects : NSObject

@property (nonatomic, strong) NSArray * objectIds;
@property (nonatomic, strong) NSDate * serverDate;

+ (RKObjectMapping*)objectMapping;

@end
