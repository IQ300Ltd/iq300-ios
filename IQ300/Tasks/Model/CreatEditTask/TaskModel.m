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

#import "IQTextCell.h"
#import "IQTaskItems.h"

#import "IQTextCell.h"
#import "IQMultipleCellsCell.h"
#import "IQEstimatedTimeCell.h"

#ifdef IPAD
#import "IQCommunityExecutorCell.h"
#import "IQDoubleDateTextCell.h"
#import "IQComplexityEstimatedTimeDoubleCell.h"
#endif

NSString * const TaskModelTextEditAction   = @"TaskModelTextEditAction";
NSString * const TaskModelDataPickerAction = @"TaskModelDataPickerAction";
NSString * const TaskModelComplexityAction = @"TaskModelComplexityAction";
NSString * const TaskModelCommunityAction  = @"TaskModelCommunityAction";
NSString * const TaskModelExecutorsAction  = @"TaskModelExecutorsAction";

static NSString * IQTextCellReuseIdentifier = @"IQTextCellReuseIdentifier";

#define MAX_NUMBER_OF_CHARACTERS 255

@interface TaskModel() {
    BOOL _isExecutersChangesEnabled;
    IQTaskDataHolder * _initState;
    NSArray *_cellClasses;
}

@end

@implementation TaskModel

+ (Class)cellClassForItem:(id)item {
    static NSDictionary * _cellsClasses = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _cellsClasses = @{
                          NSStringFromClass([IQTaskEstimatedTimeItem class]) : [IQEstimatedTimeCell class],
                          };
    });
    
    Class cellClass = [_cellsClasses objectForKey:NSStringFromClass([item class])];
    return (cellClass) ? cellClass : [IQTextCell class];
}

+ (NSString *)reuseIdentifierForCellClass:(id)cellClass {
    if ([cellClass isKindOfClass:[NSArray class]]) {
        return [IQMultipleCellsCell reuseIdentifierForCellClasses:cellClass];
    }
    return NSStringFromClass(cellClass);
}

- (instancetype)initWithDefaultCommunity:(IQCommunity *)community {
    return [self initWithDefaultCommunity:community parentTask:nil];
}

- (instancetype)initWithDefaultCommunity:(IQCommunity *)community parentTask:(IQTask *)task {
    self = [super init];
    if (self) {
        _defaultCommunity = community;
        _task = [self createTask];
        _task.parentTask = task;
        _initState = [_task copy];
        _isExecutersChangesEnabled = (![[_task.community.type lowercaseString] isEqualToString:@"defaultcommunity"]);
        _items = [self generateItems];
        _cellClasses = [self generateCellClasses];
    }
    return self;
}

- (instancetype)initWithTask:(IQTaskDataHolder *)task {
    self = [super init];
    if (self) {
        _task = task;
        _initState = [_task copy];
        _isExecutersChangesEnabled = (![[_task.community.type lowercaseString] isEqualToString:@"defaultcommunity"]);
        _items = [self generateItems];
        _cellClasses = [self generateCellClasses];
    }
    return self;
}

- (IQTaskDataHolder*)createTask {
    NSDate * today = [NSDate date];
    IQTaskDataHolder * task = [[IQTaskDataHolder alloc] init];
    task.startDate = [today beginningOfDay];
    task.endDate = [today endOfDay];
    task.community = self.defaultCommunity;
    return task;
}

#pragma mark - Cells Factory methods

