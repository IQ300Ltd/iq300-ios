//
//  MenuModel.m
//  IQ300
//
//  Created by Tayphoon on 06.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "NotificationsMenuModel.h"
#import "MenuCell.h"
#import "IQMenuSerializator.h"
#import "IQMenuSection.h"
#import "IQMenuCellFactory.h"
#import "IQMenuItem.h"

static NSString * CellReuseIdentifier = @"CellReuseIdentifier";

@interface NotificationsMenuModel() {
    NSArray * _sections;
    NSIndexPath * _selectedItemIndexPath;
}

@end

@implementation NotificationsMenuModel

- (id)init {
    self = [super init];
    
    if (self) {
        _totalItemsCount = -1;
        _unreadItemsCount = -1;
    }
    
    return self;
}

- (NSString*)title {
    return NSLocalizedString(@"Tasks", @"Tasks");
}

- (void)setTotalItemsCount:(NSInteger)totalItemsCount {
    if(_totalItemsCount != totalItemsCount) {
        _totalItemsCount = totalItemsCount;
        [self reloadItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
}

- (void)setUnreadItemsCount:(NSInteger)unreadItemsCount {
    if(_unreadItemsCount != unreadItemsCount) {
        _unreadItemsCount = unreadItemsCount;
        [self reloadItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
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
    if (indexPath.row == 0 && _totalItemsCount != -1) {
        return [NSString stringWithFormat:@"%d", _totalItemsCount];
    }
    else if (indexPath.row == 1 && _unreadItemsCount != -1) {
        return [NSString stringWithFormat:@"%d", _unreadItemsCount];
    }
    return nil;
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
    _sections = [IQMenuSerializator serializeMenuFromList:@"notifications_menu" error:nil];
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
