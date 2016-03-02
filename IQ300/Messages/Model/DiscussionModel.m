//
//  DiscussionModel.m
//  IQ300
//
//  Created by Tayphoon on 04.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/CoreData/NSManagedObjectContext+RKAdditions.h>
#import <RestKit/RestKit.h>

#import "DiscussionModel.h"
#import "IQService+Messages.h"
#import "CommentCell.h"
#import "IQDiscussion.h"
#import "IQComment.h"
#import "CViewInfo.h"
#import "ALAsset+Extension.h"
#import "NSString+UUID.h"
#import "IQNotificationCenter.h"
#import "TCObjectSerializator.h"
#import "NSManagedObjectContext+AsyncFetch.h"
#import "NSDate+IQFormater.h"
#import "NSDate+CupertinoYankee.h"
#import "DispatchAfterExecution.h"
#import "CommentDeletedObjects.h"
#import "IQConversation.h"
#import "NSManagedObject+ActiveRecord.h"
#import "SystemCommentCell.h"
#import "SharingAttachment.h"

#define CACHE_FILE_NAME @"DiscussionModelcache"
#define SORT_DIRECTION IQSortDirectionDescending
#define LAST_REQUEST_DATE_KEY @"comment_ids_request_date"

static NSString * CommentReuseIdentifier = @"CommentReuseIdentifier";
static NSString * SystemReuseIdentifier = @"SystemReuseIdentifier";

NSString * const IQConferencesTitleDidChangedEvent = @"conferences:title_changed";
NSString * const IQConferencesMemberDidAddEvent = @"conferences:member_added";
NSString * const IQConferencesMemberDidRemovedEvent = @"conferences:member_removed";

@interface DiscussionModel() <NSFetchedResultsControllerDelegate> {
    NSInteger _portionLenght;
    NSArray * _sortDescriptors;
    NSFetchedResultsController * _fetchController;
    __weak id _newMessageObserver;
    __weak id _messageViewedObserver;
    NSDate * _lastViewDate;
    NSDateFormatter * _dateFormatter;
    NSMutableDictionary * _expandedCells;
    NSMutableDictionary * _expandableCells;
}

@end

@implementation DiscussionModel

+ (void)conferenceFromConversationWithId:(NSNumber*)conversationId
                                 userIds:(NSArray*)userIds
                              completion:(void (^)(IQConversation * conversation, NSError *error))completion {
    [[IQService sharedService] conferenceFromConversationWithId:conversationId
                                                        userIds:userIds
                                                        handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                                                            if (success) {
                                                                [GAIService sendEventForCategory:GAIMessagesEventCategory
                                                                                          action:@"event_action_message_conversation_create"];
                                                                
                                                                [GAIService sendEventForCategory:GAIMessagesEventCategory
                                                                                          action:GAIAddConversationMemberEventAction
                                                                                           label:[userIds componentsJoinedByString:@", "]];
                                                            }
                                                            
                                                            if (completion) {
                                                                completion(object, error);
                                                            }
                                                        }];
}

+ (NSDate*)lastRequestDate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:LAST_REQUEST_DATE_KEY];
}

+ (void)setLastRequestDate:(NSDate*)date {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:date forKey:LAST_REQUEST_DATE_KEY];
}

- (id)init {
    self = [super init];
    if(self) {
        _expandedCells = [NSMutableDictionary dictionary];
        _expandableCells = [NSMutableDictionary dictionary];
        _portionLenght = 20;
        NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:YES];
        _sortDescriptors = @[descriptor];
    }
    return self;
}

- (id)initWithDiscussion:(IQDiscussion *)discussion {
    self = [self init];
    
    if(self) {
        _discussion = discussion;
        [self updateLastViewedDate];
    }
    
    return self;
}

- (NSUInteger)numberOfSections {
    return [_fetchController.sections count];
}

