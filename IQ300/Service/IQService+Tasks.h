//
//  IQService+Tasks.h
//  IQ300
//
//  Created by Tayphoon on 24.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQService.h"

@class IQTaskDataHolder;

@interface IQService (Tasks)

- (void)tasksUpdatedAfter:(NSDate*)date
                   folder:(NSString*)folder
                   status:(NSString*)status
              communityId:(NSNumber*)communityId
                     page:(NSNumber*)page
                      per:(NSNumber*)per
                   search:(NSString*)search
                     sort:(NSString*)sort
                  handler:(ObjectRequestCompletionHandler)handler;

- (void)tasksUpdatedAfter:(NSDate*)date
                   excludeFolder:(NSString*)folder
                     page:(NSNumber*)page
                      per:(NSNumber*)per
                   search:(NSString*)search
                     sort:(NSString*)sort
                  handler:(ObjectRequestCompletionHandler)handler;

- (void)tasksBeforeId:(NSNumber*)taskId
               folder:(NSString*)folder
               status:(NSString*)status
          communityId:(NSNumber*)communityId
                 page:(NSNumber*)page
                  per:(NSNumber*)per
               search:(NSString*)search
                 sort:(NSString*)sort
              handler:(ObjectRequestCompletionHandler)handler;

- (void)tasksWithParentId:(NSNumber *)parentId handler:(ObjectRequestCompletionHandler)handler;

- (void)filterCountersForFolder:(NSString*)folder
                         status:(NSString*)status
                    communityId:(NSNumber*)communityId
                        handler:(ObjectRequestCompletionHandler)handler;

- (void)tasksMenuCountersWithHandler:(ObjectRequestCompletionHandler)handler;

- (void)taskChangesCounterById:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler;

- (void)taskWithId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler;

- (void)changeStatus:(NSString*)status forTaskWithId:(NSNumber*)taskId reason:(NSString*)reason handler:(ObjectRequestCompletionHandler)handler;

- (void)rollbackTodoItemWithId:(NSNumber*)itemId taskId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler;

- (void)completeTodoItemWithId:(NSNumber*)itemId taskId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler;

- (void)rollbackTaskWithId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler;

- (void)todoListByTaskId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler;

- (void)saveTodoList:(NSArray*)tododList taskId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler;

- (void)markCategoryAsReaded:(NSString*)category taskId:(NSNumber*)taskId handler:(RequestCompletionHandler)handler;

- (void)attachmentsByTaskId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler;

- (void)addAttachmentWithId:(NSNumber*)attachmentId taskId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler;

- (void)membersByTaskId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler;

- (void)addMemberWithUserId:(NSNumber*)userId inTaskWithId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler;

- (void)removeMemberWithId:(NSNumber*)memberId fromTaskWithId:(NSNumber*)taskId handler:(RequestCompletionHandler)handler;

- (void)leaveTaskWithId:(NSNumber*)taskId handler:(RequestCompletionHandler)handler;

- (void)policiesForTaskWithId:(NSNumber*)taskId handler:(ObjectRequestCompletionHandler)handler;

- (void)activitiesForTaskWithId:(NSNumber*)taskId
                   updatedAfter:(NSDate*)date
                           page:(NSNumber*)page
                            per:(NSNumber*)per
                           sort:(IQSortDirection)sort
                        handler:(ObjectRequestCompletionHandler)handler;

- (void)activitiesForTaskWithId:(NSNumber*)taskId
                       beforeId:(NSNumber*)beforeId
                           page:(NSNumber*)page
                            per:(NSNumber*)per
                           sort:(IQSortDirection)sort
                        handler:(ObjectRequestCompletionHandler)handler;

- (void)taskCommunitiesWithHandler:(ObjectRequestCompletionHandler)handler;

- (void)mostUsedCommunityWithHandler:(ObjectRequestCompletionHandler)handler;

- (void)taskExecutorsForCommunityId:(NSNumber*)communityId handler:(ObjectRequestCompletionHandler)handler;

- (void)createTask:(IQTaskDataHolder*)task handler:(ObjectRequestCompletionHandler)handler;

- (void)saveTask:(IQTaskDataHolder*)task handler:(ObjectRequestCompletionHandler)handler;

- (void)taskIdsDeletedAfter:(NSDate*)deletedAfter
                    handler:(ObjectRequestCompletionHandler)handler;

- (void)approveTaskWithId:(NSNumber *)taskId handler:(ObjectRequestCompletionHandler)handler;

- (void)disapproveTaskWithId:(NSNumber *)taskId handler:(ObjectRequestCompletionHandler)handler;

- (void)complexityKindsWithHadnler:(ObjectRequestCompletionHandler)handler;

@end
