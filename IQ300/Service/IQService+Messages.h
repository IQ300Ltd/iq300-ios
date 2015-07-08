//
//  IQService+Messages.h
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQService.h"

@interface IQService (Messages)

- (void)conversationsWithHandler:(ObjectRequestCompletionHandler)handler;

- (void)conversationsUnread:(NSNumber*)unread
                       page:(NSNumber*)page
                        per:(NSNumber*)per
                     search:(NSString*)search
                       sort:(IQSortDirection)sort
                    handler:(ObjectRequestCompletionHandler)handler;

- (void)conversationWithId:(NSNumber*)conversationid handler:(ObjectRequestCompletionHandler)handler;

- (void)conversationsCountersWithHandler:(ObjectRequestCompletionHandler)handler;

- (void)createConversationWithRecipientId:(NSNumber*)recipientId handler:(ObjectRequestCompletionHandler)handler;

- (void)createConversationWithRecipientIds:(NSArray*)recipientIds handler:(ObjectRequestCompletionHandler)handler;

- (void)convertDialogToConferenceById:(NSNumber*)conversationid
                            memberIds:(NSArray*)memberIds
                              handler:(ObjectRequestCompletionHandler)handler;

- (void)discussionWithId:(NSNumber*)discussionId handler:(ObjectRequestCompletionHandler)handler;

- (void)markDiscussionAsReadedWithId:(NSNumber*)discussionId handler:(RequestCompletionHandler)handler;

- (void)commentsForDiscussionWithId:(NSNumber*)discussionId
                               page:(NSNumber*)page
                                per:(NSNumber*)per
                               sort:(IQSortDirection)sort
                            handler:(ObjectRequestCompletionHandler)handler;

- (void)markCommentsAsReadedWithIds:(NSArray*)commentIds discussionId:(NSNumber*)discussionId handler:(RequestCompletionHandler)handler;

- (void)createComment:(NSString*)comment
         discussionId:(NSNumber*)discussionId
        attachmentIds:(NSArray*)attachmentIds
              handler:(ObjectRequestCompletionHandler)handler;

- (void)commentWithId:(NSNumber*)commentId
         discussionId:(NSNumber*)discussionId
              handler:(ObjectRequestCompletionHandler)handler;

- (void)contactsWithPage:(NSNumber*)page
                     per:(NSNumber*)per
                    sort:(IQSortDirection)sort
                  search:(NSString*)search
                 handler:(ObjectRequestCompletionHandler)handler;

- (void)deleteCommentWithId:(NSNumber*)commentId
               discussionId:(NSNumber*)discussionId
                    handler:(RequestCompletionHandler)handler;

- (void)commentIdsDeletedAfter:(NSDate*)deletedAfter
                  discussionId:(NSNumber*)discussionId
                       handler:(ObjectRequestCompletionHandler)handler;

@end
