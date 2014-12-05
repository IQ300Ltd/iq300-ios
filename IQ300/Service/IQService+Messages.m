//
//  IQService+Messages.m
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQService+Messages.h"

@implementation IQService (Messages)

- (void)conversationsWithHandler:(ObjectLoaderCompletionHandler)handler {
    [self conversationsUnread:nil page:nil per:nil search:nil sort:IQSortDirectionNo handler:handler];
}

- (void)conversationsUnread:(NSNumber*)unread page:(NSNumber*)page per:(NSNumber*)per search:(NSString*)search handler:(ObjectLoaderCompletionHandler)handler {
    [self conversationsUnread:unread page:page per:per search:search sort:IQSortDirectionNo handler:handler];
}

- (void)conversationsUnread:(NSNumber*)unread page:(NSNumber*)page per:(NSNumber*)per sort:(IQSortDirection)sort handler:(ObjectLoaderCompletionHandler)handler {
    [self conversationsUnread:unread page:page per:per search:nil sort:sort handler:handler];
}

- (void)conversationWithId:(NSNumber*)conversationid handler:(ObjectLoaderCompletionHandler)handler {
    NSParameterAssert(conversationid);
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/conversations/%@", conversationid]
                parameters:nil
                   handler:handler];
}

- (void)conversationsCountersWithHandler:(ObjectLoaderCompletionHandler)handler {
    [self getObjectsAtPath:@"/api/v1/conversations/counters"
                parameters:nil
                   handler:handler];
}

- (void)createConversationWithRecipientId:(NSNumber*)recipientId handler:(ObjectLoaderCompletionHandler)handler {
    NSParameterAssert(recipientId);
    [self postObject:nil
                path:@"/api/v1/conversations"
          parameters:@{ @"recipient_id" : recipientId }
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

#pragma mark - Comments methods

- (void)commentsForDiscussionWithId:(NSNumber*)discussionId page:(NSNumber*)page per:(NSNumber*)per sort:(IQSortDirection)sort handler:(ObjectLoaderCompletionHandler)handler {
    NSMutableDictionary * parameters = IQParametersExcludeEmpty(@{
                                                                  @"page"   : NSObjectNullForNil(page),
                                                                  @"per"    : NSObjectNullForNil(per),
                                                                  }).mutableCopy;
    
    if(sort == IQSortDirectionNo) {
        parameters[@"sort"] = IQSortDirectionToString(sort);
    }

    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/discussions/%@/comments", discussionId]
                parameters:parameters
                   handler:handler];
}

- (void)createComment:(NSString*)comment discussionId:(NSNumber*)discussionId attachmentIds:(NSArray*)attachmentIds handler:(RequestCompletionHandler)handler {
    NSDictionary * parameters = IQParametersExcludeEmpty(@{
                                                           @"body"           : NSStringNullForNil(comment),
                                                           @"attachment_ids" : NSObjectNullForNil(attachmentIds)
                                                          });
    [self postObject:nil
                path:[NSString stringWithFormat:@"/api/v1/discussions/%@/comments", discussionId]
          parameters:parameters
             handler:^(BOOL success, id object, NSData * responseData, NSError *error) {
                 if(handler) {
                     handler(success, responseData, error);
                 }
             }];
}

- (void)createAttachment:(NSData *)attachmentData fileName:(NSString*)fileName title:(NSString*)title mimeType:(NSString *)mimeType handler:(RequestCompletionHandler)handler {
    [self postData:attachmentData
              path:@"/api/v1/attachments"
        parameters:@{ @"attachment[title]" : NSStringNullForNil(title) }
 fileAttributeName:@"attachment[file]"
          fileName:fileName
          mimeType:mimeType
           handler:^(BOOL success, id object, NSData * responseData, NSError *error) {
               if(handler) {
                   handler(success, responseData, error);
               }
           }];
}

#pragma mark - Private methods

- (void)conversationsUnread:(NSNumber*)unread page:(NSNumber*)page per:(NSNumber*)per search:(NSString*)search sort:(IQSortDirection)sort handler:(ObjectLoaderCompletionHandler)handler {
    NSMutableDictionary * parameters = IQParametersExcludeEmpty(@{
                                                                  @"unread" : NSObjectNullForNil(unread),
                                                                  @"page"   : NSObjectNullForNil(page),
                                                                  @"per"    : NSObjectNullForNil(per),
                                                                  @"search" : NSStringNullForNil(search)
                                                                  }).mutableCopy;
    
    if(sort == IQSortDirectionNo) {
        parameters[@"sort"] = IQSortDirectionToString(sort);
    }
    
    [self getObjectsAtPath:@"/api/v1/conversations"
                parameters:parameters
                   handler:handler];
}

@end