- (NSString*)titleForSection:(NSInteger)section {
    IQComment * comment = [self itemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    NSString * stringDate = nil;
    NSDate * today = [[NSDate date] beginningOfDay];
    NSDate * yesterday = [today prevDay];
    NSDate * beginningOfDay = comment.createShortDate;
    
    if([beginningOfDay compare:today] == NSOrderedSame) {
        stringDate =  NSLocalizedString(@"Today", nil);
    }
    else if([beginningOfDay compare:yesterday] == NSOrderedSame) {
        stringDate = NSLocalizedString(@"Yesterday", nil);
    }
    else {
        stringDate = [comment.createShortDate dateToStringWithFormat:@"dd.MM.yyyy"];
    }
    
    return stringDate;

}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [_fetchController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    IQComment * comment = [self itemAtIndexPath:indexPath];
    BOOL isSystemComment = ([[comment.type lowercaseString] isEqualToString:@"system"]);
    return (isSystemComment) ? SystemReuseIdentifier : CommentReuseIdentifier;
}

- (Class)cellClassForIndexPath:(NSIndexPath*)indexPath {
    IQComment * comment = [self itemAtIndexPath:indexPath];
    BOOL isSystemComment = ([[comment.type lowercaseString] isEqualToString:@"system"]);
    return (isSystemComment) ? [SystemCommentCell class] : [CommentCell class];
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    Class cellClass = [self cellClassForIndexPath:indexPath];
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                            reuseIdentifier:[self reuseIdentifierForIndexPath:indexPath]];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    IQComment * comment = [self itemAtIndexPath:indexPath];
    Class<IQCommentCell> cellClass = [self cellClassForIndexPath:indexPath];
    
    if(comment && ![_expandableCells objectForKey:comment.commentId] && self.cellWidth > 0) {
        BOOL expandable = [cellClass cellNeedToBeExpandableForItem:comment
                           сellWidth:self.cellWidth];
        
        [_expandableCells setObject:@(expandable) forKey:comment.commentId];
    }
    
    BOOL isExpanded = [self isItemExpandedAtIndexPath:indexPath];
    return [cellClass heightForItem:comment
                           expanded:isExpanded
                          сellWidth:self.cellWidth];
}

- (id)itemAtIndexPath:(NSIndexPath*)indexPath {
    if(indexPath.section < [self numberOfSections] &&
       indexPath.row < [self numberOfItemsInSection:indexPath.section]) {
        return [_fetchController objectAtIndexPath:indexPath];
    }
    return nil;
}

- (NSIndexPath *)indexPathOfObject:(id)object {
    return [_fetchController indexPathForObject:object];
}

- (Class)controllerClassForItemAtIndexPath:(NSIndexPath*)indexPath {
    return nil;
}

- (BOOL)isItemExpandedAtIndexPath:(NSIndexPath*)indexPath {
    IQComment * comment = [self itemAtIndexPath:indexPath];
    BOOL isExpanded = [[_expandedCells objectForKey:comment.commentId] boolValue];
    return isExpanded;
}

- (BOOL)isCellExpandableAtIndexPath:(NSIndexPath*)indexPath {
    IQComment * comment = [self itemAtIndexPath:indexPath];
    BOOL isExpandable = [[_expandableCells objectForKey:comment.commentId] boolValue];
    return isExpandable;
}

- (void)setItemExpanded:(BOOL)expanded atIndexPath:(NSIndexPath*)indexPath {
    IQComment * comment = [self itemAtIndexPath:indexPath];
    BOOL isExpanded = [[_expandedCells objectForKey:comment.commentId] boolValue];
    if(isExpanded != expanded && comment) {
        [_expandedCells setObject:@(expanded) forKey:comment.commentId];
        [self modelWillChangeContent];
        [self modelDidChangeObject:nil
                       atIndexPath:indexPath
                     forChangeType:NSFetchedResultsChangeUpdate
                      newIndexPath:nil];
        [self modelDidChangeContent];
    }
}

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion {
    BOOL hasObjects = ([_fetchController.fetchedObjects count] > 0);
    if(!hasObjects) {
        [self reloadModelWithCompletion:completion];
    }
    else {
        [self clearRemovedComments];
        
        [[IQService sharedService] commentsForDiscussionWithId:_discussion.discussionId
                                                          page:@(1)
                                                           per:@(_portionLenght)
                                                          sort:SORT_DIRECTION
                                                       handler:^(BOOL success, NSArray * comments, NSData *responseData, NSError *error) {
                                                           if(!error) {
                                                               [self updateDefaultStatusesForComments:comments];
                                                               if(completion) {
                                                                   completion(error);
                                                               }
                                                           }
                                                       }];
    }
}

- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelWithCompletion:completion];
    }
    else {
        NSInteger count = [_fetchController.fetchedObjects count];
        NSInteger page = (count > 0) ? count / _portionLenght + 1 : 1;
        [[IQService sharedService] commentsForDiscussionWithId:_discussion.discussionId
                                                          page:@(page)
                                                           per:@(_portionLenght)
                                                          sort:SORT_DIRECTION
                                                       handler:^(BOOL success, NSArray * comments, NSData *responseData, NSError *error) {
                                                           if(!error) {
                                                               [self updateDefaultStatusesForComments:comments];
                                                           }
                                                           if(completion) {
                                                               completion(error);
                                                           }
                                                       }];
    }
}

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion {
    [_expandableCells removeAllObjects];
    [_expandedCells removeAllObjects];
    
    [[IQService sharedService] commentsForDiscussionWithId:_discussion.discussionId
                                                      page:@(1)
                                                       per:@(_portionLenght)
                                                      sort:SORT_DIRECTION
                                                   handler:^(BOOL success, NSArray * comments, NSData *responseData, NSError *error) {
                                                       if(!error) {
                                                           [self updateDefaultStatusesForComments:comments];
                                                       }
                                                       
                                                       [self reloadModelSourceControllerWithCompletion:^(NSError * fetchError) {
                                                           if (!error) {
                                                               [self clearRemovedComments];
                                                           }
                                                           [self modelDidChanged];
                                                       }];

                                                       if(completion) {
                                                           completion(error);
                                                       }
                                                   }];
}

