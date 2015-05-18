//
//  TAttachmentsModel.m
//  IQ300
//
//  Created by Tayphoon on 20.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/CoreData/NSManagedObjectContext+RKAdditions.h>

#import "TaskAttachmentsModel.h"
#import "IQAttachment.h"
#import "TAttachmentCell.h"
#import "IQService+Tasks.h"
#import "TChangesCounter.h"
#import "IQNotificationCenter.h"

#define CACHE_FILE_NAME @"TAttachmensModelCache"

static NSString * TReuseIdentifier = @"TReuseIdentifier";

@interface TaskAttachmentsModel() <NSFetchedResultsControllerDelegate> {
    NSArray * _sortDescriptors;
    NSArray * _attachments;
    __weak id _notfObserver;
}

@end

@implementation TaskAttachmentsModel

- (id)init {
    self = [super init];
    if (self) {
        _attachments = [NSMutableArray array];
        _sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];
        
        [self resubscribeToIQNotifications];
    }
    return self;
}

- (NSString*)category {
    return @"documents";
}

- (NSUInteger)numberOfSections {
    return 1;
}

- (NSString*)titleForSection:(NSInteger)section {
    return nil;
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    return [_attachments count];
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    return TReuseIdentifier;
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    Class cellClass = [TAttachmentCell class];
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleSubtitle
                            reuseIdentifier:TReuseIdentifier];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    return 50.0f;
}

- (id)itemAtIndexPath:(NSIndexPath*)indexPath {
    if(indexPath.section < [self numberOfSections] &&
       indexPath.row < [self numberOfItemsInSection:indexPath.section]) {
        return [_attachments objectAtIndex:indexPath.row];
    }
    return nil;
}

- (NSIndexPath *)indexPathOfObject:(id)object {
    NSInteger index = [_attachments indexOfObject:object];
    if (index != NSNotFound) {
        return [NSIndexPath indexPathForRow:index inSection:self.section];
    }
    return nil;
}

- (Class)controllerClassForItemAtIndexPath:(NSIndexPath*)indexPath {
    return nil;
}

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion {
    [[IQService sharedService] attachmentsByTaskId:self.taskId
                                           handler:^(BOOL success, NSArray * attachments, NSData *responseData, NSError *error) {
                                               if (success) {
                                                   [self mergeChangesFromArray:attachments];
                                               }
                                               if(completion) {
                                                   completion(error);
                                               }
                                           }];
}

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion {
    _attachments = nil;
    
    [[IQService sharedService] attachmentsByTaskId:self.taskId
                                           handler:^(BOOL success, NSArray * attachments, NSData *responseData, NSError *error) {
                                               if (success) {
                                                   [self mergeChangesFromArray:attachments];
                                               }
                                               if(completion) {
                                                   completion(error);
                                               }
                                           }];
}

- (void)addAttachmentWithAsset:(ALAsset*)asset fileName:(NSString*)fileName attachmentType:(NSString*)type completion:(void (^)(NSError * error))completion {
    void (^addAttachmentBlock)(IQAttachment * attachment) = ^ (IQAttachment * param) {
        [[IQService sharedService] addAttachmentWithId:param.attachmentId
                                                taskId:self.taskId
                                               handler:^(BOOL success, IQAttachment * attachment, NSData *responseData, NSError *error) {
                                                   if (success && attachment) {
                                                       [self insertAttachment:attachment];
                                                   }
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
                                                             addAttachmentBlock(attachment);
                                                             [GAIService sendEventForCategory:GAICommonEventCategory
                                                                                       action:GAIFileUploadEventAction];
                                                         }
                                                         else if (completion) {
                                                             completion(error);
                                                         }
                                                     }];
    }
}

- (void)resetReadFlagWithCompletion:(void (^)(NSError * error))completion {
    [[IQService sharedService] markCategoryAsReaded:self.category
                                             taskId:self.taskId
                                            handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                if (success) {
                                                    self.unreadCount = @(0);
                                                    [self modelCountersDidChanged];
                                                }
                                                if(completion) {
                                                    completion(error);
                                                }
                                            }];
}

- (void)clearModelData {
    _attachments = nil;
}

#pragma mark - Private methods

