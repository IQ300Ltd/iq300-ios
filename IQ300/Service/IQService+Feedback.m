//
//  IQService+Feedback.m
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQService+Feedback.h"

@implementation IQService (Feedback)

- (void)feedbacksUpdatedAfter:(NSDate *)date
                         page:(NSNumber *)page
                          per:(NSNumber *)per
                       search:(NSString *)search
                      handler:(ObjectRequestCompletionHandler)handler {
    NSDictionary * parameters = IQParametersExcludeEmpty(@{
                                                           @"updated_at_after" : NSObjectNullForNil(date),
                                                           @"page"             : NSObjectNullForNil(page),
                                                           @"per"              : NSObjectNullForNil(per),
                                                           @"search"           : NSStringNullForNil(search)
                                                           });
    
    [self getObjectsAtPath:@"error_reports"
                parameters:parameters
                   handler:handler];
}

- (void)feedbacksBeforeId:(NSNumber *)feedbackId
                     page:(NSNumber *)page
                      per:(NSNumber *)per
                   search:(NSString *)search
                  handler:(ObjectRequestCompletionHandler)handler {
    NSDictionary * parameters = IQParametersExcludeEmpty(@{
                                                           @"id_less_than" : NSObjectNullForNil(feedbackId),
                                                           @"page"         : NSObjectNullForNil(page),
                                                           @"per"          : NSObjectNullForNil(per),
                                                           @"search"       : NSStringNullForNil(search)
                                                           });
    
    [self getObjectsAtPath:@"error_reports"
                parameters:parameters
                   handler:handler];
}

- (void)feedbackWithId:(NSNumber*)feedbackId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(feedbackId);
    [self getObjectsAtPath:[NSString stringWithFormat:@"error_reports/%@", feedbackId]
                parameters:nil
                   handler:handler];
}

- (void)feedbackCategoriesWithHandler:(ObjectRequestCompletionHandler)handler {
    [self getObjectsAtPath:@"error_reports/categories"
                parameters:nil
                   handler:handler];
}

- (void)feedbackTypesWithHandler:(ObjectRequestCompletionHandler)handler {
    [self getObjectsAtPath:@"error_reports/types"
                parameters:nil
                   handler:handler];
}

- (void)createFeedback:(IQFeedback*)feedback handler:(ObjectRequestCompletionHandler)handler {
    [self postObject:feedback
                path:@"error_reports"
          parameters:nil
             handler:handler];
}

@end
