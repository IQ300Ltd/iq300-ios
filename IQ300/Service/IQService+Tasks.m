//
//  IQService+Tasks.m
//  IQ300
//
//  Created by Tayphoon on 24.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQService+Tasks.h"
#import "IQTaskDataHolder.h"

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
    
    [self getObjectsAtPath:@"tasks"
                parameters:parameters
                   handler:handler];
}

- (void)tasksUpdatedAfter:(NSDate*)date
            excludeFolder:(NSString*)folder
                     page:(NSNumber*)page
                      per:(NSNumber*)per
                   search:(NSString*)search
                     sort:(NSString*)sort
                  handler:(ObjectRequestCompletionHandler)handler {
    NSDictionary * parameters = IQParametersExcludeEmpty(@{
                                                           @"updated_at_after" : NSObjectNullForNil(date),
                                                           @"exclude_folder"   : NSStringNullForNil(folder),
                                                           @"page"             : NSObjectNullForNil(page),
                                                           @"per"              : NSObjectNullForNil(per),
                                                           @"sort"             : NSStringNullForNil(sort),
                                                           @"search"           : NSStringNullForNil(search)
                                                           });
    
    [self getObjectsAtPath:@"tasks"
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
    
    
    [self getObjectsAtPath:@"tasks"
                parameters:parameters
                   handler:handler];
}

- (void)tasksWithParentId:(NSNumber *)parentId handler:(ObjectRequestCompletionHandler)handler {
    NSDictionary *parameters = IQParametersExcludeEmpty(@{
                                                          @"children_of" : NSObjectNullForNil(parentId)
                                                          });
    [self getObjectsAtPath:@"tasks"
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

    [self getObjectsAtPath:@"tasks/filter_counters"
                parameters:parameters
                   handler:handler];
}

- (void)tasksMenuCountersWithHandler:(ObjectRequestCompletionHandler)handler {
    [self getObjectsAtPath:@"tasks/menu_counters"
                parameters:nil
                   handler:handler];
}

- (void)taskChangesCounterById:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(taskId);
    [self getObjectsAtPath:[NSString stringWithFormat:@"tasks/%@/changes", taskId]
                parameters:nil
                   handler:handler];
}

- (void)taskWithId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(taskId);
    [self getObjectsAtPath:[NSString stringWithFormat:@"tasks/%@/", taskId]
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
               path:[NSString stringWithFormat:@"tasks/%@/change_status", taskId]
         parameters:parameters
            handler:handler];
}

- (void)completeTodoItemWithId:(NSNumber*)itemId taskId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(itemId);
    NSParameterAssert(taskId);

    [self putObject:nil
               path:[NSString stringWithFormat:@"tasks/%@/todo_items/%@/complete", taskId, itemId]
         parameters:nil
            handler:handler];
}

- (void)rollbackTaskWithId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(taskId);
    [self putObject:nil
               path:[NSString stringWithFormat:@"tasks/%@/rollback", taskId]
         parameters:nil
            handler:handler];
}

- (void)rollbackTodoItemWithId:(NSNumber*)itemId taskId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(itemId);
    NSParameterAssert(taskId);

    [self putObject:nil
               path:[NSString stringWithFormat:@"tasks/%@/todo_items/%@/rollback", taskId, itemId]
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
    
    [self getObjectsAtPath:[NSString stringWithFormat:@"tasks/%@/todo_items", taskId]
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
                path:[NSString stringWithFormat:@"tasks/%@/todo_items/apply_changes", taskId]
          parameters:nil
          fetchBlock:fetchBlock
             handler:handler];
}

- (void)markCategoryAsReaded:(NSString*)category taskId:(NSNumber*)taskId handler:(RequestCompletionHandler)handler {
    NSParameterAssert(taskId);
    NSParameterAssert(category);

    [self putObject:nil
               path:[NSString stringWithFormat:@"tasks/%@/changes/read", taskId]
         parameters:@{ @"tabs" : @[category] }
            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                if (handler) {
                    handler(success, responseData, error);
                }
            }];
}

- (void)attachmentsByTaskId:(NSNumber *)taskId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(taskId);
    
    [self getObjectsAtPath:[NSString stringWithFormat:@"tasks/%@/attachments", taskId]
                parameters:nil
                   handler:handler];
}

