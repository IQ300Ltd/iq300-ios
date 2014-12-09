//
//  IQService+Messages.h
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQService.h"

@interface IQService (Messages)

- (void)conversationsWithHandler:(ObjectLoaderCompletionHandler)handler;
- (void)conversationsUnread:(NSNumber*)unread page:(NSNumber*)page per:(NSNumber*)per search:(NSString*)search sort:(IQSortDirection)sort handler:(ObjectLoaderCompletionHandler)handler;
- (void)conversationWithId:(NSNumber*)conversationid handler:(ObjectLoaderCompletionHandler)handler;
- (void)conversationsCountersWithHandler:(ObjectLoaderCompletionHandler)handler;
- (void)createConversationWithRecipientId:(NSNumber*)recipientId handler:(ObjectLoaderCompletionHandler)handler;
- (void)markDiscussionAsReadedWithId:(NSNumber*)discussionId handler:(RequestCompletionHandler)handler;

- (void)commentsForDiscussionWithId:(NSNumber*)discussionId page:(NSNumber*)page per:(NSNumber*)per sort:(IQSortDirection)sort handler:(ObjectLoaderCompletionHandler)handler;

- (void)createComment:(NSString*)comment
         discussionId:(NSNumber*)discussionId
        attachmentIds:(NSArray*)attachmentIds
              handler:(ObjectLoaderCompletionHandler)handler;

- (void)createAttachmentWithAsset:(ALAsset*)asset fileName:(NSString*)fileName mimeType:(NSString *)mimeType handler:(ObjectLoaderCompletionHandler)handler;

- (void)contactsWithPage:(NSNumber*)page per:(NSNumber*)per sort:(IQSortDirection)sort search:(NSString*)search handler:(ObjectLoaderCompletionHandler)handler;

@end
