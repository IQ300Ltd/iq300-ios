//
//  FeedbackModel.m
//  IQ300
//
//  Created by Tayphoon on 23.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "CreateFeedbackModel.h"
#import "IQDetailsTextCell.h"
#import "IQFeedback.h"
#import "IQFeedbackCategory.h"
#import "IQFeedbackType.h"
#import "IQService+Feedback.h"
#import "IQEMultiLineTextCell.h"
#import "FeedbackAttachmentsCell.h"
#import "IQManagedAttachment.h"
#import "FileStore.h"

static NSString * CellReuseIdentifier = @"CellReuseIdentifier";
static NSString * DetailCellReuseIdentifier = @"DetailCellReuseIdentifier";
static NSString * AttachmentsCellReuseIdentifier = @"AttachmentsCellReuseIdentifier";

NSString * const CreateFeedbackErrorDomain = @"com.feedback.createerror";

@interface CreateFeedbackModel() {
    IQFeedback * _feedback;
    NSMutableDictionary *_fields;
}

@end

@implementation CreateFeedbackModel

#pragma mark - Cells Factory methods

+ (Class)cellClassAtIndexPath:(NSIndexPath*)indexPath {
    static NSDictionary * _cellsClasses = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _cellsClasses = @{
                          @(0) : [IQDetailsTextCell class],
                          @(1) : [IQDetailsTextCell class],
                          @(2) : [IQEMultiLineTextCell class],
                          @(3) : [FeedbackAttachmentsCell class]
                          };
    });
    
    Class cellClass = [_cellsClasses objectForKey:@(indexPath.row)];
    
    return (cellClass) ? cellClass : [IQEditableTextCell class];
}

+ (NSString*)cellIdentifierForItemAtIndexPath:(NSIndexPath*)indexPath {
    static NSDictionary * _cellsIdentifiers = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _cellsIdentifiers = @{
                              @(0) : DetailCellReuseIdentifier,
                              @(1) : DetailCellReuseIdentifier,
                              @(2) : CellReuseIdentifier,
                              @(3) : AttachmentsCellReuseIdentifier,
                              };
    });
    
    if([_cellsIdentifiers objectForKey:@(indexPath.row)]) {
        return [_cellsIdentifiers objectForKey:@(indexPath.row)];
    }
    
    return CellReuseIdentifier;
}

#pragma mark - CreateFeedbackModel

- (id)init {
    self = [super init];
    if(self) {
        _feedback = [[IQFeedback alloc] init];
        
        _fields = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}

- (NSUInteger)numberOfSections {
    return 1;
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    return 4;
}


- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    if ([[_fields allKeys] containsObject:@(indexPath.row)]) {
        id object = [_fields objectForKey:@(indexPath.row)];
        
        if ([object isKindOfClass:[IQFeedbackType class]]) {
            return ((IQFeedbackType *)object).title;
        }
        if ([object isKindOfClass:[IQFeedbackCategory class]]) {
            return ((IQFeedbackCategory *)object).title;
        }
        
        return object;
    }
    
    return nil;
}

- (NSIndexPath *)indexPathOfObject:(id)object {
    if ([[_fields allValues] containsObject:object]) {
        return [NSIndexPath indexPathForRow:[[[_fields allKeysForObject:object] firstObject] integerValue]
                                  inSection:0];
    }
    
    return nil;
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    Class cellClass = [CreateFeedbackModel cellClassAtIndexPath:indexPath];
    
    UITableViewCell * cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleSubtitle
                                              reuseIdentifier:[CreateFeedbackModel cellIdentifierForItemAtIndexPath:indexPath]];
    
    return cell;
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    Class cellClass = [CreateFeedbackModel cellClassAtIndexPath:indexPath];
    
    id item = [self itemAtIndexPath:indexPath];
    if (cellClass) {
        NSString * detaiTitle = [self detailTitleForItemAtIndexPath:indexPath];

        if ([cellClass respondsToSelector:(@selector(heightForItem:detailTitle:width:))]) {
            return [cellClass heightForItem:item detailTitle:detaiTitle width:self.cellWidth];
        }
        
        if ([cellClass respondsToSelector:(@selector(heightForItems:cellWidth:showAddButton:))]) {
            return [cellClass heightForItems:item cellWidth:self.cellWidth showAddButton:YES];
        }
    }
    return 50.0f;
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath *)indexPath {
    return [CreateFeedbackModel cellIdentifierForItemAtIndexPath:indexPath];
}

- (NSString*)detailTitleForItemAtIndexPath:(NSIndexPath*)indexPath {
    static NSDictionary * _titlies = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _titlies = @{ @(0) : @"Feedback type",
                      @(1) : @"Feedback category",
                      @(2) : @"Description",
                      };
    });
    
    NSString * title = _titlies[@(indexPath.row)];
    return title;
}

