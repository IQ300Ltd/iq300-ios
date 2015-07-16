//
//  IQService+Messages.m
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQService+Messages.h"

@implementation IQService (Messages)

- (void)conversationsWithHandler:(ObjectRequestCompletionHandler)handler {
    [self conversationsUnread:nil page:nil per:nil search:nil sort:IQSortDirectionNo handler:handler];
}

- (void)conversationsUnread:(NSNumber*)unread
                       page:(NSNumber*)page
                        per:(NSNumber*)per
                     search:(NSString*)search
                       sort:(IQSortDirection)sort
                    handler:(ObjectRequestCompletionHandler)handler {
    NSMutableDictionary * parameters = IQParametersExcludeEmpty(@{
                                                                  @"unread" : NSObjectNullForNil(unread),
                                                                  @"page"   : NSObjectNullForNil(page),
                                                                  @"per"    : NSObjectNullForNil(per),
                                                                  @"search" : NSStringNullForNil(search)
                                                                  }).mutableCopy;
    
    if(sort != IQSortDirectionNo) {
        parameters[@"sort"] = IQSortDirectionToString(sort);
    }
    
    [self getObjectsAtPath:@"/api/v1/conversations"
                parameters:parameters
                   handler:handler];
}

- (void)conversationWithId:(NSNumber*)conversationid handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(conversationid);
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/conversations/%@", conversationid]
                parameters:nil
                   handler:handler];
}

- (void)conversationsCountersWithHandler:(ObjectRequestCompletionHandler)handler {
    [self getObjectsAtPath:@"/api/v1/conversations/counters"
                parameters:nil
                   handler:handler];
}

- (void)createConversationWithRecipientId:(NSNumber*)recipientId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(recipientId);
    [self postObject:nil
                path:@"/api/v1/conversations"
          parameters:@{ @"recipient_id" : recipientId }
             handler:handler];
}

- (void)createConversationWithRecipientIds:(NSArray*)recipientIds handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(recipientIds);
    [self postObject:nil
                path:@"/api/v1/conversations/create_conference"
          parameters:@{ @"participant_ids" : recipientIds }
             handler:handler];
}

- (void)conferenceFromConversationWithId:(NSNumber*)conversationId
                                 userIds:(NSArray*)userIds
                                 handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(conversationId);
    NSParameterAssert(userIds);
    [self postObject:nil
                path:[NSString stringWithFormat:@"/api/v1/conversations/%@/dialog_to_conference", conversationId]
          parameters:@{ @"participant_ids" : userIds }
             handler:handler];
}

- (void)updateConversationTitle:(NSString*)title
                 conversationId:(NSNumber*)conversationId
                        handler:(RequestCompletionHandler)handler {
    NSParameterAssert(conversationId);
    [self putObject:nil
               path:[NSString stringWithFormat:@"/api/v1/conversations/%@/update_title", conversationId]
         parameters:@{ @"title" : NSStringNullForNil(title) }
            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                if (handler) {
                    handler(success, responseData, error);
                }
            }];
}

- (void)membersForConversation:(NSNumber *)conversationId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(conversationId);
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/conversations/%@/participants", conversationId]
                parameters:nil
                   handler:handler];
}


- (void)addMembersWithIds:(NSArray*)memberIds
           toConversation:(NSNumber*)conversationId
                  handler:(RequestCompletionHandler)handler {
    NSParameterAssert(conversationId);
    [self postObject:nil
                path:[NSString stringWithFormat:@"/api/v1/conversations/%@/participants", conversationId]
          parameters:@{ @"user_ids" : NSObjectNullForNil(memberIds) }
             handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                 if(handler) {
                     handler(success, responseData, error);
                 }
             }];
}

- (void)removeMemberWithId:(NSNumber*)memberId
          fromConversation:(NSNumber*)conversationId
                   handler:(RequestCompletionHandler)handler {
    NSParameterAssert(memberId);
    NSParameterAssert(conversationId);
    [self deleteObject:nil
                  path:[NSString stringWithFormat:@"/api/v1/conversations/%@/participants/%@", conversationId, memberId]
            parameters:nil
               handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                   if(handler) {
                       handler(success, responseData, error);
                   }
               }];
}

- (void)leaveConversationWithId:(NSNumber*)conversationId handler:(RequestCompletionHandler)handler {
    NSParameterAssert(conversationId);
    [self putObject:nil
               path:[NSString stringWithFormat:@"/api/v1/conversations/%@/participants/leave", conversationId]
         parameters:nil
            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                if(handler) {
                    handler(success, responseData, error);
                }
            }];
}

#pragma mark - Discussion methods

