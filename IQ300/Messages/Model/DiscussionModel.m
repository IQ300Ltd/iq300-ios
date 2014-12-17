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
#import "ObjectSerializator.h"
#import "MessagesModel.h"
#import "NSManagedObjectContext+AsyncFetch.h"

#define CACHE_FILE_NAME @"DiscussionModelcache"
#define SORT_DIRECTION IQSortDirectionDescending

static NSString * CReuseIdentifier = @"CReuseIdentifier";

@interface DiscussionModel() <NSFetchedResultsControllerDelegate> {
    NSInteger _portionLenght;
    NSArray * _sortDescriptors;
    NSFetchedResultsController * _fetchController;
    __weak id _newMessageObserver;
    __weak id _messageViewedObserver;
    NSDate * _lastViewDate;
    NSDateFormatter * _dateFormatter;
}

@end

@implementation DiscussionModel

- (id)init {
    if(self) {
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
    }
    
    return self;
}

- (void)setCompanionId:(NSNumber *)companionId {
    if(![_companionId isEqualToNumber:companionId]) {
        _companionId = companionId;
        [self updateLastViewedDate];
    }
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
    Class cellClass = [CommentCell class];
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                            reuseIdentifier:CReuseIdentifier];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    return [CommentCell heightForItem:[self itemAtIndexPath:indexPath] andCellWidth:self.cellWidth];
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

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelWithCompletion:completion];
    }
    else {
        NSInteger count = [self numberOfItemsInSection:0];
        NSInteger page = (count > 0) ? count / _portionLenght + 1 : 0;
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
    [self updateModelSourceControllerWithCompletion:nil];
    [[IQService sharedService] commentsForDiscussionWithId:_discussion.discussionId
                                                      page:@(1)
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

- (void)reloadFirstPartWithCompletion:(void (^)(NSError * error))completion {
    [[IQService sharedService] commentsForDiscussionWithId:_discussion.discussionId
                                                      page:@(1)
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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadFirstPart)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [self resubscribeToIQNotifications];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationWillEnterForegroundNotification
                                                      object:nil];
        [[IQNotificationCenter defaultCenter] removeObserver:_newMessageObserver];
        [[IQNotificationCenter defaultCenter] removeObserver:_messageViewedObserver];
    }
}