- (void)clearModelData {
    [NSFetchedResultsController deleteCacheWithName:CACHE_FILE_NAME];
    if(_fetchController) {
        [_fetchController.fetchRequest setPredicate:[NSPredicate predicateWithValue:NO]];
        [_fetchController performFetch:nil];
        [_fetchController setDelegate:nil];
        _fetchController = nil;
    }
}

- (void)setSubscribedToNotifications:(BOOL)subscribed {
    if(subscribed) {
        [self resubscribeToIQNotifications];
    }
    else {
        [self unsubscribeFromIQNotification];
    }
}

- (void)sendComment:(NSString *)comment
         attachment:(SharingAttachment *)attachment
     withCompletion:(void (^)(NSError *))completion {
    
    void (^sendCommentBlock)(NSArray * attachmentIds) = ^ (NSArray * attachments) {
        NSArray * attachmentIds = [attachments valueForKey:@"attachmentId"];
        [[IQService sharedService] createComment:comment
                                    discussionId:_discussion.discussionId
                                   attachmentIds:attachmentIds
                                         handler:^(BOOL success, IQComment * item, NSData *responseData, NSError *error) {
                                             NSError * saveError = nil;
                                             if (!success) {
                                                 [self createLocalComment:comment attachments:attachments error:&saveError];
                                                 if(saveError) {
                                                     NSLog(@"Create comment error: %@", saveError);
                                                 }
                                                 if (completion) {
                                                     completion(saveError);
                                                 }
                                             }
                                             else {
                                                 [GAIService sendEventForCategory:GAIMessagesEventCategory
                                                                           action:GAICreateMessageEventAction];
                                                 
                                                 item.commentStatus = @(IQCommentStatusSent);
                                                 [item.managedObjectContext saveToPersistentStore:&saveError];
                                                 if(saveError) {
                                                     NSLog(@"Create comment status error: %@", saveError);
                                                 }
                                                 if (completion) {
                                                     completion(error);
                                                 }
                                             }
                                         }];
    };
    
    [[IQService sharedService] createAttachmentWithFileAtPath:attachment.localURL
                                                     fileName:attachment.displayName
                                                     mimeType:attachment.contentType
                                                      handler:^(BOOL success, IQManagedAttachment * attachmentObject, NSData *responseData, NSError *error) {
                                                          if(success) {
                                                              sendCommentBlock(@[attachmentObject]);
                                                              [GAIService sendEventForCategory:GAICommonEventCategory
                                                                                        action:GAIFileUploadEventAction];
                                                          }
                                                          else {
                                                              NSError *localError;
                                                              
                                                              IQManagedAttachment *localAttachment = [self createLocalAttachmentWithFilePath:attachment.localURL fileName:attachment.displayName contentType:attachment.contentType error:&localError];
                                                              if (localAttachment) {
                                                                  sendCommentBlock(@[localAttachment]);
                                                              }
                                                              else if (completion) {
                                                                  completion(localError ? localError : error);
                                                              }
                                                          }
                                                      }];

}

