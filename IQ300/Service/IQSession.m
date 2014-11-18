//
//  IQSession.m
//  IQ300
//
//  Created by Tayphoon on 18.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQSession.h"

#define USER_NAME_PREF_KEY @"user_name"
#define USER_PASSWORD_PREF_KEY @"user_password"
#define USER_TOKEN_PREF_KEY @"user_token"

static IQSession * _defaultSession = nil;

@implementation IQSession

+ (IQSession*)defaultSession {
    return _defaultSession;
}

+ (void)setDefaultSession:(IQSession*)defaultSession {
    if(![_defaultSession isEqual:defaultSession]) {
        _defaultSession = defaultSession;
        // save session into user defaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if (_defaultSession) {
            [defaults setValue:_defaultSession.userName forKey:USER_NAME_PREF_KEY];
            [defaults setValue:_defaultSession.password forKey:USER_PASSWORD_PREF_KEY];
            [defaults setValue:_defaultSession.token forKey:USER_TOKEN_PREF_KEY];
        }
        else { // clear old session
            [defaults removeObjectForKey:USER_NAME_PREF_KEY];
            [defaults removeObjectForKey:USER_PASSWORD_PREF_KEY];
            [defaults removeObjectForKey:USER_TOKEN_PREF_KEY];
        }
        
        [defaults synchronize];
    }
}

+ (IQSession*)sessionWithUserName:(NSString *)userName andPassword:(NSString *)password token:(NSString*)token {
    return [[self alloc] initWithUserName:userName andPassword:password token:token];
}

- (instancetype)initWithUserName:(NSString *)userName andPassword:(NSString *)password token:(NSString*)token {
    self = [super init];
    if(self) {
        _userName = userName;
        _password = password;
        _token = token;
        _tokenType = @"Bearer";
    }
    return self;
}

@end
