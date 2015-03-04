//
//  TasksMenuModel.m
//  IQ300
//
//  Created by Tayphoon on 19.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TasksMenuModel.h"
#import "MenuCell.h"
#import "IQMenuSerializator.h"
#import "IQMenuSection.h"
#import "IQMenuCellFactory.h"
#import "IQMenuItem.h"
#import "TasksMenuCounters.h"

static NSString * CellReuseIdentifier = @"CellReuseIdentifier";

@interface TasksMenuModel() {
    NSArray * _sections;
    NSIndexPath * _selectedItemIndexPath;
}

@end

@implementation TasksMenuModel

- (id)init {
    self = [super init];
    
    if (self) {
    }
    
    return self;
}

- (NSString*)title {
    return NSLocalizedString(@"Tasks", @"Tasks");
}

- (void)setCounters:(TasksMenuCounters *)counters {
    if (_counters != counters) {
        _counters = counters;
        [self modelDidChanged];
    }
}

- (NSUInteger)numberOfSections {
    return [_sections count];
}

- (NSString*)titleForSection:(NSInteger)section {
    IQMenuSection * menuSection = _sections[section];
    return menuSection.title;
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    IQMenuSection * menuSection = _sections[section];
    return [menuSection.menuItems count];
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    IQMenuItem * item = [self itemAtIndexPath:indexPath];
    return [IQMenuCellFactory cellIdentifierForItemType:[item.type integerValue]];
}

- (MenuCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    NSString * reuseIdentifier = [self reuseIdentifierForIndexPath:indexPath];
    IQMenuItem * item = [self itemAtIndexPath:indexPath];
    Class cellClass = [IQMenuCellFactory cellClassForItemType:[item.type integerValue]];
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                            reuseIdentifier:reuseIdentifier];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    return 42;
}

- (id)itemAtIndexPath:(NSIndexPath*)indexPath {
    IQMenuSection * menuSection = _sections[indexPath.section];
    return menuSection.menuItems[indexPath.row];
}

- (NSIndexPath *)indexPathOfObject:(id)object {
    return nil;
}

- (BOOL)canExpandSection:(NSInteger)section {
    IQMenuSection * menuSection = _sections[section];
    return menuSection.isExpandable;
}

- (Class)controllerClassForItemAtIndexPath:(NSIndexPath*)indexPath {
    return nil;
}

- (NSString*)badgeTextForSection:(NSInteger)section {
    return nil;
}

- (NSString*)badgeTextAtIndexPath:(NSIndexPath*)indexPath {
    NSInteger count = -1;
    NSString * propertyName = [self folderForMenuItemAtIndexPath:indexPath];
    if(propertyName && self.counters && [self.counters respondsToSelector:NSSelectorFromString(propertyName)]) {
        count = [[self.counters valueForKey:propertyName] integerValue];
    }
    
    if(count > 99.0f) {
        return @"99+";
    }
    
    return (count > 0) ? [NSString stringWithFormat:@"%ld", (long)count] : nil;
}

- (NSIndexPath*)indexPathForSelectedItem {
    return _selectedItemIndexPath;
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(_selectedItemIndexPath != indexPath) {
        _selectedItemIndexPath = indexPath;
    }
}

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion {
    _sections = [IQMenuSerializator serializeMenuFromList:@"tasks_menu" error:nil];
    if(completion) {
        completion(nil);
    }
}

- (void)clearModelData {
    _sections = nil;
}

- (void)reloadItemAtIndexPath:(NSIndexPath*)indexPath {
    [self modelWillChangeContent];
    [self modelDidChangeObject:[self itemAtIndexPath:indexPath]
                   atIndexPath:indexPath
                 forChangeType:NSFetchedResultsChangeUpdate
                  newIndexPath:nil];
    [self modelDidChangeContent];
}

- (NSString*)folderForMenuItemAtIndexPath:(NSIndexPath*)indexPath {
    static NSDictionary * _folders = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _folders = @{
                        @(0) : @"actual",
                        @(1) : @"overdue",
                        @(2) : @"inbox",
                        @(3) : @"outbox",
                        @(4) : @"watchable",
                        @(5) : @"templates",
                        @(6) : @"archive"
                        };
    });
    
    if([_folders objectForKey:@(indexPath.row)]) {
        return [_folders objectForKey:@(indexPath.row)];
    }
    
    return nil;
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
