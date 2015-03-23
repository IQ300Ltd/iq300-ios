//
//  TAttachmentsModel.m
//  IQ300
//
//  Created by Tayphoon on 20.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TAttachmentsModel.h"
#import "IQAttachment.h"
#import "TAttachmentCell.h"
#import "IQService+Tasks.h"

static NSString * TReuseIdentifier = @"TReuseIdentifier";

@interface TAttachmentsModel() {
    NSArray * _sortDescriptors;
}

@end

@implementation TAttachmentsModel

- (id)init {
    self = [super init];
    if (self) {
        _sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];
    }
    return self;
}

- (void)setItems:(NSArray *)items {
    _items = [items sortedArrayUsingDescriptors:_sortDescriptors];
}

- (NSUInteger)numberOfSections {
    return 1;
}

- (NSString*)titleForSection:(NSInteger)section {
    return nil;
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    return (section == self.section) ? [_items count] : 0;
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
    if(indexPath.section == self.section &&
       indexPath.row < _items.count) {
        return [_items objectAtIndex:indexPath.row];
    }
    return nil;
}

- (NSIndexPath *)indexPathOfObject:(id)object {
    NSInteger index = [_items indexOfObject:object];
    if (index != NSNotFound) {
        return [NSIndexPath indexPathForRow:index inSection:self.section];
    }
    return nil;
}

- (Class)controllerClassForItemAtIndexPath:(NSIndexPath*)indexPath {
    return nil;
}

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion {

    if(completion) {
        completion(nil);
    }
}

- (void)addAttachmentWithAsset:(ALAsset*)asset fileName:(NSString*)fileName attachmentType:(NSString*)type completion:(void (^)(NSError * error))completion {
    void (^addAttachmentBlock)(IQAttachment * attachment) = ^ (IQAttachment * attachment) {
        [[IQService sharedService] addAttachmentWithId:attachment.attachmentId
                                                taskId:self.taskId
                                               handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                   if(success) {
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
                                                         }
                                                         else if (completion) {
                                                             completion(error);
                                                         }
                                                     }];
    }
}

- (void)clearModelData {
    _items = nil;
}

#pragma mark - Private methods

- (void)insertAttachment:(IQAttachment*)attachment {
    _items = [_items arrayByAddingObject:attachment];
    
    [self modelWillChangeContent];
    [self modelDidChangeObject:attachment
                   atIndexPath:nil
                 forChangeType:NSFetchedResultsChangeInsert
                  newIndexPath:[NSIndexPath indexPathForItem:[_items count] - 1 inSection:self.section]];
    [self modelDidChangeContent];
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
