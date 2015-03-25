//
//  IQService+Tasks.h
//  IQ300
//
//  Created by Tayphoon on 24.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQService.h"

@interface IQService (Tasks)

- (void)tasksUpdatedAfter:(NSDate*)date
                   folder:(NSString*)folder
                   status:(NSString*)status
              communityId:(NSNumber*)communityId
                     page:(NSNumber*)page
                      per:(NSNumber*)per
                   search:(NSString*)search
                     sort:(NSString*)sort
                  handler:(ObjectLoaderCompletionHandler)handler;

- (void)tasksBeforeId:(NSNumber*)taskId
               folder:(NSString*)folder
               status:(NSString*)status
          communityId:(NSNumber*)communityId
                 page:(NSNumber*)page
                  per:(NSNumber*)per
               search:(NSString*)search
                 sort:(NSString*)sort
              handler:(ObjectLoaderCompletionHandler)handler;

- (void)filterCountersForFolder:(NSString*)folder
                         status:(NSString*)status
                    communityId:(NSNumber*)communityId
                        handler:(ObjectLoaderCompletionHandler)handler;

- (void)tasksMenuCountersWithHandler:(ObjectLoaderCompletionHandler)handler;

- (void)taskChangesCounterById:(NSNumber*)taskId handler:(ObjectLoaderCompletionHandler)handler;

- (void)taskWithId:(NSNumber*)taskId handler:(ObjectLoaderCompletionHandler)handler;

- (void)changeStatus:(NSString*)status forTaskWithId:(NSNumber*)taskId reason:(NSString*)reason handler:(ObjectLoaderCompletionHandler)handler;

- (void)completeTodoItemWithId:(NSNumber*)itemId taskId:(NSNumber*)taskId handler:(ObjectLoaderCompletionHandler)handler;

- (void)rollbackTodoItemWithId:(NSNumber*)itemId taskId:(NSNumber*)taskId handler:(ObjectLoaderCompletionHandler)handler;

- (void)markCategoryAsReaded:(NSString*)category taskId:(NSNumber*)taskId handler:(RequestCompletionHandler)handler;

- (void)addAttachmentWithId:(NSNumber*)attachmentId taskId:(NSNumber*)taskId handler:(RequestCompletionHandler)handler;

- (void)membersByTaskId:(NSNumber*)taskId handler:(ObjectLoaderCompletionHandler)handler;

- (void)addMemberWithUserId:(NSNumber*)userId inTaskWithId:(NSNumber*)taskId handler:(ObjectLoaderCompletionHandler)handler;

- (void)removeMemberWithId:(NSNumber*)memberId fromTaskWithId:(NSNumber*)taskId handler:(RequestCompletionHandler)handler;

- (void)leaveTaskWithId:(NSNumber*)taskId handler:(RequestCompletionHandler)handler;

- (void)policiesForTaskWithId:(NSNumber*)taskId handler:(ObjectLoaderCompletionHandler)handler;

@end
