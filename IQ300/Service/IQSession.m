//
//  IQSession.m
//  IQ300
//
//  Created by Tayphoon on 18.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQSession.h"

#define USER_EMAIL_PREF_KEY @"user_email"
#define USER_PASSWORD_PREF_KEY @"user_password"
#define USER_ID_PREF_KEY @"user_id"
#define USER_TOKEN_PREF_KEY @"user_token"

static IQSession * _defaultSession = nil;

@implementation IQSession

+ (void)initialize {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * email = [defaults stringForKey:USER_EMAIL_PREF_KEY];
    NSString * token = [defaults stringForKey:USER_TOKEN_PREF_KEY];
    NSString * password = [defaults stringForKey:USER_PASSWORD_PREF_KEY];
    NSInteger userId = [defaults integerForKey:USER_ID_PREF_KEY];
    
    if([token length] > 0) {
        _defaultSession = [IQSession sessionWithEmail:email andPassword:password token:token];
        _defaultSession.userId = @(userId);
    }
}

+ (IQSession*)defaultSession {
    return _defaultSession;
}

+ (void)setDefaultSession:(IQSession*)defaultSession {
    if(![_defaultSession isEqual:defaultSession]) {
        _defaultSession = defaultSession;
        // save session into user defaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if (_defaultSession) {
            [defaults setValue:_defaultSession.email forKey:USER_EMAIL_PREF_KEY];
            [defaults setValue:_defaultSession.password forKey:USER_PASSWORD_PREF_KEY];
            [defaults setValue:_defaultSession.token forKey:USER_TOKEN_PREF_KEY];
            [defaults setInteger:[_defaultSession.userId integerValue] forKey:USER_ID_PREF_KEY];
        }
        else { // clear old session
            [defaults removeObjectForKey:USER_EMAIL_PREF_KEY];
            [defaults removeObjectForKey:USER_PASSWORD_PREF_KEY];
            [defaults removeObjectForKey:USER_TOKEN_PREF_KEY];
            [defaults removeObjectForKey:USER_ID_PREF_KEY];
        }
        
        [defaults synchronize];
    }
}

+ (IQSession*)sessionWithEmail:(NSString *)email andPassword:(NSString *)password token:(NSString*)token {
    return [[self alloc] initWithEmail:email andPassword:password token:token];
}

- (instancetype)initWithEmail:(NSString *)email andPassword:(NSString *)password token:(NSString*)token {
    self = [super init];
    if(self) {
        _email = email;
        _password = password;
        _token = token;
        _tokenType = @"Bearer";
    }
    return self;
}

@end
