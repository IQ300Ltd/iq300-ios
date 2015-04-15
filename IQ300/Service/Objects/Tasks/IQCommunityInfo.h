//
//  IQCommunityInfo.h
//  IQ300
//
//  Created by Tayphoon on 15.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;

@interface IQCommunityInfo : NSObject

@property (nonatomic, strong) NSNumber * communityId;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSNumber * sortOrder;

+ (RKObjectMapping*)objectMapping;

@end
