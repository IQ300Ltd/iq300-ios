//
//  IQSession.h
//  IQ300
//
//  Created by Tayphoon on 18.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IQSession : NSObject

@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * password;
@property (nonatomic, strong) NSString * tokenType;
@property (nonatomic, strong) NSString * token;
@property (nonatomic, strong) NSString * userName;

+ (IQSession*)defaultSession;
+ (void)setDefaultSession:(IQSession*)defaultSession;

+ (IQSession*)sessionWithEmail:(NSString *)email andPassword:(NSString *)password token:(NSString*)token;
- (instancetype)initWithEmail:(NSString *)email andPassword:(NSString *)password token:(NSString*)token;

@end
