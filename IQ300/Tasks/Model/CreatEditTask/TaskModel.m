//
//  TaskModel.m
//  IQ300
//
//  Created by Tayphoon on 14.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TaskModel.h"
#import "IQTaskDataHolder.h"
#import "NSDate+CupertinoYankee.h"
#import "NSManagedObject+ActiveRecord.h"
#import "IQUser.h"
#import "IQSession.h"
#import "IQService+Tasks.h"
#import "IQCommunity.h"
#import "TaskExecutor.h"

#import "IQDateDetailsCell.h"
#import "TaskExecutersCell.h"
#import "TaskCommunityCell.h"
#import "IQEMultiLineTextCell.h"

#import "TaskComplexityCell.h"
#import "TaskEstimatedTimeCell.h"

#ifdef IPAD
#import "IQCommunityExecutorCell.h"
#import "IQDoubleDateTextCell.h"
#import "IQComplexityEstimatedTimeDoubleCell.h"
#endif

static NSString * CellReuseIdentifier = @"CellReuseIdentifier";
static NSString * DetailCellReuseIdentifier = @"DetailCellReuseIdentifier";
static NSString * DoubleDetailCellReuseIdentifier = @"DoubleDetailCellReuseIdentifier";
static NSString * DoubleDateCellReuseIdentifier = @"DoubleDateCellReuseIdentifier";
static NSString * DateCellReuseIdentifier = @"DateCellReuseIdentifier";
static NSString * CommunityCellReuseIdentifier = @"CommunityCellReuseIdentifier";
static NSString * ExecutorsCellReuseIdentifier = @"ExecutorsCellReuseIdentifier";
static NSString * ComplexityCellReuseIdentifier = @"ComplexityCellReuseIdentifier";
static NSString * EstimatedTimeCellReuserIdentifier = @"EstimatedTimeCellReuserIdentifier";
static NSString * ComplexityEstimatedTimeCellReuseIdentifier =  @"ComplexityEstimatedTimeCellReuseIdentifier";

#define MAX_NUMBER_OF_CHARACTERS 255

@interface NSObject(TaskModelCells)

+ (CGFloat)heightForItem:(id)item detailTitle:(NSString*)detailTitle width:(CGFloat)width;

@end

@interface TaskModel() {
    BOOL _isExecutersChangesEnabled;
    IQTaskDataHolder * _initState;
}

@end

@implementation TaskModel

#pragma mark - Cells Factory methods

+ (Class)cellClassAtIndexPath:(NSIndexPath*)indexPath {
    static NSDictionary * _cellsClasses = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _cellsClasses = @{
                          @(0) : [IQEditableTextCell class],
#ifdef IPAD
                          @(1) : [IQEMultiLineTextCell class],
                          @(2) : [IQCommunityExecutorCell class],
                          @(3) : [IQComplexityEstimatedTimeDoubleCell class],
                          @(4) : [IQDoubleDateTextCell class],
#else
                          @(1) : [IQDetailsTextCell class],
                          @(2) : [TaskCommunityCell class],
                          @(3) : [TaskExecutersCell class],
                          @(4) : [TaskComplexityCell class],
                          @(5) : [TaskEstimatedTimeCell class],
                          @(6) : [IQDateDetailsCell class],
                          @(7) : [IQDateDetailsCell class]
#endif
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
                              @(0) : CellReuseIdentifier,
#ifdef IPAD
                              @(1) : CellReuseIdentifier,
                              @(2) : DoubleDetailCellReuseIdentifier,
                              @(3) : ComplexityEstimatedTimeCellReuseIdentifier,
                              @(4) : DoubleDateCellReuseIdentifier
#else
                              @(1) : DetailCellReuseIdentifier,
                              @(2) : CommunityCellReuseIdentifier,
                              @(3) : ExecutorsCellReuseIdentifier,
                              @(4) : ComplexityCellReuseIdentifier,
                              @(5) : EstimatedTimeCellReuserIdentifier,
                              @(6) : DateCellReuseIdentifier,
                              @(7) : DateCellReuseIdentifier
#endif
                              };
    });
    
    if([_cellsIdentifiers objectForKey:@(indexPath.row)]) {
        return [_cellsIdentifiers objectForKey:@(indexPath.row)];
    }
    
    return CellReuseIdentifier;
}

#pragma mark - TaskModel

- (id)init {
    self = [super init];
    if(self) {

    }
    return self;
}

- (void)setTask:(IQTaskDataHolder *)task {
    _task = task;
    _initState = [_task copy];
    _isExecutersChangesEnabled = (![[_task.community.type lowercaseString] isEqualToString:@"defaultcommunity"]);
}