- (void)sendComment:(NSString*)comment
         attachment:(id)attachment
           fileName:(NSString*)fileName
           mimeType:(NSString*)mimeType
     withCompletion:(void (^)(NSError * error))completion {
    
    void (^sendCommentBlock)(NSArray * attachmentIds) = ^ (NSArray * attachments) {
        NSArray * attachmentIds = [attachments valueForKey:@"attachmentId"];
        [[IQService sharedService] createComment:comment
                                    discussionId:_discussion.discussionId
                                   attachmentIds:attachmentIds
                                         handler:^(BOOL success, IQComment * item, NSData *responseData, NSError *error) {
                                             NSError * saveError = nil;
                                            if (!success) {
                                                [self createLocalComment:comment attachments:attachments error:&saveError];
                                                if(saveError) {
                                                    NSLog(@"Create comment error: %@", saveError);
                                                }
                                                if (completion) {
                                                    completion(saveError);
                                                }
                                             }
                                             else {
                                                 [GAIService sendEventForCategory:GAIMessagesEventCategory
                                                                           action:GAICreateMessageEventAction];

                                                 item.commentStatus = @(IQCommentStatusSent);
                                                 [item.managedObjectContext saveToPersistentStore:&saveError];
                                                 if(saveError) {
                                                     NSLog(@"Create comment status error: %@", saveError);
                                                 }
                                                 if (completion) {
                                                     completion(error);
                                                 }
                                             }
                                         }];
    };
    
    if(attachment && [attachment isKindOfClass:[ALAsset class]]) {
        [[IQService sharedService] createAttachmentWithAsset:attachment
                                                    fileName:fileName
                                                    mimeType:mimeType
                                                     handler:^(BOOL success, IQManagedAttachment * attachmentObject, NSData *responseData, NSError *error) {
                                                        if(success) {
                                                            sendCommentBlock(@[attachmentObject]);
                                                            [GAIService sendEventForCategory:GAICommonEventCategory
                                                                                      action:GAIFileUploadEventAction];
                                                        }
                                                        else {
                                                            [self createLocalAttachmentWithAsset:(ALAsset*)attachment
                                                                                        fileName:fileName
                                                                                        mimeType:mimeType
                                                                                      completion:^(IQManagedAttachment * attachmentObject, NSError *error) {
                                                                                          if(attachmentObject) {
                                                                                              sendCommentBlock(@[attachmentObject]);
                                                                                          }
                                                                                          else if (completion) {
                                                                                              completion(error);
                                                                                          }
                                                                                      }];
                                                        }
                                                    }];
    }
    else if(attachment && [attachment isKindOfClass:[UIImage class]]) {
        [[IQService sharedService] createAttachmentWithImage:attachment
                                                    fileName:fileName
                                                    mimeType:mimeType
                                                     handler:^(BOOL success, IQManagedAttachment * attachmentObject, NSData *responseData, NSError *error) {
                                                         if(success) {
                                                             sendCommentBlock(@[attachmentObject]);
                                                             [GAIService sendEventForCategory:GAICommonEventCategory
                                                                                       action:GAIFileUploadEventAction];
                                                         }
                                                         else {
                                                             [self createLocalAttachmentWithImage:(UIImage*)attachment
                                                                                         fileName:fileName
                                                                                         mimeType:mimeType
                                                                                       completion:^(IQManagedAttachment * attachmentObject, NSError *error) {
                                                                 if(attachmentObject) {
                                                                     sendCommentBlock(@[attachmentObject]);
                                                                 }
                                                                 else if (completion) {
                                                                     completion(error);
                                                                 }
                                                             }];
                                                         }
                                                     }];
    }
    else {
        sendCommentBlock(nil);
    }
}

- (void)resendLocalComment:(IQComment*)comment withCompletion:(void (^)(NSError * error))completion {
    void (^sendCommentBlock)(NSArray * attachmentIds) = ^ (NSArray * attachments) {
        NSArray * attachmentIds = [attachments valueForKey:@"attachmentId"];
        [[IQService sharedService] createComment:comment.body
                                    discussionId:comment.discussionId
                                   attachmentIds:attachmentIds
                                         handler:^(BOOL success, IQComment * item, NSData *responseData, NSError *error) {
                                             if (success) {
                                                 [GAIService sendEventForCategory:GAIMessagesEventCategory
                                                                           action:GAICreateMessageEventAction];
                                                 NSError * saveError = nil;
                                                 item.commentStatus = @(IQCommentStatusSent);
                                                 [item.managedObjectContext saveToPersistentStore:&saveError];
                                                 if(saveError) {
                                                     NSLog(@"Create comment status error: %@", saveError);
                                                 }
                                             }
                                             
                                             if (completion) {
                                                 completion(error);
                                             }
                                         }];
    };

    IQManagedAttachment * localAttachment = [[comment.attachments allObjects] firstObject];
    if([localAttachment.originalURL length] > 0) {
        [[IQService sharedService] createAttachmentWithFileAtPath:localAttachment.localURL
                                                         fileName:localAttachment.displayName
                                                         mimeType:localAttachment.contentType
                                                          handler:^(BOOL success, IQManagedAttachment * attachment, NSData *responseData, NSError *error) {
                                                              if(success) {
                                                                  sendCommentBlock(@[attachment]);
                                                                  [GAIService sendEventForCategory:GAICommonEventCategory
                                                                                            action:GAIFileUploadEventAction];
                                                              }
                                                              else if (completion) {
                                                                  completion(error);
                                                              }
                                                          }];
    }
    else {
        sendCommentBlock(nil);
    }
}

- (void)deleteComment:(IQComment*)comment completion:(void (^)(NSError * error))completion {
    [[IQService sharedService] deleteCommentWithId:comment.commentId
                                      discussionId:comment.discussionId
                                           handler:^(BOOL success, NSData *responseData, NSError *error) {
                                               if (success) {
                                                   [self deleteLocalComment:comment];
                                               }
                                               if (completion) {
                                                   completion(error);
                                               }
                                           }];
}

