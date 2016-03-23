//
//  CommentsModel.m
//  IQ300
//
//  Created by Tayphoon on 24.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/CoreData/NSManagedObjectContext+RKAdditions.h>
#import <RestKit/RestKit.h>

#import "CommentsModel.h"
#import "IQService+Messages.h"
#import "CCommentCell.h"
#import "IQDiscussion.h"
#import "IQComment.h"
#import "CViewInfo.h"
#import "ALAsset+Extension.h"
#import "NSString+UUID.h"
#import "IQNotificationCenter.h"
#import "TCObjectSerializator.h"
#import "NSManagedObjectContext+AsyncFetch.h"
#import "CommentDeletedObjects.h"
#import "NotificationsModel.h"

#define CACHE_FILE_NAME @"CommentsModelcache"
#define SORT_DIRECTION IQSortDirectionDescending
#define LAST_REQUEST_DATE_KEY @"comment_ids_request_date"

static NSString * CReuseIdentifier = @"CReuseIdentifier";

@interface CommentsModel() <NSFetchedResultsControllerDelegate> {
    NSInteger _portionLenght;
    NSArray * _sortDescriptors;
    NSFetchedResultsController * _fetchController;
    NSDateFormatter * _dateFormatter;
    NSMutableDictionary * _expandedCells;
    NSMutableDictionary * _expandableCells;
    __weak id _newMessageObserver;
}

@end

@implementation CommentsModel

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
        NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
        NSSortDescriptor * idSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"commentId" ascending:NO];
        _sortDescriptors = @[descriptor, idSortDescriptor];
    }
    return self;
}

- (id)initWithDiscussion:(IQDiscussion *)discussion {
    self = [self init];
    
    if(self) {
        _discussion = discussion;
    }
    
    return self;
}

- (NSUInteger)numberOfSections {
    return [_fetchController.sections count];
}

- (NSString*)titleForSection:(NSInteger)section {
    return nil;
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [_fetchController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    return CReuseIdentifier;
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    Class cellClass = [CCommentCell class];
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                            reuseIdentifier:CReuseIdentifier];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    IQComment * comment = [self itemAtIndexPath:indexPath];
    
    if(comment && self.cellWidth > 0 && ![_expandableCells objectForKey:comment.commentId]) {
        BOOL expandable = [CCommentCell cellNeedToBeExpandableForItem:comment andCellWidth:self.cellWidth];
        [_expandableCells setObject:@(expandable) forKey:comment.commentId];
    }
    
    BOOL isExpanded = [self isItemExpandedAtIndexPath:indexPath];
    return [CCommentCell heightForItem:comment
                              expanded:isExpanded
                          andCellWidth:self.cellWidth];
}

- (id)itemAtIndexPath:(NSIndexPath*)indexPath {
    NSUInteger numberOfItems = [self numberOfItemsInSection:indexPath.section];
    NSUInteger numberOfSections = [self numberOfSections];
    if(indexPath.section < numberOfSections &&
       indexPath.row < numberOfItems) {
        return [_fetchController objectAtIndexPath:[NSIndexPath indexPathForRow:(numberOfItems - indexPath.row - 1)
                                                                      inSection:numberOfSections - indexPath.section - 1]];
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
    if(comment && isExpanded != expanded) {
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
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelWithCompletion:completion];
    }
    else {
        [self clearRemovedCommentsWithCompletion:^(BOOL success, NSData *responseData, NSError *error) {
            [[IQService sharedService] commentsForDiscussionWithId:_discussion.discussionId
                                                              page:@(1)
                                                               per:@(_portionLenght)
                                                              sort:SORT_DIRECTION
                                                           handler:^(BOOL success, NSArray * comments, NSData *responseData, NSError *error) {
                                                               if(completion) {
                                                                   completion(error);
                                                               }
                                                           }];
        }];
    }
}

