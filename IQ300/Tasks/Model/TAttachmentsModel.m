//
//  TAttachmentsModel.m
//  IQ300
//
//  Created by Tayphoon on 20.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/CoreData/NSManagedObjectContext+RKAdditions.h>

#import "TAttachmentsModel.h"
#import "IQTaskAttachment.h"
#import "TAttachmentCell.h"
#import "IQService+Tasks.h"

#define CACHE_FILE_NAME @"TAttachmensModelCache"

static NSString * TReuseIdentifier = @"TReuseIdentifier";

@interface TAttachmentsModel() <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController * _fetchController;
    NSArray * _sortDescriptors;
}

@end

@implementation TAttachmentsModel

- (id)init {
    self = [super init];
    if (self) {
        _sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
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
        [[IQService sharedService] attachmentsByTaskId:self.taskId
                                               handler:^(BOOL success, NSArray * attachments, NSData *responseData, NSError *error) {
                                                   if (success) {
                                                       [attachments setValue:self.taskId forKey:@"taskId"];
                                                       
                                                       if([[IQService sharedService].context hasChanges]) {
                                                           NSError *saveError = nil;
                                                           if(![[IQService sharedService].context saveToPersistentStore:&saveError] ) {
                                                               NSLog(@"Save attachments change taskId error: %@", saveError);
                                                           }
                                                       }
                                                   }
                                                   if(completion) {
                                                       completion(error);
                                                   }
                                               }];
    }
}

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion {
    [self reloadModelSourceControllerWithCompletion:completion];
    
    [[IQService sharedService] attachmentsByTaskId:self.taskId
                                           handler:^(BOOL success, NSArray * attachments, NSData *responseData, NSError *error) {
                                               if (success) {
                                                   [attachments setValue:self.taskId forKey:@"taskId"];
                                                   
                                                   if([[IQService sharedService].context hasChanges]) {
                                                       NSError *saveError = nil;
                                                       if(![[IQService sharedService].context saveToPersistentStore:&saveError] ) {
                                                           NSLog(@"Save attachments change taskId error: %@", saveError);
                                                       }
                                                   }
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
                                               handler:^(BOOL success, IQTaskAttachment * attachment, NSData *responseData, NSError *error) {
                                                   if (success) {
                                                       [attachment setTaskId:self.taskId];
                                                       
                                                       if([[IQService sharedService].context hasChanges]) {
                                                           NSError *saveError = nil;
                                                           if(![[IQService sharedService].context saveToPersistentStore:&saveError] ) {
                                                               NSLog(@"Save attachments change taskId error: %@", saveError);
                                                           }
                                                       }
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
                                                         }
                                                         else if (completion) {
                                                             completion(error);
                                                         }
                                                     }];
    }
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

#pragma mark - Private methods

- (void)reloadModelSourceControllerWithCompletion:(void (^)(NSError * error))completion {
    _fetchController.delegate = nil;
    
    [NSFetchedResultsController deleteCacheWithName:CACHE_FILE_NAME];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"taskId == %@", self.taskId];
    
    if(!_fetchController && [IQService sharedService].context) {
        NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IQTaskAttachment"];
        [fetchRequest setSortDescriptors:_sortDescriptors];
        
        _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                               managedObjectContext:[IQService sharedService].context
                                                                 sectionNameKeyPath:nil
                                                                          cacheName:CACHE_FILE_NAME];
    }
    
    NSError * fetchError = nil;
    [_fetchController.fetchRequest setPredicate:predicate];
    [_fetchController.fetchRequest setSortDescriptors:_sortDescriptors];
    [_fetchController setDelegate:self];
    [_fetchController performFetch:&fetchError];
    
    if(completion) {
        completion(fetchError);
    }
}

- (void)applicationWillEnterForeground {
    [self updateModelWithCompletion:nil];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
