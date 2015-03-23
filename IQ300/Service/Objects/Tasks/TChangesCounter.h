//
//  TChangesCounter.h
//  IQ300
//
//  Created by Tayphoon on 23.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;

@interface TChangesCounter : NSObject

@property (nonatomic, strong) NSNumber * details;
@property (nonatomic, strong) NSNumber * comments;
@property (nonatomic, strong) NSNumber * users;
@property (nonatomic, strong) NSNumber * documents;

+ (RKObjectMapping*)objectMapping;

@end