- (void)deleteLocalComment:(IQComment *)comment {
    NSArray * attachments = [comment.attachments allObjects];
    for (IQManagedAttachment * attachment in attachments) {
        NSError * removeError = nil;
        if(![[NSFileManager defaultManager] removeItemAtPath:attachment.localURL error:&removeError]) {
            NSLog(@"Failed delete tmp attachment file with error: %@", removeError);
        }
        [attachment.managedObjectContext deleteObject:attachment];
    }
    
    [comment.managedObjectContext deleteObject:comment];
    
    NSError *saveError = nil;
    if(![[IQService sharedService].context saveToPersistentStore:&saveError] ) {
        NSLog(@"Save delete comment error: %@", saveError);
    }

}

- (void)markDiscussionAsReadedWithCompletion:(void (^)(NSError * error))completion {
    [[IQService sharedService] markDiscussionAsReadedWithId:_discussion.discussionId
                                                    handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                        if(success) {
                                                            NSDictionary * userInfo = @{ ChangedCounterNameUserInfoKey : @"messages" };
                                                            [[NSNotificationCenter defaultCenter] postNotificationName:CountersDidChangedNotification
                                                                                                                object:nil
                                                                                                              userInfo:userInfo];
                                                        }
                                                        if(completion) {
                                                            completion(error);
                                                        }
                                                    }];
}

- (BOOL)isDiscussionConference {
    return ([[_discussion.conversation.type lowercaseString] isEqualToString:@"conference"]);
}

- (void)lockConversation {
    self.discussion.conversation.locked = @(YES);
    NSError * saveError = nil;
    if(![self.discussion.conversation.managedObjectContext saveToPersistentStore:&saveError]) {
        NSLog(@"Failed save to presistent store conversation with removed mark");
    }
}

- (void)unlockConversation {
    self.discussion.conversation.locked = @(NO);
    NSError * saveError = nil;
    if(![self.discussion.conversation.managedObjectContext saveToPersistentStore:&saveError]) {
        NSLog(@"Failed save to presistent store conversation with removed mark");
    }
}

#pragma mark - Private methods

- (void)updateLastViewedDate {
    if([IQSession defaultSession].userId) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId != %@", [IQSession defaultSession].userId];
        NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"viewDate" ascending:NO];
        NSSet * filteredSet = [_discussion.userViews filteredSetUsingPredicate:predicate];
        CViewInfo * viewInfo = [[filteredSet sortedArrayUsingDescriptors:@[sortDescriptor]] firstObject];
        if (viewInfo) {
            _lastViewDate = viewInfo.viewDate;
        }
    }
}

- (void)updateDefaultStatusesForComments:(NSArray*)comments {
    NSNumber * userId = [IQSession defaultSession].userId;
    for (IQComment * comment in comments) {
        if([comment.commentStatus integerValue] != IQCommentStatusSendError) {
            BOOL isViewed = (_lastViewDate) ? [comment.createDate compare:_lastViewDate] == NSOrderedAscending : NO;
            IQCommentStatus status = (isViewed) ? IQCommentStatusViewed : IQCommentStatusSent;
            
            if([comment.commentStatus integerValue] != status &&
               userId != nil && [comment.author.userId isEqualToNumber:userId]) {
                comment.commentStatus = @(status);
            }
        }
    }
    
    if([[IQService sharedService].context hasChanges]) {
        NSError *saveError = nil;
        if(![[IQService sharedService].context saveToPersistentStore:&saveError] ) {
            NSLog(@"Save comment statuses error: %@", saveError);
        }
    }
}

- (IQComment*)createLocalComment:(NSString*)text attachments:(NSArray*)attachments error:(NSError**)error {
    NSManagedObjectContext * context = [IQService sharedService].context;
    NSEntityDescription * entity = [NSEntityDescription entityForName:NSStringFromClass([IQComment class])
                                               inManagedObjectContext:context];
    NSNumber * uniqId = [IQComment uniqueLocalIdInContext:context error:error];
    IQUser * user = [IQUser userWithId:[IQSession defaultSession].userId
                             inContext:[IQService sharedService].context];

    if(uniqId && user) {
        IQComment * comment = (IQComment*)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        
        comment.localId = uniqId;
        comment.discussionId = _discussion.discussionId;
        comment.createDate = [NSDate date];
        comment.body = text;
        comment.attachments = [NSSet setWithArray:attachments];
        comment.author = user;
        comment.commentStatus = @(IQCommentStatusSendError);
        
        if([comment.managedObjectContext saveToPersistentStore:error] ) {
            return comment;
        }
    }
    return nil;
}