- (void)loadNextPartWithCompletion:(void (^)(NSError * error, NSIndexPath *indexPath))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelWithCompletion:^(NSError *error) {
            completion(error, [_fetchController.fetchedObjects count] > 0 ? [NSIndexPath indexPathForRow:[self numberOfItemsInSection:0] inSection:0] : nil);
        }];
    }
    else {
        [self clearRemovedCommentsWithCompletion:^(BOOL success, NSData *responseData, NSError *error) {
            if (success) {
                NSInteger count = [_fetchController.fetchedObjects count];
                NSInteger page = (count > 0) ? count / _portionLenght + 1 : 1;
                [[IQService sharedService] commentsForDiscussionWithId:_discussion.discussionId
                                                                  page:@(page)
                                                                   per:@(_portionLenght)
                                                                  sort:SORT_DIRECTION
                                                               handler:^(BOOL success, NSArray * comments, NSData *responseData, NSError *error) {
                                                                   if(!error) {
                                                                       if (comments.count > 0) {
                                                                           [self loadNextPartSourceControllerWithCount:comments.count completion:^(NSError *error, NSUInteger addedSectionsCount, NSUInteger addedRows) {
                                                                               if(completion) {
                                                                                   completion(error, [NSIndexPath indexPathForRow:addedRows inSection:addedSectionsCount]);
                                                                               }
                                                                           }];
                                                                       }
                                                                       else {
                                                                           if (completion) {
                                                                               completion(error, nil);
                                                                           }
                                                                       }
                                                                      
                                                                   }
                                                                   else if(completion) {
                                                                       completion(error, nil);
                                                                   }
                                                                   
                                                               }];
            }
            else {
                if (completion) {
                    completion(error, nil);
                }
            }
        }];
    }
}

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion {
    [[IQService sharedService] commentsForDiscussionWithId:_discussion.discussionId
                                                      page:@(1)
                                                       per:@(_portionLenght)
                                                      sort:SORT_DIRECTION
                                                   handler:^(BOOL success, NSArray * comments, NSData *responseData, NSError *error) {
                                               
                                                       [self reloadModelSourceControllerWithCompletion:^(NSError *error) {
                                                           if(completion) {
                                                               completion(error);
                                                           }
                                                           [self modelDidChanged];
                                                       }];
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
        [self resubscribeToNewMessageNotification];
    }
    else {
        [self unsubscribeFromNewMessageNotification];
    }
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
                                             if (success) {
                                                 [GAIService sendEventForCategory:GAIMessagesEventCategory
                                                                           action:GAICreateMessageEventAction];
                                             }

                                             if (completion) {
                                                 completion(error);
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
                                                         else if (completion) {
                                                             completion(error);
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
                                                         else if (completion) {
                                                             completion(error);
                                                         }
                                                     }];
    }
    else {
        sendCommentBlock(nil);
    }
}

