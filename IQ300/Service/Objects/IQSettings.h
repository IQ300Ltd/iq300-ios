//
//  IQSettings.h
//  IQ300
//
//  Created by Viktor Shabanov on 03.04.17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;

@interface IQSettings : NSObject

@property (nonatomic, strong) NSNumber *pushEnabled;

+ (RKObjectMapping *)objectMapping;

@end