- (void)updateCountersWithCompletion:(void (^)(TChangesCounter * counters, NSError * error))completion {
    [[IQService sharedService] taskChangesCounterById:self.taskId
                                              handler:^(BOOL success, TChangesCounter * counter, NSData *responseData, NSError *error) {
                                                  if(success) {
                                                      self.unreadCount = counter.documents;
                                                      [self modelCountersDidChanged];
                                                  }
                                                  if(completion) {
                                                      completion(counter, error);
                                                  }
                                              }];
}

- (void)mergeChangesFromArray:(NSArray*)attachments {
    NSMutableArray * insertPaths = [NSMutableArray array];
    NSMutableArray * deletePaths = [NSMutableArray array];

    NSArray * newState = [attachments sortedArrayUsingDescriptors:_sortDescriptors];
    
    NSArray * oldAttachmentIds = [_attachments valueForKey:@"attachmentId"];
    NSArray * newAttachmentIds = [newState valueForKey:@"attachmentId"];
    NSArray * insertObjects = [newState filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (attachmentId IN %@)", oldAttachmentIds]];
    NSArray * deleteObjects = [_attachments filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (attachmentId IN %@)", newAttachmentIds]];
    
    for (id object in insertObjects) {
        NSInteger index = [newState indexOfObject:object];
        if (index != NSNotFound) {
            [insertPaths addObject:[NSIndexPath indexPathForRow:index inSection:self.section]];
        }
    }
    
    for (id object in deleteObjects) {
        NSInteger index = [_attachments indexOfObject:object];
        if (index != NSNotFound) {
            [deletePaths addObject:[NSIndexPath indexPathForRow:index inSection:self.section]];
        }
    }
    
    _attachments = newState;
    
    if ([insertObjects count] > 0 || [deleteObjects count] > 0) {
        [self modelWillChangeContent];
        
        for (NSIndexPath * indexPath in deletePaths) {
            [self modelDidChangeObject:nil
                           atIndexPath:indexPath
                         forChangeType:NSFetchedResultsChangeDelete
                          newIndexPath:nil];
        }
        
        for (NSIndexPath * indexPath in insertPaths) {
            [self modelDidChangeObject:nil
                           atIndexPath:nil
                         forChangeType:NSFetchedResultsChangeInsert
                          newIndexPath:indexPath];
            
        }
        
        [self modelDidChangeContent];
    }
}

- (void)insertAttachment:(IQAttachment*)attachment {
    _attachments = [_attachments arrayByAddingObject:attachment];
    _attachments = [_attachments sortedArrayUsingDescriptors:_sortDescriptors];
    
    [self modelWillChangeContent];
    [self modelDidChangeObject:attachment
                   atIndexPath:nil
                 forChangeType:NSFetchedResultsChangeInsert
                  newIndexPath:[self indexPathOfObject:attachment]];
    [self modelDidChangeContent];
}

- (void)resubscribeToIQNotifications {
    [self unsubscribeFromIQNotifications];
    
    __weak typeof(self) weakSelf = self;
    void (^block)(IQCNotification * notf) = ^(IQCNotification * notf) {
        NSArray * tasks = notf.userInfo[IQNotificationDataKey];
        NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"task_id == %@", weakSelf.taskId];
        NSDictionary * curTask = [[tasks filteredArrayUsingPredicate:filterPredicate] lastObject];

        if(curTask) {
            [weakSelf updateModelWithCompletion:nil];
            
            NSNumber * count = curTask[@"counter"];
            if(![weakSelf.unreadCount isEqualToNumber:count]) {
                if (weakSelf.resetReadFlagAutomatically) {
                    [weakSelf resetReadFlagWithCompletion:nil];
                }
                else {
                    weakSelf.unreadCount = count;
                    [weakSelf modelCountersDidChanged];
                }
            }
        }
    };
    _notfObserver = [[IQNotificationCenter defaultCenter] addObserverForName:IQTaskAttachmentsDidChangedNotification
                                                                       queue:nil
                                                                  usingBlock:block];
}

- (void)unsubscribeFromIQNotifications {
    if(_notfObserver) {
        [[IQNotificationCenter defaultCenter] removeObserver:_notfObserver];
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
    [self unsubscribeFromIQNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