- (void)resendLocalComment:(IQComment*)comment completion:(void (^)(NSError * error))completion {
    void (^sendCommentBlock)(NSArray * attachmentIds) = ^ (NSArray * attachments) {
        NSArray * attachmentIds = [attachments valueForKey:@"attachmentId"];
        [[IQService sharedService] createComment:comment.body
                                    discussionId:comment.discussionId
                                   attachmentIds:attachmentIds
                                         handler:^(BOOL success, IQComment * item, NSData *responseData, NSError *error) {
                                             NSError * saveError = nil;
                                             item.commentStatus = @(IQCommentStatusSent);
                                             [item.managedObjectContext saveToPersistentStore:&saveError];
                                             if(saveError) {
                                                 NSLog(@"Set comment status error: %@", saveError);
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
        [attachment.managedObjectContext deleteObject:attachment];
    }
    
    [comment.managedObjectContext deleteObject:comment];
    
    NSError *saveError = nil;
    if(![[IQService sharedService].context saveToPersistentStore:&saveError] ) {
        NSLog(@"Save delete comment error: %@", saveError);
    }
    
}

- (NSIndexPath*)indexPathForCommentWithId:(NSNumber*)commentId {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"commentId == %@", commentId];
    NSArray * filteredItems = [_fetchController.fetchedObjects filteredArrayUsingPredicate:predicate];
    if([filteredItems count] > 0) {
        return [_fetchController indexPathForObject:[filteredItems lastObject]];
    }
    return nil;
}

- (void)markCommentsReadedAtIndexPaths:(NSArray *)indexPaths {
    NSMutableArray * items = [NSMutableArray array];
    for (NSIndexPath * indexPath in indexPaths) {
        IQComment * comment = [self itemAtIndexPath:indexPath];
        if ([comment.unread boolValue]) {
            [items addObject:comment];
        }
    }
    
    if ([items count] > 0) {
        [[IQService sharedService] markCommentsAsReadedWithIds:[items valueForKey:@"commentId"]
                                                  discussionId:self.discussion.discussionId
                                                       handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                           if (success) {
                                                               [items setValue:@(NO) forKey:@"unread"];
                                                               
                                                               NSManagedObjectContext * context = [IQService sharedService].context;
                                                               NSError * saveError = nil;
                                                               if(![context saveToPersistentStore:&saveError] ) {
                                                                   NSLog(@"Failed save after mark related notifications: %@", saveError);
                                                               }

                                                               [NotificationsModel markNotificationsRelatedToComments:items];
                                                           }
                                                       }];
    }
}

#pragma mark - Private methods

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

- (void)crecreateLocalAttachmentWithAsset:(ALAsset*)asset completion:(void (^)(IQManagedAttachment * attachment, NSError * error))completion {
    NSError * error = nil;
    NSString * diskCachePath = [self createCacheDirIfNeedWithError:&error];
    NSURL * filePath = [NSURL fileURLWithPath:[[diskCachePath stringByAppendingPathComponent:[NSString UUIDString]]
                                               stringByAppendingPathExtension:[asset.fileName pathExtension]]];
    NSManagedObjectContext * context = [IQService sharedService].context;
    NSNumber * uniqId = (!error) ? [IQManagedAttachment uniqueLocalIdInContext:context error:&error] : nil;
    
    if (uniqId && !error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError * exportAssetError = nil;
            
            if([asset writeToFile:filePath error:&exportAssetError]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError * saveError = nil;
                    NSEntityDescription * entity = [NSEntityDescription entityForName:NSStringFromClass([IQManagedAttachment class])
                                                               inManagedObjectContext:context];
                    
                    IQManagedAttachment * attachment = (IQManagedAttachment*)[[NSManagedObject alloc] initWithEntity:entity
                                                                        insertIntoManagedObjectContext:context];
                    
                    attachment.localId = uniqId;
                    attachment.createDate = [NSDate date];
                    attachment.displayName = [asset fileName];
                    attachment.ownerId = [IQSession defaultSession].userId;
                    attachment.contentType = [asset MIMEType];
                    attachment.originalURL = [filePath absoluteString];
                    attachment.localURL = [filePath path];
                    attachment.previewURL = [filePath absoluteString];
                    
                    if([attachment.managedObjectContext saveToPersistentStore:&saveError] ) {
                        if(completion) {
                            completion(attachment, nil);
                        }
                    }
                });
            }
            else if(completion) {
                completion(nil, error);
            }
        });
    }
    else if(completion) {
        completion(nil, error);
    }
}

- (void)reloadModelSourceControllerWithCompletion:(void (^)(NSError * error))completion {
    _fetchController.delegate = nil;
    
    [NSFetchedResultsController deleteCacheWithName:CACHE_FILE_NAME];
    
    if(!_fetchController && [IQService sharedService].context) {
        NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQComment"];
        [fetchRequest setSortDescriptors:_sortDescriptors];
        
        _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                               managedObjectContext:[IQService sharedService].context
                                                                 sectionNameKeyPath:nil
                                                                          cacheName:CACHE_FILE_NAME];
    }
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"discussionId == %@", _discussion.discussionId];
    
    NSError * fetchError = nil;
    [_fetchController.fetchRequest setPredicate:predicate];
    [_fetchController.fetchRequest setFetchLimit:_portionLenght];
    [_fetchController.fetchRequest setSortDescriptors:_sortDescriptors];
    [_fetchController setDelegate:self];
    [_fetchController performFetch:&fetchError];
    
    if(completion) {
        completion(fetchError);
    }
}