- (NSString*)placeholderForItemAtIndexPath:(NSIndexPath*)indexPath {
    static NSDictionary * _placeholders = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _placeholders = @{ @(0) : @"Feedback type",
                           @(1) : @"Feedback category",
                           @(2) : @"Description",
                           };
    });
    
    NSString * placeholder = _placeholders[@(indexPath.row)];
    return NSLocalizedString(placeholder, nil);
}

- (void)updateFieldAtIndexPath:(NSIndexPath *)indexPath withValue:(id)value {
    if (indexPath.row < 2 || indexPath.row == 3) {
        
        if (indexPath.row == 0) {
            _feedback.feedbackType = value;
            [_fields setObject:value forKey:@(indexPath.row)];
        }
        else if (indexPath.row == 1) {
            _feedback.feedbackCategory = value;
            [_fields setObject:value forKey:@(indexPath.row)];
        }
        else {
            if ([value conformsToProtocol:@protocol(IQAttachment)]) {
                [_feedback addAttachement:value];
            }
            else if ([value isKindOfClass:[NSNumber class]]) {
                NSURL *url = [NSURL URLWithString:[_feedback attachmentAtIndex:[value unsignedIntegerValue]].localURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[FileStore sharedStore] removeDataForFileName:url.lastPathComponent];
                });
                [_feedback removeAttachementAtIndex:[value unsignedIntegerValue]];
            }
            
            [_fields setObject:_feedback.attachements forKey:@(indexPath.row)];
        }
        
        [self modelWillChangeContent];
        [self modelDidChangeObject:value
                       atIndexPath:indexPath
                     forChangeType:NSFetchedResultsChangeUpdate
                      newIndexPath:nil];
        [self modelDidChangeContent];
    }
    else {
        _feedback.feedbackDescription = value;
        
        [_fields setObject:value forKey:@(indexPath.row)];
    }
}

- (void)createFeedbackWithCompletion:(void (^)(NSError * error))completion {
    [self uploadAttachmentsWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [[IQService sharedService] createFeedback:_feedback
                                              handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                                                  if (completion) {
                                                      completion(error);
                                                  }
                                              }];
        }
        completion(error);
    }];
}

- (void)uploadAttachmentsWithCompletion:(void (^)(BOOL success, NSError *error)) completion {
    NSArray *attachments = _feedback.attachements;
    NSArray *attachmentIds = _feedback.attachmentIds;
    if (attachments.count == attachmentIds.count) {
        if (completion) {
            completion(YES, nil);
        }
    }
    else {
        id<IQAttachment> attachment = [attachments objectAtIndex:attachmentIds.count];
        __weak typeof(self) weakSelf = self;
        [[IQService sharedService] createAttachmentWithFileAtPath:[attachment localURL]
                                                         fileName:[attachment displayName]
                                                         mimeType:[attachment contentType]
                                                          handler:^(BOOL success, IQManagedAttachment *object, NSData *responseData, NSError *error) {
                                                              if (success) {
                                                                  [_feedback addAttachmentId:object.attachmentId];
                                                                  [weakSelf uploadAttachmentsWithCompletion:completion];
                                                              }
                                                              else {
                                                                  completion(NO, error);
                                                              }
                                                          }];
    }

}

- (BOOL)isAllFieldsValidWithError:(NSError**)error {
    NSError * validationError = nil;
    if (!_feedback.feedbackType) {
        NSString * errorDescription = NSLocalizedString(@"You should select feedback type", nil);
        validationError = [NSError errorWithDomain:CreateFeedbackErrorDomain
                                              code:0
                                          userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
    }
    else if (!_feedback.feedbackCategory) {
        NSString * errorDescription = NSLocalizedString(@"You should select feedback category", nil);
        validationError = [NSError errorWithDomain:CreateFeedbackErrorDomain
                                              code:0
                                          userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
    }
    else if([_feedback.feedbackDescription length] == 0) {
        NSString * errorDescription = NSLocalizedString(@"The feedback can not be empty", nil);
        validationError = [NSError errorWithDomain:CreateFeedbackErrorDomain
                                              code:0
                                          userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
    }
    
    if (error && validationError) {
        *error = validationError;
    }
    
    return !(validationError);
}

- (BOOL)modelHasChanges {
    return (_feedback.feedbackCategory != nil || _feedback.feedbackType ||
            [_feedback.feedbackDescription length] > 0 || _feedback.attachements.count > 0);
}

- (void)clearModelData {
    NSArray *attachments = _feedback.attachements;
    for (IQAttachment *attachment in attachments) {
        NSURL *url = [NSURL URLWithString:attachment.localURL];
        [[FileStore sharedStore] removeDataForFileName:url.lastPathComponent];
    }
    [super clearModelData];
}

@end
