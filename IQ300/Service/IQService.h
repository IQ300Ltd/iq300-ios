//
//  IQService.h
//  IQ300
//
//  Created by Tayphoon on 13.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "TCService+Subclass.h"
#import "IQSession.h"

@interface IQService : TCService

@property (nonatomic, strong) IQSession * session;

- (void)loginWithEmail:(NSString*)email password:(NSString*)password handler:(RequestCompletionHandler)handler;

@end
