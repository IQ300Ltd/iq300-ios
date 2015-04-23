//
//  TaskModel.m
//  IQ300
//
//  Created by Tayphoon on 14.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TaskModel.h"
#import "IQDetailsTextCell.h"
#import "IQTaskDataHolder.h"
#import "NSDate+CupertinoYankee.h"
#import "NSManagedObject+ActiveRecord.h"
#import "IQUser.h"
#import "IQSession.h"
#import "IQService+Tasks.h"
#import "IQDateDetailsCell.h"
#import "TaskExecutersCell.h"
#import "TaskCommunityCell.h"
#import "IQCommunity.h"
#import "TaskExecutor.h"

static NSString * CellReuseIdentifier = @"CellReuseIdentifier";
static NSString * DetailCellReuseIdentifier = @"DetailCellReuseIdentifier";
static NSString * DateCellReuseIdentifier = @"DateCellReuseIdentifier";
static NSString * CommunityCellReuseIdentifier = @"CommunityCellReuseIdentifier";
static NSString * ExecutorsCellReuseIdentifier = @"ExecutorsCellReuseIdentifier";

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
                          @(1) : [IQDetailsTextCell class],
                          @(2) : [TaskCommunityCell class],
                          @(3) : [TaskExecutersCell class],
                          @(4) : [IQDateDetailsCell class],
                          @(5) : [IQDateDetailsCell class]
                          };
    });
    
    Class cellClass = [_cellsClasses objectForKey:@(indexPath.row)];
    
    return (cellClass) ? cellClass :  [IQEditableTextCell class];
}

+ (NSString*)cellIdentifierForItemAtIndexPath:(NSIndexPath*)indexPath {
    static NSDictionary * _cellsIdentifiers = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _cellsIdentifiers = @{
                              @(0) : CellReuseIdentifier,
                              @(1) : DetailCellReuseIdentifier,
                              @(2) : CommunityCellReuseIdentifier,
                              @(3) : ExecutorsCellReuseIdentifier,
                              @(4) : DateCellReuseIdentifier,
                              @(5) : DateCellReuseIdentifier
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
}

- (NSUInteger)numberOfSections {
    return 1;
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    return (_isExecutersChangesEnabled) ? 5 : 6;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath * realIndexPath = [self realIndexPathForPath:indexPath];
    if(indexPath.section < [self numberOfSections] &&
       indexPath.row < [self numberOfItemsInSection:indexPath.section]) {
        NSString * field = [self fieldAtIndexPath:realIndexPath];
        if ([self.task respondsToSelector:NSSelectorFromString(field)]) {
            return [self.task valueForKey:field];
        }
    }
    return nil;
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    NSIndexPath * realIndexPath = [self realIndexPathForPath:indexPath];
    Class cellClass = [TaskModel cellClassAtIndexPath:realIndexPath];
    
    IQEditableTextCell * cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                 reuseIdentifier:[TaskModel cellIdentifierForItemAtIndexPath:realIndexPath]];
    
    return cell;
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath * realIndexPath = [self realIndexPathForPath:indexPath];
    Class cellClass = [TaskModel cellClassAtIndexPath:realIndexPath];
    
    NSString * detaiTitle = [self detailTitleForItemAtIndexPath:indexPath];
    id item = [self itemAtIndexPath:indexPath];
    if (cellClass) {
        return [cellClass heightForItem:item detailTitle:detaiTitle width:self.cellWidth];
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
                      @(4) : @"Begins",
                      @(5) : @"Perform to"};
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
                           @(3) : @"Executers",
                           @(4) : @"Begins",
                           @(5) : @"Perform to"};
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
                
                BOOL isExecutersChangesEnabled = ([[community.type lowercaseString] isEqualToString:@"defaultcommunity"]);
                if (_isExecutersChangesEnabled != isExecutersChangesEnabled) {
                    _isExecutersChangesEnabled = isExecutersChangesEnabled;
                    
                    if (_isExecutersChangesEnabled) {
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
            
            if (realIndexPath.row != 0) {
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

- (BOOL)isItemEditableAtIndexPath:(NSIndexPath*)indexPath {
    NSIndexPath * realIndexPath = [self realIndexPathForPath:indexPath];
    if (self.task.taskId != nil && realIndexPath.row == 2) {
        return NO;
    }
    return YES;
}

- (NSIndexPath*)realIndexPathForPath:(NSIndexPath*)indexPath {
    if (_isExecutersChangesEnabled) {
        if (indexPath.row > 2) {
            return [NSIndexPath indexPathForRow:indexPath.row + 1
                                      inSection:indexPath.section];
        }
    }
    return indexPath;
}

- (BOOL)modelHasChanges {
    if (_task && _initState) {
        return ![self isString:_task.title equalToString:_initState.title] ||
               ![self isString:_task.taskDescription equalToString:_initState.taskDescription] ||
               ![_task.community.communityId isEqualToNumber:_initState.community.communityId] ||
               [self executrosHasChanges] ||
               ![_task.startDate isEqualToDate:_initState.startDate] ||
               ![_task.endDate isEqualToDate:_initState.endDate];
    }
    
    return NO;
}

#pragma mark - Private methods

- (NSString*)fieldAtIndexPath:(NSIndexPath*)indexPath {
    static NSDictionary * _fields = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _fields = @{
                    @(0) : @"title",
                    @(1) : @"taskDescription",
                    @(2) : @"community",
                    @(3) : @"executors",
                    @(4) : @"startDate",
                    @(5) : @"endDate"
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

@end