- (void)createLocalAttachmentWithAsset:(ALAsset*)asset
                              fileName:(NSString*)fileName
                              mimeType:(NSString *)mimeType
                            completion:(void (^)(IQManagedAttachment * attachment, NSError * error))completion {
    NSError * error = nil;
    NSString * diskCachePath = [self createCacheDirIfNeedWithError:&error];
    NSURL * filePath = [NSURL fileURLWithPath:[[diskCachePath stringByAppendingPathComponent:[NSString UUIDString]]
                                               stringByAppendingPathExtension:[asset.fileName pathExtension]]];
    
    if (!error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError * exportAssetError = nil;
            
            if([asset writeToFile:filePath error:&exportAssetError]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError * createEntityError = nil;
                    IQManagedAttachment * attachment =[self createLocalAttachmentWithFilePath:[filePath path]
                                                                              fileName:fileName
                                                                           contentType:mimeType
                                                                                 error:&createEntityError];
                    if(completion) {
                        completion(attachment, createEntityError);
                    }
                });
            }
            else if(completion) {
                completion(nil, exportAssetError);
            }
        });
    }
    else if(completion) {
        completion(nil, error);
    }
}

- (void)createLocalAttachmentWithImage:(UIImage*)image
                              fileName:(NSString*)fileName
                              mimeType:(NSString *)mimeType
                            completion:(void (^)(IQManagedAttachment * attachment, NSError * error))completion {
    NSError * error = nil;
    NSString * diskCachePath = [self createCacheDirIfNeedWithError:&error];
    NSURL * filePath = [NSURL fileURLWithPath:[[diskCachePath stringByAppendingPathComponent:[NSString UUIDString]]
                                               stringByAppendingPathExtension:@"png"]];
    
    if (!error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError * saveDataError = nil;
            NSData * imageData = UIImagePNGRepresentation(image);
            [imageData writeToURL:filePath
                          options:NSDataWritingAtomic error:&saveDataError];
            if (!saveDataError) {
                NSError * createEntityError = nil;
                IQManagedAttachment * attachment = [self createLocalAttachmentWithFilePath:[filePath path]
                                                                           fileName:fileName
                                                                        contentType:mimeType
                                                                              error:&createEntityError];
                if(completion) {
                    completion(attachment, createEntityError);
                }
            }
            else if(completion) {
                completion(nil, saveDataError);
            }
        });
    }
    else if(completion) {
        completion(nil, error);
    }
}

- (IQManagedAttachment*)createLocalAttachmentWithFilePath:(NSString*)filePath fileName:(NSString*)fileName contentType:(NSString*)contentType error:(NSError**)error {
    NSManagedObjectContext * context = [IQService sharedService].context;
    NSNumber * uniqId = [IQManagedAttachment uniqueLocalIdInContext:context error:error];
    if (*error || !uniqId) {
        return nil;
    }

    NSEntityDescription * entity = [NSEntityDescription entityForName:NSStringFromClass([IQManagedAttachment class])
                                               inManagedObjectContext:context];
    
    IQManagedAttachment * attachment = (IQManagedAttachment*)[[NSManagedObject alloc] initWithEntity:entity
                                                        insertIntoManagedObjectContext:context];
    
    attachment.localId = uniqId;
    attachment.createDate = [NSDate date];
    attachment.displayName = fileName;
    attachment.ownerId = [IQSession defaultSession].userId;
    attachment.contentType = contentType;
    attachment.originalURL = filePath;
    attachment.localURL = filePath;
    attachment.previewURL = filePath;
    
    if([attachment.managedObjectContext saveToPersistentStore:error] ) {
        return attachment;
    }
    
    return nil;
}

- (void)reloadModelSourceControllerWithCompletion:(void (^)(NSError * error))completion {
    _fetchController.delegate = nil;
    
    [NSFetchedResultsController deleteCacheWithName:CACHE_FILE_NAME];
    
    if(!_fetchController && [IQService sharedService].context) {
        NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQComment"];
        [fetchRequest setSortDescriptors:_sortDescriptors];
        
        _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                               managedObjectContext:[IQService sharedService].context
                                                                 sectionNameKeyPath:@"createShortDate"
                                                                          cacheName:CACHE_FILE_NAME];
    }
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"discussionId == %@", _discussion.discussionId];
    
    NSError * fetchError = nil;
    [_fetchController.fetchRequest setPredicate:predicate];
    [_fetchController.fetchRequest setSortDescriptors:_sortDescriptors];
    [_fetchController setDelegate:self];
    [_fetchController performFetch:&fetchError];
    
    if(completion) {
        completion(fetchError);
    }
}

- (NSString*)createCacheDirIfNeedWithError:(NSError**)error {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString * namespace = @"com.iq300.FileStore.Share";
    NSString * diskCachePath = [paths[0] stringByAppendingPathComponent:namespace];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:diskCachePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath withIntermediateDirectories:YES attributes:nil error:error];
    }
    
    if(!*error) {
        return diskCachePath;
    }
    
    return nil;
}