- (void)addAttachmentWithId:(NSNumber*)attachmentId taskId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(taskId);
    [self postObject:nil
                path:[NSString stringWithFormat:@"tasks/%@/attachments", taskId]
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
    [self getObjectsAtPath:[NSString stringWithFormat:@"tasks/%@/accessor_users", taskId]
                parameters:nil
                fetchBlock:fetchBlock
                   handler:handler];
}

- (void)addMemberWithUserId:(NSNumber*)userId inTaskWithId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(taskId);
    [self postObject:nil
                path:[NSString stringWithFormat:@"tasks/%@/accessor_users", taskId]
          parameters:@{ @"user_id" : userId }
             handler:handler];
}

- (void)removeMemberWithId:(NSNumber*)memberId fromTaskWithId:(NSNumber*)taskId handler:(RequestCompletionHandler)handler {
    NSParameterAssert(memberId);
    NSParameterAssert(taskId);

    [self deleteObject:nil
                  path:[NSString stringWithFormat:@"tasks/%@/accessor_users/%@", taskId, memberId]
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
               path:[NSString stringWithFormat:@"tasks/%@/accessor_users/leave", taskId]
         parameters:nil
            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                if (handler) {
                    handler(success, responseData, error);
                }
            }];
}

- (void)policiesForTaskWithId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(taskId);
    [self getObjectsAtPath:[NSString stringWithFormat:@"tasks/%@/abilities", taskId]
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

    [self getObjectsAtPath:[NSString stringWithFormat:@"tasks/%@/activities", taskId]
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
    
    [self getObjectsAtPath:[NSString stringWithFormat:@"tasks/%@/activities", taskId]
                parameters:parameters
                   handler:handler];
  
}

- (void)taskCommunitiesWithHandler:(ObjectRequestCompletionHandler)handler {
    [self getObjectsAtPath:@"tasks/communities"
                parameters:nil
                   handler:handler];
}

- (void)mostUsedCommunityWithHandler:(ObjectRequestCompletionHandler)handler {
    [self getObjectsAtPath:@"tasks/communities/most_used"
                parameters:nil
                   handler:handler];
}

- (void)taskExecutorsForCommunityId:(NSNumber*)communityId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(communityId);

    [self getObjectsAtPath:[NSString stringWithFormat:@"communities/%@/executors", communityId]
                parameters:nil
                   handler:handler];
}

- (void)createTask:(IQTaskDataHolder*)task handler:(ObjectRequestCompletionHandler)handler {
    [self postObject:task
                path:@"tasks"
          parameters:nil
             handler:handler];
}

- (void)saveTask:(IQTaskDataHolder*)task handler:(ObjectRequestCompletionHandler)handler {
    [self putObject:task
               path:[NSString stringWithFormat:@"tasks/%@/", task.taskId]
         parameters:nil
            handler:handler];
}

- (void)taskIdsDeletedAfter:(NSDate*)deletedAfter
                    handler:(ObjectRequestCompletionHandler)handler {
    [self getObjectsAtPath:[NSString stringWithFormat:@"tasks/deleted_ids"]
                parameters:IQParametersExcludeEmpty(@{ @"deleted_at_after" : NSObjectNullForNil(deletedAfter) })
                   handler:handler];
}

- (void)approveTaskWithId:(NSNumber *)taskId handler:(ObjectRequestCompletionHandler)handler {
    [self putObject:nil
               path:[NSString stringWithFormat:@"tasks/%@/reconciliation_list/approve", taskId]
         parameters:nil
            handler:handler];
}

- (void)disapproveTaskWithId:(NSNumber *)taskId handler:(ObjectRequestCompletionHandler)handler {
    [self putObject:nil
               path:[NSString stringWithFormat:@"tasks/%@/reconciliation_list/disapprove", taskId]
         parameters:nil
            handler:handler];
}

- (void)complexityKindsWithHadnler:(ObjectRequestCompletionHandler)handler {
    [self getObjectsAtPath:@"tasks/complexity_kinds" parameters:nil handler:handler];
}

@end
