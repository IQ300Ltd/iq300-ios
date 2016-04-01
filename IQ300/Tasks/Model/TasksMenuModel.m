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
#import "MenuConsts.h"

static NSString * CellReuseIdentifier = @"CellReuseIdentifier";

@interface TasksMenuModel() {
    NSArray * _sections;
    NSIndexPath * _selectedItemIndexPath;
    NSDictionary * _statuses;
    NSDictionary * _folders;
}

@end

@implementation TasksMenuModel

+ (NSString*)counterPropertyNameForItemId:(NSNumber*)type {
    static NSDictionary * _counterPropertyNames = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _counterPropertyNames = @{
                                  @(1)  : @"overdue",
                                  @(3)  : @"inboxNew",
                                  @(4)  : @"inboxBrowsed",
                                  @(6)  : @"outboxCompleted",
                                  @(7)  : @"outboxRefused",
                                  @(11) : @"notApproved"
                                  };
    });
    
    return [_counterPropertyNames objectForKey:type];
}

- (id)init {
    self = [super init];
    
    if (self) {
        _statuses = @{
                      @"inbox_3" : @"new",
                      @"inbox_4" : @"browsed",
                      @"outbox_6" : @"completed",
                      @"outbox_7" : @"refused"
                      };
        
        _folders = @{
                     @(0) : @"actual",
                     @(1) : @"overdue",
                     @(2) : @"inbox",
                     @(3) : @"inbox",
                     @(4) : @"inbox",
                     @(5) : @"outbox",
                     @(6) : @"outbox",
                     @(7) : @"outbox",
                     @(8) : @"watchable",
                     @(9) : @"archive",
                     @(10) : @"templates",
                     @(11) : @"reconcilable"
                     };
        
        _selectedItemIndexPath = [NSIndexPath indexPathForRow:0
                                                    inSection:0];
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
    return MENU_ITEM_HEIGHT;
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
    NSInteger badgeValue = -1;
    IQMenuItem * item = [self itemAtIndexPath:indexPath];
    NSString * propertyName = [TasksMenuModel counterPropertyNameForItemId:item.itemId];
    if(propertyName && self.counters && [self.counters respondsToSelector:NSSelectorFromString(propertyName)]) {
        badgeValue = [[self.counters valueForKey:propertyName] integerValue];
    }
    
    return BadgTextFromInteger(badgeValue);
}

- (NSIndexPath*)indexPathForSelectedItem {
    return _selectedItemIndexPath;
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(![_selectedItemIndexPath isEqual:indexPath]) {
        _selectedItemIndexPath = indexPath;
        [self modelDidChanged];
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
    IQMenuSection *section = [_sections objectAtIndex:indexPath.section] ;
    IQMenuItem *item = [section.menuItems objectAtIndex:indexPath.row];
    return [_folders objectForKey:item.itemId];
}

- (NSIndexPath*)indexPathForItemWithFolder:(NSString*)folder {
    NSSortDescriptor * descriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    NSArray * keys = [[_folders allKeysForObject:folder] sortedArrayUsingDescriptors:@[descriptor]];
    if ([keys count] > 0) {
        return [NSIndexPath indexPathForItem:[[keys firstObject] integerValue] inSection:0];
    }
    return nil;
}

- (NSString*)statusForMenuItemAtIndexPath:(NSIndexPath*)indexPath {
    NSString * folder = [self folderForMenuItemAtIndexPath:indexPath];
    if ([folder length] > 0) {
        NSString * key = [NSString stringWithFormat:@"%@_%ld", folder, (long)indexPath.row];
        return [_statuses objectForKey:key];

    }
    
    return nil;
}

- (NSIndexPath*)indexPathForItemWithStatus:(NSString*)status folder:(NSString*)folder {
    NSArray * keys = [_statuses allKeysForObject:status];
    NSString * key = [keys lastObject];
    if ([folder length] > 0 && [key length] > 0 && [key rangeOfString:folder].location != NSNotFound) {
        NSInteger row = [[[key componentsSeparatedByString:@"_"] lastObject] integerValue];
        return [NSIndexPath indexPathForItem:row inSection:0];
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