- (NSArray *)generateItems {
    NSMutableArray *mutableItems = [[NSMutableArray alloc] init];
    [mutableItems addObject:[[IQTaskTitleItem alloc] initWithTask:_task]];
    [mutableItems addObject:[[IQTaskDescriptionItem alloc] initWithTask:_task]];
    
    if (_isExecutersChangesEnabled) {
#ifdef IPAD
        [mutableItems addObject:@[[[IQTaskCommunityItem alloc] initWithTask:_task],
                                  [[IQTaskExecutorsItem alloc] initWithTask:_task],
                                  ]];
#else 
        [mutableItems addObject:[[IQTaskCommunityItem alloc] initWithTask:_task]];
        [mutableItems addObject:[[IQTaskExecutorsItem alloc] initWithTask:_task]];
#endif
    }
    else {
        [mutableItems addObject:[[IQTaskCommunityItem alloc] initWithTask:_task]];
    }
    if (_task.parentTaskId) {
        [mutableItems addObject:[[IQTaskParentAccessItem alloc] initWithTask:_task]];
    }
#ifdef IPAD
    [mutableItems addObject:@[[[IQTaskComplexityItem alloc] initWithTask:_task],
                              [[IQTaskEstimatedTimeItem alloc] initWithTask:_task]
                              ]];
    [mutableItems addObject:@[[[IQTaskStartDateItem alloc] initWithTask:_task],
                              [[IQTaskEndDateItem alloc] initWithTask:_task]
                              ]];
#else
    [mutableItems addObject:[[IQTaskComplexityItem alloc] initWithTask:_task]];
    [mutableItems addObject:[[IQTaskEstimatedTimeItem alloc] initWithTask:_task]];
    [mutableItems addObject:[[IQTaskStartDateItem alloc] initWithTask:_task]];
    [mutableItems addObject:[[IQTaskEndDateItem alloc] initWithTask:_task]];
#endif
    return [mutableItems copy];
}

- (NSArray *)generateCellClasses {
    NSMutableArray *mutableCellClasses = [[NSMutableArray alloc] initWithCapacity:[_items count]];
    for (id item in _items) {
        if ([item isKindOfClass:[NSArray class]]) {
            NSMutableArray *nestedArray = [[NSMutableArray alloc] initWithCapacity:[item count]];
            for (id nestedItem in item) {
                [nestedArray addObject:[TaskModel cellClassForItem:nestedItem]];
            }
            [mutableCellClasses addObject:[nestedArray copy]];
        }
        else {
            [mutableCellClasses addObject:[TaskModel cellClassForItem:item]];
        }
    }
    return [mutableCellClasses copy];
}

- (void)updateItems {
    for (id item in _items) {
        if ([item isKindOfClass:[NSArray class]]) {
            for (id nestedItem in item) {
                [nestedItem setTask:_task];
            }
        }
        else {
            [item setTask:_task];
        }
    }

}

#pragma mark - IQTableModel

- (void)updateModelWithCompletion:(void (^)(NSError *))completion {
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil);
        });
    }
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    id cellClass = [_cellClasses objectAtIndex:indexPath.row];
    if ([cellClass isKindOfClass:[NSArray class]]) {
        return [[IQMultipleCellsCell alloc] initWithStyle:UITableViewCellStyleSubtitle cellClassess:cellClass];
    }
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[self reuseIdentifierForIndexPath:indexPath]];
}

- (NSString *)reuseIdentifierForIndexPath:(NSIndexPath *)indexPath {
    id cellClass = [_cellClasses objectAtIndex:indexPath.row];
    return [NSString stringWithFormat:@"%@%li", [TaskModel reuseIdentifierForCellClass:cellClass], (long)indexPath.row];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    id cellClass = [_cellClasses objectAtIndex:indexPath.row];
    id item = [self itemAtIndexPath:indexPath];

    if ([cellClass isKindOfClass:[NSArray class]]) {
        return [IQMultipleCellsCell heightForItem:item cellClasses:cellClass width:self.cellWidth];
    }
    return [cellClass heightForItem:item width:self.cellWidth];
}

- (void)updateItem:(id<IQTaskItemProtocol>)item atIndexPath:(NSIndexPath *)indexPath withValue:(id)value {
    if (indexPath != nil) {
        [item updateWithTask:_task value:value];
        
        if ([item isKindOfClass:[IQTaskCommunityItem class]]) {
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
                 _items = [self generateItems];
                _cellClasses = [self generateCellClasses];
                [self modelDidChanged];
            }
            else {
                [self updateItems];
                [self modelDidChanged];
            }
        }
        else if ([item isKindOfClass:[IQTaskStartDateItem class]]) {
            [self updateItems];
            [self modelDidChanged];
        }
        else if (![item editable]) {
            [self modelWillChangeContent];
            [self modelDidChangeObject:nil
                                           atIndexPath:indexPath
                                         forChangeType:NSFetchedResultsChangeUpdate
                                          newIndexPath:nil];
            [self modelDidChangeContent];
        }
    }
}

- (NSInteger)maxNumberOfCharactersForPath:(NSIndexPath*)indexPath {
    return (indexPath.row == 0) ? MAX_NUMBER_OF_CHARACTERS : NSIntegerMax;
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