- (NSUInteger)numberOfSections {
    return 1;
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
#ifdef IPAD
    return 5;
#else
    return (_isExecutersChangesEnabled) ? 8 : 7;
#endif
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath * realIndexPath = [self realIndexPathForPath:indexPath];
    NSUInteger numberOfSections = [self numberOfSections];
    NSUInteger numberOfRows = (!IS_IPAD) ? [self numberOfItemsInSection:indexPath.section] : 8;
    
    if(indexPath.section < numberOfSections && indexPath.row < numberOfRows) {
        return [self fieldValueAtIndexPath:realIndexPath];
    }
    return nil;
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {    
    NSIndexPath * realIndexPath = [self realIndexPathForPath:indexPath];

    Class cellClass = [TaskModel cellClassAtIndexPath:realIndexPath];
    
    UITableViewCell * cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleSubtitle
                                              reuseIdentifier:[TaskModel cellIdentifierForItemAtIndexPath:realIndexPath]];
    
    return cell;
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath * realIndexPath = [self realIndexPathForPath:indexPath];
    Class cellClass = [TaskModel cellClassAtIndexPath:realIndexPath];
    
    NSString * detaiTitle = [self detailTitleForItemAtIndexPath:indexPath];
    id item = [self itemAtIndexPath:indexPath];
    if ([cellClass respondsToSelector:@selector(heightForItem:detailTitle:width:)]) {
        return [cellClass heightForItem:item detailTitle:detaiTitle width:self.cellWidth];
    }
    else if ([cellClass respondsToSelector:@selector(heightForComplexity:estimatedTime:widht:)]) {
        return [cellClass heightForComplexity:_task.complexity estimatedTime:_task.estimatedTimeSeconds widht:self.cellWidth];
    }
    return 50.0f;
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath * realIndexPath = [self realIndexPathForPath:indexPath];
    return [TaskModel cellIdentifierForItemAtIndexPath:realIndexPath];
}

- (NSString*)detailTitleForItemAtIndexPath:(NSIndexPath*)indexPath {
    NSIndexPath * realIndexPath = [self realIndexPathForPath:indexPath];
   static NSDictionary * _titlies = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _titlies = @{ @(0) : @"Title",
                      @(1) : @"Description",
                      @(2) : @"Community",
                      @(3) : @"Performers",
                      @(4) : @"Complexity",
                      @(5) : @"Estimated time",
                      @(6) : @"Begins",
                      @(7) : @"Perform to"};
    });
    
    NSString * title = _titlies[@(realIndexPath.row)];
    return title;
}

- (NSString*)placeholderForItemAtIndexPath:(NSIndexPath*)indexPath {
    NSIndexPath * realIndexPath = [self realIndexPathForPath:indexPath];
    static NSDictionary * _placeholders = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _placeholders = @{ @(0) : @"Title",
                           @(1) : @"Description",
                           @(2) : @"Community",
                           @(3) : @"Executors",
                           @(4) : @"Normal",
                           @(5) : @"0:00",
                           @(6) : @"Begins",
                           @(7) : @"Perform to"};
    });
    
    NSString * placeholder = _placeholders[@(realIndexPath.row)];
    return NSLocalizedString(placeholder, nil);
}

- (void)updateModelWithCompletion:(void (^)(NSError *))completion {
    NSError * error = nil;

    if (self.task == nil) {
        self.task = [self createTask];
    }
    
    if (completion) {
        completion(error);
    }
}

