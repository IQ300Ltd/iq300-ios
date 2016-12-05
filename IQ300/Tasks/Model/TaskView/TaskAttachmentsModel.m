//
//  TAttachmentsModel.m
//  IQ300
//
//  Created by Tayphoon on 20.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/NSManagedObjectContext+RKAdditions.h>

#import "TaskAttachmentsModel.h"
#import "IQManagedAttachment.h"
#import "TAttachmentCell.h"
#import "IQService+Tasks.h"
#import "TChangesCounter.h"
#import "IQNotificationCenter.h"
#import "IQTask.h"

#define CACHE_FILE_NAME @"TAttachmensModelCache"

static NSString * TReuseIdentifier = @"TReuseIdentifier";

@interface TaskAttachmentsModel() <NSFetchedResultsControllerDelegate> {
    __weak id _notfObserver;
    CGSize _cellSize;
}

@end

@implementation TaskAttachmentsModel

- (id)init {
    self = [super init];
    if (self) {
        self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];
        [self resubscribeToIQNotifications];
        _cellSize = CGSizeMake(85.0f, 120.0f);
    }
    return self;
}

- (NSString*)category {
    return @"documents";
}

- (NSString*)entityName {
    return @"IQManagedAttachment";
}

- (NSManagedObjectContext *)context {
    return [IQService sharedService].context;
}

- (NSPredicate*)fetchPredicate {
    return [NSPredicate predicateWithFormat:@"ANY tasks.taskId == %@", _taskId];
}

- (NSString*)reuseIdentifierForCellAtIndexPath:(NSIndexPath*)indexPath {
    return TReuseIdentifier;
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath*)indexPath constrainedToSize:(CGSize)size {
    return _cellSize;
}

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelWithCompletion:completion];
    }
    else {
        [[IQService sharedService] attachmentsByTaskId:self.taskId
                                               handler:^(BOOL success, NSArray * attachments, NSData *responseData, NSError *error) {
                                                   if(completion) {
                                                       completion(error);
                                                   }
                                               }];
    }
}

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion {
    [self reloadModelSourceControllerWithCompletion:^(NSError *error) {
        if (!error) {
            [self modelDidChanged];
        }
    }];
    [[IQService sharedService] attachmentsByTaskId:self.taskId
                                           handler:^(BOOL success, NSArray * attachments, NSData *responseData, NSError *error) {
                                               if(completion) {
                                                   completion(error);
                                               }
                                           }];
}


- (void)addAttachmentWithAsset:(ALAsset*)asset fileName:(NSString*)fileName attachmentType:(NSString*)type completion:(void (^)(NSError * error))completion {
    void (^addAttachmentBlock)(IQManagedAttachment * attachment) = ^ (IQManagedAttachment * param) {
        [[IQService sharedService] addAttachmentWithId:param.attachmentId
                                                taskId:self.taskId
                                               handler:^(BOOL success, IQManagedAttachment * attachment, NSData *responseData, NSError *error) {
                                                   if (success) {
                                                       NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IQTask"];
                                                       NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskId == %@", self.taskId];
                                                       [fetchRequest setPredicate:predicate];
                                                       [fetchRequest setFetchLimit:1];
                                                       
                                                       NSError *fetchError = nil;
                                                       NSArray *objects = [[IQService sharedService].context executeFetchRequest:fetchRequest error:&fetchError];
                                                       
                                                       NSAssert(!fetchError && objects.count == 1, @"Can't fetch task");
                                                       IQTask *task = objects.firstObject;
                                                       [task addAttachmentsObject:attachment];
                                                       
                                                       NSError *saveError = nil;
                                                       [[IQService sharedService].context saveToPersistentStore:&saveError];
                                                       
                                                       NSAssert(!saveError, @"Error on saving task");
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
                                                     handler:^(BOOL success, IQManagedAttachment * attachment, NSData *responseData, NSError *error) {
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

#pragma mark - Delegate methods


- (void)modelDidChanged {
    if([self.delegate respondsToSelector:@selector(modelDidChanged:)]) {
        [self.delegate modelDidChanged:self];
    }
}


- (void)modelCountersDidChanged {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if([self.delegate respondsToSelector:@selector(modelCountersDidChanged:)]) {
        [self.delegate performSelector:@selector(modelCountersDidChanged:) withObject:self];
    }
#pragma clang diagnostic pop
}

- (void)dealloc {
    [self unsubscribeFromIQNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