- (void)sendComment:(NSString*)comment
    attachmentAsset:(ALAsset*)asset
           fileName:(NSString*)fileName
     attachmentType:(NSString*)type
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
    
    if(asset) {
        [[IQService sharedService] createAttachmentWithAsset:asset
                                                    fileName:fileName
                                                    mimeType:type
                                                     handler:^(BOOL success, IQAttachment * attachment, NSData *responseData, NSError *error) {
                                                        if(success) {
                                                            sendCommentBlock(@[attachment]);
                                                        }
                                                        else {
                                                            [self crecreateLocalAttachmentWithAsset:asset completion:^(IQAttachment * attachment, NSError *error) {
                                                                if(attachment) {
                                                                    sendCommentBlock(@[attachment]);
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
                                             NSError * saveError = nil;
                                             item.commentStatus = @(IQCommentStatusSent);
                                             [item.managedObjectContext saveToPersistentStore:&saveError];
                                             if(saveError) {
                                                 NSLog(@"Create comment status error: %@", saveError);
                                             }
                                             if (completion) {
                                                 completion(error);
                                             }
                                         }];
    };

    IQAttachment * localAttachment = [[comment.attachments allObjects] firstObject];
    if([localAttachment.originalURL length] > 0) {
        [[IQService sharedService] createAttachmentWithFileAtPath:localAttachment.localURL
                                                         fileName:localAttachment.displayName
                                                         mimeType:localAttachment.contentType
                                                          handler:^(BOOL success, IQAttachment * attachment, NSData *responseData, NSError *error) {
                                                              if(success) {
                                                                  sendCommentBlock(@[attachment]);
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

- (void)deleteComment:(IQComment *)comment {
    NSArray * attachments = [comment.attachments allObjects];
    for (IQAttachment * attachment in attachments) {
        NSError * removeError = nil;
        if(![[NSFileManager defaultManager] removeItemAtPath:attachment.localURL error:&removeError]) {
            NSLog(@"Failed delete tmp attachment file with error: %@", removeError);
        }
    }
    
    [comment.managedObjectContext deleteObject:comment];
    
    NSError *saveError = nil;
    if(![[IQService sharedService].context saveToPersistentStore:&saveError] ) {
        NSLog(@"Save delete comment error: %@", saveError);
    }

}

#pragma mark - Private methods

- (void)updateLastViewedDate {
    if(_companionId) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId == %@", _companionId];
        CViewInfo * viewInfo = [[[_discussion.userViews filteredSetUsingPredicate:predicate] allObjects] firstObject];
        _lastViewDate = viewInfo.viewDate;
    }
}

- (void)updateDefaultStatusesForComments:(NSArray*)comments {
    NSNumber * userId = [IQSession defaultSession].userId;
    for (IQComment * comment in comments) {
        if([comment.commentStatus integerValue] != IQCommentStatusSendError) {
            BOOL isViewed = [comment.createDate compare:_lastViewDate] == NSOrderedAscending;
            IQCommentStatus status = (isViewed) ? IQCommentStatusViewed : IQCommentStatusSent;
            if([comment.commentStatus integerValue] != status && [comment.author.userId isEqualToNumber:userId]) {
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

- (void)crecreateLocalAttachmentWithAsset:(ALAsset*)asset completion:(void (^)(IQAttachment * attachment, NSError * error))completion {
    NSError * error = nil;
    NSString * diskCachePath = [self createCacheDirIfNeedWithError:&error];
    NSURL * filePath = [NSURL fileURLWithPath:[[diskCachePath stringByAppendingPathComponent:[NSString UUIDString]]
                                               stringByAppendingPathExtension:[asset.fileName pathExtension]]];
    NSManagedObjectContext * context = [IQService sharedService].context;
    NSNumber * uniqId = (!error) ? [IQAttachment uniqueLocalIdInContext:context error:&error] : nil;
    
    if (uniqId && !error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError * exportAssetError = nil;
            
            if([asset writeToFile:filePath error:&exportAssetError]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError * saveError = nil;
                    NSEntityDescription * entity = [NSEntityDescription entityForName:NSStringFromClass([IQAttachment class])
                                                               inManagedObjectContext:context];
                    
                    IQAttachment * attachment = (IQAttachment*)[[NSManagedObject alloc] initWithEntity:entity
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

- (void)updateModelSourceControllerWithCompletion:(void (^)(NSError * error))completion {
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
    [_fetchController.fetchRequest setSortDescriptors:_sortDescriptors];
    [_fetchController setDelegate:self];
    [_fetchController performFetch:&fetchError];
    
    if(completion) {
        completion(fetchError);
    }
}

- (void)reloadFirstPart {
    [self reloadFirstPartWithCompletion:^(NSError *error) {
        
    }];
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
        [[IQNotificationCenter defaultCenter] removeObserver:_newMessageObserver];
        [[IQNotificationCenter defaultCenter] removeObserver:_messageViewedObserver];
    
    __weak typeof(self) weakSelf = self;
    void (^newMessageBlock)(IQCNotification * notf) = ^(IQCNotification * notf) {
        NSDictionary * commentData = notf.userInfo[IQNotificationDataKey][@"comment"];
        NSNumber * authorId = commentData[@"author"][@"id"];
        if(authorId && ![authorId isEqualToNumber:[IQSession defaultSession].userId]) {
            NSError * serializeError = nil;
            Class commentClass = [IQComment class];
            IQComment * comment = [ObjectSerializator objectFromDictionary:@{ NSStringFromClass(commentClass) : commentData }
                                                          destinationClass:[IQComment class]
                                                        managedObjectStore:[IQService sharedService].objectManager.managedObjectStore
                                                                     error:&serializeError];
            [weakSelf modelNewComment:comment];
            [[IQService sharedService] markDiscussionAsReadedWithId:_discussion.discussionId
                                                            handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                                if(!success) {
                                                                    NSLog(@"Mark conversation as read fail with error:%@", error);
                                                                }
                                                            }];
        }
    };
    
    _newMessageObserver = [[IQNotificationCenter defaultCenter] addObserverForName:IQNewMessageNotification
                                                                       channelName:_discussion.pusherChannel
                                                                             queue:nil
                                                                        usingBlock:newMessageBlock];
    
    void (^messageViewedBlock)(IQCNotification * notf) = ^(IQCNotification * notf) {
        NSDictionary * viewData = notf.userInfo[IQNotificationDataKey][@"user_view"];
        NSNumber * userId = viewData[@"user_id"];
        
        if(userId && [_companionId isEqualToNumber:userId]) {
            NSNumber * discussionId = viewData[@"discussion_id"];
            NSString * viewedDateString = viewData[@"viewed_at"];
            NSDate * viewedDate = [[weakSelf dateFormater] dateFromString:viewedDateString];
            
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
                        if(status != [comment.commentStatus integerValue] &&
                           [comment.commentStatus integerValue] != IQCommentStatusSendError) {
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
                                                                          channelName:_discussion.pusherChannel
                                                                                queue:nil
                                                                           usingBlock:messageViewedBlock];
}

- (NSDateFormatter *)dateFormater {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        
        [_dateFormatter setDateFormat:@"YYYY-MM-dd'T'HH:mm:ssZZZ"];
    }
    
    return _dateFormatter;
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
