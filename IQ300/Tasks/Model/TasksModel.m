//
//  TasksModel.m
//  IQ300
//
//  Created by Tayphoon on 19.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TasksModel.h"
#import "TaskCell.h"
#import "IQTask.h"

static NSString * CellReuseIdentifier = @"CellReuseIdentifier";

#define NUMBER_OF_TASKS 15

@interface TasksModel() {
    NSMutableArray * _tasks;
}

@end

@implementation TasksModel

- (id)init {
    self = [super init];
    if(self) {
        _tasks = [NSMutableArray array];
    }
    return self;
}

- (NSUInteger)numberOfSections {
    return 1;
}

- (NSString*)titleForSection:(NSInteger)section {
    return nil;
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    return NUMBER_OF_TASKS;
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    return CellReuseIdentifier;
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    Class cellClass = [TaskCell class];
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                            reuseIdentifier:CellReuseIdentifier];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    return 109;
}

- (id)itemAtIndexPath:(NSIndexPath*)indexPath {
    return _tasks[indexPath.row];
}

- (NSIndexPath *)indexPathOfObject:(id)object {
    return nil;
}

- (Class)controllerClassForItemAtIndexPath:(NSIndexPath*)indexPath {
    return nil;
}

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion {
    [_tasks removeAllObjects];
    for (int i = 0; i < NUMBER_OF_TASKS; i++) {
        [_tasks addObject:[IQTask randomTask]];
    }
    if(completion) {
        completion(nil);
    }
}

- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion {
}

- (void)clearModelData {
}

@end
