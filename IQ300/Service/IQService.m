//
//  IQService.m
//  IQ300
//
//  Created by Tayphoon on 13.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQService.h"

#define NSStringEptyForNil(value) [value length] ? value : @""

@implementation IQService

- (id)initWithURL:(NSString *)url andSession:(id)session {
    self = [super initWithURL:url andSession:session];
    if (self) {
        
    }
    return self;
}

#pragma mark - Public methods

- (NSString*)storeFileName {
    return @"IQ300";
}

- (void)loginWithEmail:(NSString*)email password:(NSString*)password handler:(RequestCompletionHandler)handler {
//    NSDictionary * parameters = @{ @"email"    : NSStringEptyForNil(email) ,
//                                   @"password" : NSStringEptyForNil(password) };
//    [self postObject:nil
//                path:@"/api/v1/sessions"
//          parameters:parameters
//             handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                 if(handler) {
//                     handler(success, responseData, error);
                     self.session = [IQSession sessionWithUserName:email andPassword:password token:@""];
                     handler(YES, nil, nil);
                 }
//             }];
}

#pragma mark - Private methods

- (void)processAuthorizationForOperation:(RKObjectRequestOperation *)operation {
    if(self.session) {
        NSString * token = [NSString stringWithFormat:@"%@ %@", self.session.tokenType, self.session.token];
        [((NSMutableURLRequest*)operation.HTTPRequestOperation.request) addValue:token forHTTPHeaderField:@"Authorization"];
    }
}

@end
