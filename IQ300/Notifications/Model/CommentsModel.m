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
#import "ObjectSerializator.h"
#import "MessagesModel.h"
#import "NSManagedObjectContext+AsyncFetch.h"

#define CACHE_FILE_NAME @"DiscussionModelcache"
#define SORT_DIRECTION IQSortDirectionDescending

static NSString * CReuseIdentifier = @"CReuseIdentifier";

@interface CommentsModel() <NSFetchedResultsControllerDelegate> {
    NSInteger _portionLenght;
    NSArray * _sortDescriptors;
    NSFetchedResultsController * _fetchController;
    NSDateFormatter * _dateFormatter;
}

@end

@implementation CommentsModel

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
    return [CCommentCell heightForItem:[self itemAtIndexPath:indexPath] andCellWidth:self.cellWidth];
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
                                                       if(completion) {
                                                           completion(error);
                                                       }
                                                   }];
}

- (void)reloadFirstPartWithCompletion:(void (^)(NSError * error))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self updateModelSourceControllerWithCompletion:nil];
    }
    
    [[IQService sharedService] commentsForDiscussionWithId:_discussion.discussionId
                                                      page:@(1)
                                                       per:@(_portionLenght)
                                                      sort:SORT_DIRECTION
                                                   handler:^(BOOL success, NSArray * comments, NSData *responseData, NSError *error) {
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
                                                 selector:@selector(applicationWillEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationWillEnterForegroundNotification
                                                      object:nil];
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
                                             if (completion) {
                                                 completion(error);
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
                                                         else if (completion) {
                                                             completion(error);
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

- (NSIndexPath*)indexPathForCommentWithId:(NSNumber*)commentId {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"commentId == %@", commentId];
    NSArray * filteredItems = [_fetchController.fetchedObjects filteredArrayUsingPredicate:predicate];
    if([filteredItems count] > 0) {
        return [_fetchController indexPathForObject:[filteredItems lastObject]];
    }
    return nil;
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

- (void)applicationWillEnterForeground {
    [self reloadFirstPartWithCompletion:nil];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
