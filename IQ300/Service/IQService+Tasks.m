//
//  IQService+Tasks.m
//  IQ300
//
//  Created by Tayphoon on 24.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQService+Tasks.h"

@implementation IQService (Tasks)

- (void)tasksUpdatedAfter:(NSDate*)date
                   folder:(NSString*)folder
                   status:(NSString*)status
              communityId:(NSNumber*)communityId
                     page:(NSNumber*)page
                      per:(NSNumber*)per
                   search:(NSString*)search
                     sort:(NSString*)sort
                  handler:(ObjectLoaderCompletionHandler)handler {
    
    NSDictionary * parameters = IQParametersExcludeEmpty(@{
                                                           @"updated_at_after" : NSObjectNullForNil(date),
                                                           @"folder"           : NSStringNullForNil(folder),
                                                           @"by_status"        : NSStringNullForNil(status),
                                                           @"by_community"     : NSObjectNullForNil(communityId),
                                                           @"page"             : NSObjectNullForNil(page),
                                                           @"per"              : NSObjectNullForNil(per),
                                                           @"sort"             : NSStringNullForNil(sort),
                                                           @"search"           : NSStringNullForNil(search)
                                                           });
    
    [self getObjectsAtPath:@"/api/v1/tasks"
                parameters:parameters
                   handler:handler];
}

- (void)tasksBeforeId:(NSNumber*)taskId
               folder:(NSString*)folder
               status:(NSString*)status
          communityId:(NSNumber*)communityId
                 page:(NSNumber*)page
                  per:(NSNumber*)per
               search:(NSString*)search
                 sort:(NSString*)sort
              handler:(ObjectLoaderCompletionHandler)handler {
    
    NSDictionary * parameters = IQParametersExcludeEmpty(@{
                                                           @"id_less_than" : NSObjectNullForNil(taskId),
                                                           @"folder"       : NSStringNullForNil(folder),
                                                           @"by_status"    : NSStringNullForNil(status),
                                                           @"by_community" : NSObjectNullForNil(communityId),
                                                           @"page"         : NSObjectNullForNil(page),
                                                           @"per"          : NSObjectNullForNil(per),
                                                           @"sort"         : NSStringNullForNil(sort),
                                                           @"search"       : NSStringNullForNil(search)
                                                           });
    
    
    [self getObjectsAtPath:@"/api/v1/tasks"
                parameters:parameters
                   handler:handler];
}

- (void)filterCountersForFolder:(NSString*)folder
                         status:(NSString*)status
                    communityId:(NSNumber*)communityId
                        handler:(ObjectLoaderCompletionHandler)handler {
    NSDictionary * parameters = IQParametersExcludeEmpty(@{
                                                           @"folder"       : NSStringNullForNil(folder),
                                                           @"by_status"    : NSStringNullForNil(status),
                                                           @"by_community" : NSObjectNullForNil(communityId),
                                                           });

    [self getObjectsAtPath:@"/api/v1/tasks/filter_counters"
                parameters:parameters
                   handler:handler];
}

- (void)tasksMenuCountersWithHandler:(ObjectLoaderCompletionHandler)handler {
    [self getObjectsAtPath:@"/api/v1/tasks/menu_counters"
                parameters:nil
                   handler:handler];
}

- (void)taskChangesCounterById:(NSNumber*)taskId handler:(ObjectLoaderCompletionHandler)handler {
    NSParameterAssert(taskId);
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/tasks/%@/changes", taskId]
                parameters:nil
                   handler:handler];
}

- (void)taskWithId:(NSNumber*)taskId handler:(ObjectLoaderCompletionHandler)handler {
    NSParameterAssert(taskId);
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/tasks/%@", taskId]
                parameters:nil
                   handler:handler];
}

- (void)addAttachmentWithId:(NSNumber*)attachmentId taskId:(NSNumber*)taskId handler:(RequestCompletionHandler)handler {
    NSParameterAssert(taskId);
    [self postObject:nil
                path:[NSString stringWithFormat:@"/api/v1/tasks/%@/attachments", taskId]
          parameters:@{ @"attachment_id" : attachmentId }
             handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                 if (handler) {
                     handler(success, responseData, error);
                 }
             }];
}

- (void)membersByTaskId:(NSNumber*)taskId handler:(ObjectLoaderCompletionHandler)handler {
    NSParameterAssert(taskId);
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/tasks/%@/accessor_users", taskId]
                parameters:nil
                   handler:handler];
}

- (void)addMemberWithUserId:(NSNumber*)userId inTaskWithId:(NSNumber*)taskId handler:(ObjectLoaderCompletionHandler)handler {
    NSParameterAssert(taskId);
    [self postObject:nil
                path:[NSString stringWithFormat:@"/api/v1/tasks/%@/accessor_users", taskId]
          parameters:@{ @"user_id" : userId }
             handler:handler];
}

@end
