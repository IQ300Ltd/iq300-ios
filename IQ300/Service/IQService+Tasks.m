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
                  handler:(ObjectRequestCompletionHandler)handler {
    
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
              handler:(ObjectRequestCompletionHandler)handler {
    
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
                        handler:(ObjectRequestCompletionHandler)handler {
    NSDictionary * parameters = IQParametersExcludeEmpty(@{
                                                           @"folder"       : NSStringNullForNil(folder),
                                                           @"by_status"    : NSStringNullForNil(status),
                                                           @"by_community" : NSObjectNullForNil(communityId),
                                                           });

    [self getObjectsAtPath:@"/api/v1/tasks/filter_counters"
                parameters:parameters
                   handler:handler];
}

- (void)tasksMenuCountersWithHandler:(ObjectRequestCompletionHandler)handler {
    [self getObjectsAtPath:@"/api/v1/tasks/menu_counters"
                parameters:nil
                   handler:handler];
}

- (void)taskChangesCounterById:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(taskId);
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/tasks/%@/changes", taskId]
                parameters:nil
                   handler:handler];
}

- (void)taskWithId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(taskId);
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/tasks/%@/", taskId]
                parameters:nil
                   handler:handler];
}

- (void)changeStatus:(NSString*)status forTaskWithId:(NSNumber*)taskId reason:(NSString*)reason handler:(ObjectRequestCompletionHandler)handler {
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

- (void)completeTodoItemWithId:(NSNumber*)itemId taskId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(itemId);
    NSParameterAssert(taskId);

    [self putObject:nil
               path:[NSString stringWithFormat:@"/api/v1/tasks/%@/todo_items/%@/complete", taskId, itemId]
         parameters:nil
            handler:handler];
}

- (void)rollbackTaskWithId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(taskId);
    [self putObject:nil
               path:[NSString stringWithFormat:@"/api/v1/tasks/%@/rollback", taskId]
         parameters:nil
            handler:handler];
}

- (void)rollbackTodoItemWithId:(NSNumber*)itemId taskId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(itemId);
    NSParameterAssert(taskId);

    [self putObject:nil
               path:[NSString stringWithFormat:@"/api/v1/tasks/%@/todo_items/%@/rollback", taskId, itemId]
         parameters:nil
            handler:handler];
}

- (void)todoListByTaskId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(taskId);
    
    NSFetchRequest *(^fetchBlock)(NSURL *URL) = ^(NSURL *URL) {
        NSFetchRequest * fRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQManagedTodoItem"];
        [fRequest setPredicate:[NSPredicate predicateWithFormat:@"taskId == %@", taskId]];
        
        return fRequest;
    };
    
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/tasks/%@/todo_items", taskId]
                parameters:nil
                fetchBlock:fetchBlock
                   handler:handler];
}

- (void)saveTodoList:(NSArray*)tododList taskId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(taskId);
    
    NSFetchRequest *(^fetchBlock)(NSURL *URL) = ^(NSURL *URL) {
        NSFetchRequest * fRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQManagedTodoItem"];
        [fRequest setPredicate:[NSPredicate predicateWithFormat:@"taskId == %@", taskId]];
        
        return fRequest;
    };
    
    TCRequestItemsHolder * holder = [[TCRequestItemsHolder alloc] init];
    holder.items = tododList;
    
    [self postObject:holder
                path:[NSString stringWithFormat:@"/api/v1/tasks/%@/todo_items/apply_changes", taskId]
          parameters:nil
          fetchBlock:fetchBlock
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

- (void)attachmentsByTaskId:(NSNumber *)taskId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(taskId);
    
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/tasks/%@/attachments", taskId]
                parameters:nil
                   handler:handler];
}

- (void)addAttachmentWithId:(NSNumber*)attachmentId taskId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(taskId);
    [self postObject:nil
                path:[NSString stringWithFormat:@"/api/v1/tasks/%@/attachments", taskId]
          parameters:@{ @"attachment_id" : attachmentId }
             handler:handler];
}

- (void)membersByTaskId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler {
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

- (void)addMemberWithUserId:(NSNumber*)userId inTaskWithId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(taskId);
    [self postObject:nil
                path:[NSString stringWithFormat:@"/api/v1/tasks/%@/accessor_users", taskId]
          parameters:@{ @"user_id" : userId }
             handler:handler];
}

- (void)removeMemberWithId:(NSNumber*)memberId fromTaskWithId:(NSNumber*)taskId handler:(RequestCompletionHandler)handler {
    NSParameterAssert(memberId);
    NSParameterAssert(taskId);

    [self deleteObject:nil
                  path:[NSString stringWithFormat:@"/api/v1/tasks/%@/accessor_users/%@", taskId, memberId]
            parameters:nil
               handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                   if (handler) {
                       handler(success, responseData , error);
                   }
               }];
}

- (void)leaveTaskWithId:(NSNumber*)taskId handler:(RequestCompletionHandler)handler {
    NSParameterAssert(taskId);
  
    [self putObject:nil
               path:[NSString stringWithFormat:@"/api/v1/tasks/%@/accessor_users/leave", taskId]
         parameters:nil
            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                if (handler) {
                    handler(success, responseData, error);
                }
            }];
}

- (void)policiesForTaskWithId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(taskId);
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/tasks/%@/abilities", taskId]
                parameters:nil
                   handler:handler];
}

- (void)activitiesForTaskWithId:(NSNumber*)taskId
                   updatedAfter:(NSDate*)date
                           page:(NSNumber*)page
                            per:(NSNumber*)per
                           sort:(IQSortDirection)sort
                        handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(taskId);
    
    NSMutableDictionary * parameters = IQParametersExcludeEmpty(@{
                                                                  @"updated_at_after" : NSObjectNullForNil(date),
                                                                  @"page"             : NSObjectNullForNil(page),
                                                                  @"per"              : NSObjectNullForNil(per),
                                                                  }).mutableCopy;
    
    if(sort != IQSortDirectionNo) {
        parameters[@"sort"] = IQSortDirectionToString(sort);
    }

    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/tasks/%@/activities", taskId]
                parameters:parameters
                   handler:handler];
}

- (void)activitiesForTaskWithId:(NSNumber*)taskId
                       beforeId:(NSNumber*)beforeId
                           page:(NSNumber*)page
                            per:(NSNumber*)per
                           sort:(IQSortDirection)sort
                        handler:(ObjectRequestCompletionHandler)handler {
    NSMutableDictionary * parameters = IQParametersExcludeEmpty(@{
                                                                  @"id_less_than" : NSObjectNullForNil(beforeId),
                                                                  @"page"         : NSObjectNullForNil(page),
                                                                  @"per"          : NSObjectNullForNil(per),
                                                                  }).mutableCopy;
    
    if(sort != IQSortDirectionNo) {
        parameters[@"sort"] = IQSortDirectionToString(sort);
    }
    
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/tasks/%@/activities", taskId]
                parameters:parameters
                   handler:handler];
  
}

@end