- (void)loadNextPartSourceControllerWithCount:(NSUInteger)count
                                   completion:(void (^)(NSError * error,
                                                        NSUInteger addedSectionsCount, NSUInteger addedRows))completion {
    NSError * fetchError = nil;
    NSUInteger addedSectionsCount = 0;
    NSUInteger addedRows = 0;
    if (count > 0) {
        [NSFetchedResultsController deleteCacheWithName:CACHE_FILE_NAME];
        
        NSUInteger sectionsCount = [self numberOfSections];
        NSMutableArray *sections = [[NSMutableArray alloc] initWithCapacity:sectionsCount];
        for (NSUInteger i = 0; i < sectionsCount; ++i) {
            [sections addObject:@([self numberOfItemsInSection:i])];
        }
        
        NSInteger fetchLimit = _fetchController.fetchRequest.fetchLimit;
        
        [_fetchController.fetchRequest setFetchLimit:fetchLimit + count];
        [_fetchController performFetch:&fetchError];
        if (!fetchError) {
            addedSectionsCount = [self numberOfSections] - sectionsCount;
            addedRows = [self numberOfItemsInSection:addedSectionsCount] - [[sections objectAtIndex:0] integerValue];
            [self modelDidChanged];
        }
    }
    if (completion) {
        completion(fetchError, addedSectionsCount, addedRows);
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

- (NSDateFormatter *)dateFormater {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        
        [_dateFormatter setDateFormat:@"YYYY-MM-dd'T'HH:mm:ssZZZ"];
    }
    
    return _dateFormatter;
}

- (void)resubscribeToNewMessageNotification {
    [self unsubscribeFromNewMessageNotification];
    
    __weak typeof(self) weakSelf = self;
    void (^block)(IQCNotification * notf) = ^(IQCNotification * notf) {
        NSDictionary * commentData = notf.userInfo[IQNotificationDataKey][@"comment"];
        NSNumber * authorId = commentData[@"author"][@"id"];
        NSNumber * commentId = commentData[@"id"];
        NSNumber * discussionId = commentData[@"discussion_id"];
        
        if(authorId && ![authorId isEqualToNumber:[IQSession defaultSession].userId] &&
           discussionId && [_discussion.discussionId isEqualToNumber:discussionId]) {
            
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
                    [weakSelf modelNewComment:comment];
                }
            }
        }
    };
    
    _newMessageObserver = [[IQNotificationCenter defaultCenter] addObserverForName:IQNewMessageNotification
                                                                             queue:nil
                                                                        usingBlock:block];
}

- (void)unsubscribeFromNewMessageNotification {
    if(_newMessageObserver) {
        [[IQNotificationCenter defaultCenter] removeObserver:_newMessageObserver];
    }
}

- (void)clearRemovedCommentsWithCompletion:(RequestCompletionHandler)handler{
    NSDate * lastRequestDate = [CommentsModel lastRequestDate];
    
    [[IQService sharedService] commentIdsDeletedAfter:lastRequestDate
                                         discussionId:_discussion.discussionId
                                              handler:^(BOOL success, CommentDeletedObjects * object, NSData *responseData, NSError *error) {
                                                  if (success) {
                                                      [CommentsModel setLastRequestDate:object.serverDate];
                                                      [self removeLocalCommentsWithIds:object.objectIds];
                                                  }
                                                  if (handler) {
                                                      handler(success, responseData, error);
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
        [self.delegate model:self didChangeSectionAtIndex:[self numberOfSections] - sectionIndex - (type == NSFetchedResultsChangeDelete ? 0 : 1) forChangeType:type];
    }
}

- (void)modelDidChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSInteger)type newIndexPath:(NSIndexPath *)newIndexPath {
    if ([self.delegate respondsToSelector:@selector(model:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
        
        if (indexPath) {
            NSUInteger section = [self numberOfSections] - indexPath.section - 1;
            indexPath = [NSIndexPath indexPathForRow:[self numberOfItemsInSection:section] - indexPath.row - (type == NSFetchedResultsChangeDelete ? 0 : 1) inSection:section];
        }
        
        if (newIndexPath) {
            NSUInteger section = [self numberOfSections] - newIndexPath.section - 1;
            newIndexPath = [NSIndexPath indexPathForRow:[self numberOfItemsInSection:section] - newIndexPath.row - 1 inSection:section];
        }
        
        
        [self.delegate model:self
             didChangeObject:anObject
                 atIndexPath:indexPath
               forChangeType:type
                newIndexPath:newIndexPath];
    }
}

- (void)modelNewComment:(IQComment*)comment {
    if ([self.delegate respondsToSelector:@selector(model:newComment:)]) {
        [self.delegate model:self newComment:comment];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
