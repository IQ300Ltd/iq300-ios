//
//  TaskSubtasksModel.m
//  IQ300
//
//  Created by Vladislav Grigoriev on 22/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "TaskSubtasksModel.h"
#import "IQTableManagedModel+Subclass.h"
#import "IQService.h"
#import "IQService+Tasks.h"
#import "TSubtaskCell.h"

NSString *const SubtaskCellReuseIdentifier = @"SubtaskCellReuseIdentifier";

@implementation TaskSubtasksModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updatedDate" ascending:YES]];
    }
    return self;
}

- (NSString *)category {
    return @"subtasks";
}

#pragma mark - IQTableManagedModel

- (NSString*)cacheFileName {
    return @"SubtasksModelCache";
}

- (NSString*)entityName {
    return @"IQTask";
}

- (NSManagedObjectContext*)context {
    return [IQService sharedService].context;
}

- (NSPredicate*)fetchPredicate {
    NSPredicate * fetchPredicate = nil;
    if (_taskId) {
        fetchPredicate = [NSPredicate predicateWithFormat:@"parentId == %@", _taskId];

    }
    return fetchPredicate;
}

#pragma mark - IQTableModel

- (Class)cellClassForIndexPath:(NSIndexPath*)indexPath {
    return [TSubtaskCell class];
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    return SubtaskCellReuseIdentifier;
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    return [TSubtaskCell heightForItem:[self itemAtIndexPath:indexPath] andCellWidth:self.cellWidth];
}

- (void)updateModelWithCompletion:(void (^)(NSError *))completion {
    if (!_fetchController) {
        [self reloadModelSourceControllerWithCompletion:^(NSError *error) {
            [self updateModelFromServiceWithCompletion:completion];
        }];
    }
    else {
        [self updateModelFromServiceWithCompletion:completion];
    }
}

- (void)updateModelFromServiceWithCompletion:(void (^)(NSError *))completion {
    [[IQService sharedService] tasksWithParentId:_taskId handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
}




@end