- (void)updateFieldAtIndexPath:(NSIndexPath*)indexPath withValue:(id)value {
    if (indexPath != nil) {
        NSIndexPath * realIndexPath = [self realIndexPathForPath:indexPath];
        NSString * field = [self fieldAtIndexPath:realIndexPath];
        if ([self.task respondsToSelector:NSSelectorFromString(field)]) {
            [self.task setValue:value forKey:field];
            
            if (realIndexPath.row == 2) {
                IQCommunity * community = value;
                
                self.task.executors = nil;
                
                BOOL isExecutersChangesEnabled = (![[community.type lowercaseString] isEqualToString:@"defaultcommunity"]);
                if (_isExecutersChangesEnabled != isExecutersChangesEnabled) {
                    _isExecutersChangesEnabled = isExecutersChangesEnabled;
                    
                    if (!_isExecutersChangesEnabled) {
                        IQUser * user = [IQUser userWithId:[IQSession defaultSession].userId
                                                 inContext:[IQService sharedService].context];
                        TaskExecutor * executor = [[TaskExecutor alloc] init];
                        executor.executorId = user.userId;
                        executor.executorName = user.displayName;
                        self.task.executors = @[executor];
                    }

                    [self modelDidChanged];
                }
            }
            
#ifdef IPAD
            if (realIndexPath.row > 1 && realIndexPath.row != 5) {
#else
            if (realIndexPath.row != 0 && realIndexPath.row != 5) {
#endif
                [self modelWillChangeContent];
                [self modelDidChangeObject:nil
                               atIndexPath:indexPath
                             forChangeType:NSFetchedResultsChangeUpdate
                              newIndexPath:nil];
                [self modelDidChangeContent];
            }
        }
    }
}

- (BOOL)isItemEnabledAtIndexPath:(NSIndexPath*)indexPath {
    NSIndexPath * realIndexPath = [self realIndexPathForPath:indexPath];
    if (self.task.taskId != nil && realIndexPath.row == 2) {
        return NO;
    }
#ifdef IPAD
    else if(realIndexPath.row == 3) {
        return _isExecutersChangesEnabled;
    }
#endif
    return YES;
}

- (NSIndexPath*)realIndexPathForPath:(NSIndexPath*)indexPath {
#ifndef IPAD
    if (!_isExecutersChangesEnabled) {
        if (indexPath.row > 2) {
            return [NSIndexPath indexPathForRow:indexPath.row + 1
                                      inSection:indexPath.section];
        }
    }
#endif
    return indexPath;
}

- (NSInteger)maxNumberOfCharactersForPath:(NSIndexPath*)indexPath {
    NSIndexPath * realIndexPath = [self realIndexPathForPath:indexPath];
    return (realIndexPath.row == 0) ? MAX_NUMBER_OF_CHARACTERS : NSIntegerMax;
}

- (BOOL)modelHasChanges {
    if (_task && _initState) {
        return ![self isString:_task.title equalToString:_initState.title] ||
               ![self isString:_task.taskDescription equalToString:_initState.taskDescription] ||
               ![self isNumber:_task.community.communityId equalToNumber:_initState.community.communityId] ||
               [self executrosHasChanges] ||
               ![_task.startDate isEqualToDate:_initState.startDate] ||
               ![_task.endDate isEqualToDate:_initState.endDate];
    }
    
    return NO;
}

#pragma mark - Private methods
    
- (id)fieldValueAtIndexPath:(NSIndexPath*)indexPath {
    NSString * field = [self fieldAtIndexPath:indexPath];
    if ([self.task respondsToSelector:NSSelectorFromString(field)]) {
        return [self.task valueForKey:field];
    }
    return nil;
}

- (NSString*)fieldAtIndexPath:(NSIndexPath*)indexPath {
    static NSDictionary * _fields = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _fields = @{
                    @(0) : @"title",
                    @(1) : @"taskDescription",
                    @(2) : @"community",
                    @(3) : @"executors",
                    @(4) : @"complexity",
                    @(5) : @"estimatedTimeSeconds",
                    @(6) : @"startDate",
                    @(7) : @"endDate"
                    };
    });
    
    if([_fields objectForKey:@(indexPath.row)]) {
        return _fields[@(indexPath.row)];
    }
    return nil;
}

- (IQTaskDataHolder*)createTask {
    NSDate * today = [NSDate date];
    IQTaskDataHolder * task = [[IQTaskDataHolder alloc] init];
    task.startDate = [today beginningOfDay];
    task.endDate = [today endOfDay];
    task.community = self.defaultCommunity;
    return task;
}

- (BOOL)executrosHasChanges {
    BOOL selectionIsEmpty = (_task.executors == nil && _initState.executors == nil);
    return  [_task.executors count] != [_initState.executors count] ||
            (!selectionIsEmpty && ![_task.executors isEqualToArray:_initState.executors]);
}

- (BOOL)isString:(NSString*)firstString equalToString:(NSString*)secondString {
    BOOL stringsIsEmpty = (firstString == nil && secondString == nil);
    return stringsIsEmpty || (!stringsIsEmpty && [firstString isEqualToString:secondString]);
}

- (BOOL)isNumber:(NSNumber*)firstNumber equalToNumber:(NSNumber*)secondNumber {
    BOOL numberIsEmpty = (firstNumber == nil && secondNumber == nil);
    return numberIsEmpty || (!numberIsEmpty && secondNumber != nil && [firstNumber isEqualToNumber:secondNumber]);
}

@end
