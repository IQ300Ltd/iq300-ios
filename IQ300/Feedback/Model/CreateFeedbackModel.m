//
//  FeedbackModel.m
//  IQ300
//
//  Created by Tayphoon on 23.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "CreateFeedbackModel.h"
#import "IQDetailsTextCell.h"

static NSString * CellReuseIdentifier = @"CellReuseIdentifier";
static NSString * DetailCellReuseIdentifier = @"DetailCellReuseIdentifier";

@implementation CreateFeedbackModel

#pragma mark - Cells Factory methods

+ (Class)cellClassAtIndexPath:(NSIndexPath*)indexPath {
    static NSDictionary * _cellsClasses = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _cellsClasses = @{
                          @(0) : [IQDetailsTextCell class],
                          @(1) : [IQDetailsTextCell class],
                          @(2) : [IQEditableTextCell class],
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
        
    }
    return self;
}

- (NSUInteger)numberOfSections {
    return 1;
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    return 3;
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
    
}

@end
