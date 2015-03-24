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
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/tasks/%@/", taskId]
                parameters:nil
                   handler:handler];
}

- (void)changeStatus:(NSString*)status forTaskWithId:(NSNumber*)taskId reason:(NSString*)reason handler:(ObjectLoaderCompletionHandler)handler {
    NSParameterAssert(taskId);
    NSDictionary * parameters = IQParametersExcludeEmpty(@{
                                                           @"do"     : NSStringNullForNil(status),
                                                           @"reason" : NSStringNullForNil(reason)
                                                           });
    
    [self putObject:nil
               path:[NSString stringWithFormat:@"/api/v1/tasks/%@/change_status", taskId]
         parameters:parameters
            handler:handler];
}

- (void)completeTodoItemWithId:(NSNumber*)itemId taskId:(NSNumber*)taskId handler:(ObjectLoaderCompletionHandler)handler {
    NSParameterAssert(itemId);
    NSParameterAssert(taskId);

    [self putObject:nil
               path:[NSString stringWithFormat:@"/api/v1/tasks/%@/todo_items/%@/complete", taskId, itemId]
         parameters:nil
            handler:handler];
}

- (void)rollbackTodoItemWithId:(NSNumber*)itemId taskId:(NSNumber*)taskId handler:(ObjectLoaderCompletionHandler)handler {
    NSParameterAssert(itemId);
    NSParameterAssert(taskId);

    [self putObject:nil
               path:[NSString stringWithFormat:@"/api/v1/tasks/%@/todo_items/%@/rollback", taskId, itemId]
         parameters:nil
            handler:handler];
}

- (void)markCategoryAsReaded:(NSString*)category taskId:(NSNumber*)taskId handler:(RequestCompletionHandler)handler {
    NSParameterAssert(taskId);
    NSParameterAssert(category);

    [self putObject:nil
               path:[NSString stringWithFormat:@"/api/v1/tasks/%@/changes/read", taskId]
         parameters:@{ @"tabs" : @[category] }
            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                if (handler) {
                    handler(success, responseData, error);
                }
            }];
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
    NSFetchRequest *(^fetchBlock)(NSURL *URL) = ^(NSURL *URL) {
        NSFetchRequest * fRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQTaskMember"];
        [fRequest setPredicate:[NSPredicate predicateWithFormat:@"taskId == %@", taskId]];
        
        return fRequest;
    };

    NSParameterAssert(taskId);
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/tasks/%@/accessor_users", taskId]
                parameters:nil
                fetchBlock:fetchBlock
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