- (void)resubscribeToIQNotifications {
    [self unsubscribeFromIQNotification];
    
    __weak typeof(self) weakSelf = self;
    void (^newMessageBlock)(IQCNotification * notf) = ^(IQCNotification * notification) {
        NSDictionary * commentData = notification.userInfo[IQNotificationDataKey][@"comment"];
        NSDictionary * eventData = ((NSNull*)commentData[@"additional_data"] != [NSNull null]) ? commentData[@"additional_data"][@"event"] : nil;
        NSNumber * commentId = commentData[@"id"];
        NSNumber * discussionId = commentData[@"discussion_id"];

        if(discussionId && [_discussion.discussionId isEqualToNumber:discussionId]) {
            
            NSError * requestError = nil;
            NSManagedObjectContext * context = [IQService sharedService].context;
            NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQComment"];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"commentId == %@", commentId];
            NSUInteger count = [context countForFetchRequest:fetchRequest error:&requestError];
            
            if(!requestError && count == 0) {
                NSError * serializeError = nil;
                Class commentClass = [IQComment class];
                IQComment * comment = [TCObjectSerializator objectFromDictionary:@{ NSStringFromClass(commentClass) : commentData }
                                                              destinationClass:[IQComment class]
                                                            managedObjectStore:[IQService sharedService].objectManager.managedObjectStore
                                                                         error:&serializeError];
                
                if(comment) {
                    [self updateDefaultStatusesForComments:@[comment]];
                    
                    [weakSelf modelNewComment:comment];
                    [[IQService sharedService] markDiscussionAsReadedWithId:_discussion.discussionId
                                                                    handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                                        if(!success) {
                                                                            NSLog(@"Mark discussion as read fail with error:%@", error);
                                                                        }
                                                                    }];
                }
            }
            
            NSString * eventName = [eventData[@"name"] lowercaseString];
            if (eventData) {
                NSDictionary * data = eventData[@"data"];
                if ([eventName isEqualToString:IQConferencesTitleDidChangedEvent]) {
                    [self modelConversationTitleDidChanged:data[@"new_title"]];
                }
                else if([eventName isEqualToString:IQConferencesMemberDidAddEvent]) {
                    [self modelMemberDidAddWithId:data[@"user_id"]];
                }
                else if([eventName isEqualToString:IQConferencesMemberDidRemovedEvent]) {
                    [self modelMemberDidRemovedWithId:data[@"user_id"]];
                }
            }
        }
    };
    
    _newMessageObserver = [[IQNotificationCenter defaultCenter] addObserverForName:IQNewMessageNotification
                                                                             queue:nil
                                                                        usingBlock:newMessageBlock];
    
    void (^messageViewedBlock)(IQCNotification * notf) = ^(IQCNotification * notf) {
        NSDictionary * viewData = notf.userInfo[IQNotificationDataKey][@"user_view"];
        NSNumber * userId = viewData[@"user_id"];
        NSNumber * discussionId = viewData[@"discussion_id"];
        NSString * viewedDateString = viewData[@"viewed_at"];
        NSDate * viewedDate = [[weakSelf dateFormater] dateFromString:viewedDateString];
        BOOL isViewDateNewer = (_lastViewDate) ? [_lastViewDate compare:viewedDate] == NSOrderedAscending :
                                                 viewedDate != nil;
        BOOL shouldProcessUserId = (userId) ? ![[IQSession defaultSession].userId isEqualToNumber:userId] : NO;

        if(isViewDateNewer && shouldProcessUserId &&
           discussionId && [_discussion.discussionId isEqualToNumber:discussionId]) {
            _lastViewDate = viewedDate;
            
            NSManagedObjectContext * context = [IQService sharedService].context;
            NSString * format = @"discussionId == %@ AND author.userId == %@ AND commentStatus == %d";
            NSPredicate * predicate = [NSPredicate predicateWithFormat:format, discussionId, [IQSession defaultSession].userId, IQCommentStatusSent];
            NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([IQComment class])];
            [request setPredicate:predicate];
            [context executeFetchRequest:request completion:^(NSArray *objects, NSError *error) {
                if([objects count] > 0) {
                    for (IQComment * comment in objects) {
                        BOOL isViewed = [comment.createDate compare:viewedDate] == NSOrderedAscending;
                        IQCommentStatus status = (isViewed) ? IQCommentStatusViewed : IQCommentStatusSent;
                        if(status != [comment.commentStatus integerValue]) {
                            comment.commentStatus = @(status);
                        }
                    }
                    
                    if([[IQService sharedService].context hasChanges]) {
                        NSError *saveError = nil;
                        if(![[IQService sharedService].context saveToPersistentStore:&saveError] ) {
                            NSLog(@"Save comment statuses error: %@", saveError);
                        }
                    }
                }
            }];
        }
    };
    
    _messageViewedObserver = [[IQNotificationCenter defaultCenter] addObserverForName:IQMessageViewedByUserNotification
                                                                                queue:nil
                                                                           usingBlock:messageViewedBlock];
}