- (void)discussionWithId:(NSNumber*)discussionId handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(discussionId);
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/discussions/%@", discussionId]
                parameters:nil
                   handler:handler];
}

- (void)markDiscussionAsReadedWithId:(NSNumber *)discussionId handler:(RequestCompletionHandler)handler {
    [self putObject:nil
               path:[NSString stringWithFormat:@"/api/v1/discussions/%@", discussionId]
         parameters:nil
            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                if(handler) {
                    handler(success, responseData, error);
                }
            }];
}

- (void)commentsForDiscussionWithId:(NSNumber*)discussionId
                               page:(NSNumber*)page
                                per:(NSNumber*)per
                               sort:(IQSortDirection)sort
                            handler:(ObjectRequestCompletionHandler)handler {
    NSMutableDictionary * parameters = IQParametersExcludeEmpty(@{
                                                                  @"page"   : NSObjectNullForNil(page),
                                                                  @"per"    : NSObjectNullForNil(per),
                                                                  }).mutableCopy;
    
    if(sort != IQSortDirectionNo) {
        parameters[@"sort"] = IQSortDirectionToString(sort);
    }

    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/discussions/%@/comments", discussionId]
                parameters:parameters
                   handler:handler];
}

- (void)markCommentsAsReadedWithIds:(NSArray*)commentIds
                       discussionId:(NSNumber*)discussionId
                            handler:(RequestCompletionHandler)handler {
    [self putObject:nil
               path:[NSString stringWithFormat:@"/api/v1/discussions/%@/comments/read", discussionId]
         parameters:@{ @"comment_ids" : commentIds }
            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                if(handler) {
                    handler(success, responseData, error);
                }
            }];
}

- (void)createComment:(NSString*)comment
         discussionId:(NSNumber*)discussionId
        attachmentIds:(NSArray*)attachmentIds
              handler:(ObjectRequestCompletionHandler)handler {
    NSDictionary * parameters = IQParametersExcludeEmpty(@{
                                                           @"body"           : NSStringNullForNil(comment),
                                                           @"attachment_ids" : NSObjectNullForNil(attachmentIds)
                                                          });
    [self postObject:nil
                path:[NSString stringWithFormat:@"/api/v1/discussions/%@/comments", discussionId]
          parameters:@{ @"comment" : parameters }
             handler:handler];
}

- (void)commentWithId:(NSNumber*)commentId
         discussionId:(NSNumber*)discussionId
              handler:(ObjectRequestCompletionHandler)handler {
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/discussions/%@/comments/%@", discussionId, commentId]
                parameters:nil
                   handler:handler];
}

- (void)contactsWithPage:(NSNumber*)page
                     per:(NSNumber*)per
                    sort:(IQSortDirection)sort
                  search:(NSString*)search
                 handler:(ObjectRequestCompletionHandler)handler {
    NSMutableDictionary * parameters = IQParametersExcludeEmpty(@{
                                                                  @"page"   : NSObjectNullForNil(page),
                                                                  @"per"    : NSObjectNullForNil(per),
                                                                  @"search" : NSStringNullForNil(search)
                                                                  }).mutableCopy;
    
    if(sort != IQSortDirectionNo) {
        parameters[@"sort"] = IQSortDirectionToString(sort);
    }
    
    [self getObjectsAtPath:@"/api/v1/contacts"
                parameters:parameters
                   handler:handler];

}

- (void)deleteCommentWithId:(NSNumber*)commentId
               discussionId:(NSNumber*)discussionId
                    handler:(RequestCompletionHandler)handler {
    [self deleteObject:nil
                  path:[NSString stringWithFormat:@"/api/v1/discussions/%@/comments/%@", discussionId, commentId]
            parameters:nil
               handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                   if (handler) {
                       handler(success, responseData, error);
                   }
               }];
}

- (void)commentIdsDeletedAfter:(NSDate*)deletedAfter
                  discussionId:(NSNumber*)discussionId
                       handler:(ObjectRequestCompletionHandler)handler {
    NSParameterAssert(discussionId);
    
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/discussions/%@/comments/deleted_ids", discussionId]
                parameters:IQParametersExcludeEmpty(@{ @"deleted_at_after" : NSObjectNullForNil(deletedAfter) })
                   handler:handler];
}

- (void)conversationsIdsDeletedAfter:(NSDate*)deletedAfter
                             handler:(ObjectRequestCompletionHandler)handler {
    [self getObjectsAtPath:@"/api/v1/conversations/deleted_ids"
                parameters:IQParametersExcludeEmpty(@{ @"deleted_at_after" : NSObjectNullForNil(deletedAfter) })
                   handler:handler];
}

@end
