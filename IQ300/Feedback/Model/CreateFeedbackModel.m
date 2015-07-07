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

static NSString * CellReuseIdentifier = @"CellReuseIdentifier";
static NSString * DetailCellReuseIdentifier = @"DetailCellReuseIdentifier";
NSString * const CreateFeedbackErrorDomain = @"com.feedback.createerror";

@interface CreateFeedbackModel() {
    IQFeedback * _feedback;
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
    }
    return self;
}

- (NSUInteger)numberOfSections {
    return 1;
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return _feedback.feedbackType.title;
    }
    else if(indexPath.row == 1) {
        return _feedback.feedbackCategory.title;
    }
    else {
       return _feedback.feedbackDescription;
    }
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    Class cellClass = [CreateFeedbackModel cellClassAtIndexPath:indexPath];
    
    UITableViewCell * cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleSubtitle
                                              reuseIdentifier:[CreateFeedbackModel cellIdentifierForItemAtIndexPath:indexPath]];
    
    return cell;
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    Class cellClass = [CreateFeedbackModel cellClassAtIndexPath:indexPath];
    
    NSString * detaiTitle = [self detailTitleForItemAtIndexPath:indexPath];
    id item = [self itemAtIndexPath:indexPath];
    if (cellClass) {
        return [cellClass heightForItem:item detailTitle:detaiTitle width:self.cellWidth];
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
    if (indexPath.row < 2) {
        
        if (indexPath.row == 0) {
            _feedback.feedbackType = value;
        }
        else {
            _feedback.feedbackCategory = value;
        }
        
        [self modelWillChangeContent];
        [self modelDidChangeObject:nil
                       atIndexPath:indexPath
                     forChangeType:NSFetchedResultsChangeUpdate
                      newIndexPath:nil];
        [self modelDidChangeContent];
    }
    else {
        _feedback.feedbackDescription = value;
    }
}

- (void)createFeedbackWithCompletion:(void (^)(NSError * error))completion {
    [[IQService sharedService] createFeedback:_feedback
                                      handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                                          if (completion) {
                                              completion(error);
                                          }
                                      }];
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
            [_feedback.feedbackDescription length] > 0);
}

@end