- (void)unsubscribeFromIQNotification {
    if(_newMessageObserver) {
        [[IQNotificationCenter defaultCenter] removeObserver:_newMessageObserver];
    }
    
    if (_messageViewedObserver) {
        [[IQNotificationCenter defaultCenter] removeObserver:_messageViewedObserver];
    }
}

- (NSDateFormatter *)dateFormater {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        
        [_dateFormatter setDateFormat:@"YYYY-MM-dd'T'HH:mm:ssZZZ"];
    }
    
    return _dateFormatter;
}

- (void)clearRemovedComments {
    NSDate * lastRequestDate = [DiscussionModel lastRequestDate];
    
    [[IQService sharedService] commentIdsDeletedAfter:lastRequestDate
                                         discussionId:_discussion.discussionId
                                              handler:^(BOOL success, CommentDeletedObjects * object, NSData *responseData, NSError *error) {
                                                  if (success) {
                                                      [DiscussionModel setLastRequestDate:object.serverDate];
                                                      [self removeLocalCommentsWithIds:object.objectIds];
                                                  }
                                              }];
}

- (void)removeLocalCommentsWithIds:(NSArray*)commentIds {
    if ([commentIds count] > 0) {
        NSManagedObjectContext * context = [IQService sharedService].context;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IQComment"];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"commentId IN %@", commentIds]];
        
        [context executeFetchRequest:fetchRequest completion:^(NSArray *objects, NSError *error) {
            if ([objects count] > 0) {
                for (NSManagedObject * object in objects) {
                    [context deleteObject:object];
                }
                
                NSError * saveError = nil;
                if(![context saveToPersistentStore:&saveError] ) {
                    NSLog(@"Failed save to presistent store after comments removed");
                }
            }
        }];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller {
    [self modelWillChangeContent];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    [self modelDidChangeSectionAtIndex:sectionIndex
                         forChangeType:type];
}

- (void)controller:(NSFetchedResultsController*)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    [self modelDidChangeObject:anObject
                   atIndexPath:indexPath
                 forChangeType:type
                  newIndexPath:newIndexPath];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller {
    [self modelDidChangeContent];
}

#pragma mark - Delegate methods

- (void)modelWillChangeContent {
    if ([self.delegate respondsToSelector:@selector(modelWillChangeContent:)]) {
        [self.delegate modelWillChangeContent:self];
    }
}

- (void)modelDidChangeSectionAtIndex:(NSUInteger)sectionIndex forChangeType:(NSInteger)type {
    if ([self.delegate respondsToSelector:@selector(model:didChangeSectionAtIndex:forChangeType:)]) {
        [self.delegate model:self didChangeSectionAtIndex:sectionIndex forChangeType:type];
    }
}

- (void)modelDidChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSInteger)type newIndexPath:(NSIndexPath *)newIndexPath {
    if ([self.delegate respondsToSelector:@selector(model:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
        [self.delegate model:self didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    }
}

- (void)modelNewComment:(IQComment*)comment {
    if ([self.delegate respondsToSelector:@selector(model:newComment:)]) {
        [self.delegate model:self newComment:comment];
    }
}

- (void)modelConversationTitleDidChanged:(NSString*)newTitle {
    if ([self.delegate respondsToSelector:@selector(model:conversationTitleDidChanged:)]) {
        [self.delegate model:self conversationTitleDidChanged:newTitle];
    }
}

- (void)modelMemberDidAddWithId:(NSNumber*)userId {
    if ([self.delegate respondsToSelector:@selector(model:didAddMemberWith:)]) {
        [self.delegate model:self didAddMemberWith:userId];
    }
}

- (void)modelMemberDidRemovedWithId:(NSNumber*)userId {
    if ([self.delegate respondsToSelector:@selector(model:memberDidRemovedWithId:)]) {
        [self.delegate model:self memberDidRemovedWithId:userId];
    }
}

- (void)modelDidChangeContent {
    if ([self.delegate respondsToSelector:@selector(modelDidChangeContent:)]) {
        [self.delegate modelDidChangeContent:self];
    }
}

- (void)modelDidChanged {
    if([self.delegate respondsToSelector:@selector(modelDidChanged:)]) {
        [self.delegate modelDidChanged:self];
    }
}

- (void)modelCountersDidChanged {
    if([self.delegate respondsToSelector:@selector(modelCountersDidChanged:)]) {
        [self.delegate modelCountersDidChanged:self];
    }
}

- (void)dealloc {
    [[IQNotificationCenter defaultCenter] removeObserver:_newMessageObserver];
    [[IQNotificationCenter defaultCenter] removeObserver:_messageViewedObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
