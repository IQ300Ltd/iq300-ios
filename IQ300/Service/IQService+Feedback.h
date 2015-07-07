//
//  IQService+Feedback.h
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQService.h"

@class IQFeedback;

@interface IQService (Feedback)

- (void)feedbacksUpdatedAfter:(NSDate*)date
                     page:(NSNumber*)page
                      per:(NSNumber*)per
                   search:(NSString*)search
                  handler:(ObjectRequestCompletionHandler)handler;

- (void)feedbacksBeforeId:(NSNumber*)feedbackId
                     page:(NSNumber*)page
                      per:(NSNumber*)per
                   search:(NSString*)search
                  handler:(ObjectRequestCompletionHandler)handler;

- (void)feedbackWithId:(NSNumber*)feedbackId handler:(ObjectRequestCompletionHandler)handler;

- (void)feedbackCategoriesWithHandler:(ObjectRequestCompletionHandler)handler;

- (void)feedbackTypesWithHandler:(ObjectRequestCompletionHandler)handler;

- (void)createFeedback:(IQFeedback*)feedback handler:(ObjectRequestCompletionHandler)handler;

@end
