//
//  TasksFilterModel.m
//  IQ300
//
//  Created by Tayphoon on 26.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TasksFilterModel.h"
#import "TaskFilterCell.h"

static NSString * CellReuseIdentifier = @"CellReuseIdentifier";

@interface TasksFilterModel () {
    NSArray * _sections;
    NSMutableArray * _selectedItems;
}

@end

@implementation TasksFilterModel

- (id)init {
    self = [super init];
    
    if (self) {
        _selectedItems = [NSMutableArray array];
    }
    
    return self;
}

- (NSUInteger)numberOfSections {
    return 3;
}

- (NSString*)titleForSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%ld", (long)section];
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    return CellReuseIdentifier;
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    Class cellClass = [TaskFilterCell class];
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                            reuseIdentifier:CellReuseIdentifier];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    return 42;
}

- (id)itemAtIndexPath:(NSIndexPath*)indexPath {
    return nil;
}

- (NSIndexPath *)indexPathOfObject:(id)object {
    return nil;
}

- (BOOL)canExpandSection:(NSInteger)section {
    return YES;
}

- (Class)controllerClassForItemAtIndexPath:(NSIndexPath*)indexPath {
    return nil;
}


- (BOOL)isItemSellectedAtIndexPath:(NSIndexPath *)indexPath {
    return [_selectedItems containsObject:indexPath];
}

- (void)makeItemAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected {
    if (selected && ![_selectedItems containsObject:indexPath]) {
        [_selectedItems addObject:indexPath];
    }
    else if(!selected && [_selectedItems containsObject:indexPath]) {
        [_selectedItems removeObject:indexPath];
    }
}

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion {
    if(completion) {
        completion(nil);
    }
}

- (void)clearModelData {
}

- (void)reloadItemAtIndexPath:(NSIndexPath*)indexPath {
    [self modelWillChangeContent];
    [self modelDidChangeObject:[self itemAtIndexPath:indexPath]
                   atIndexPath:indexPath
                 forChangeType:NSFetchedResultsChangeUpdate
                  newIndexPath:nil];
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

@end
