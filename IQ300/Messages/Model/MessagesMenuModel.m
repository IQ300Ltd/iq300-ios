//
//  MessagesMenuModel.m
//  IQ300
//
//  Created by Vladislav Grigoriev on 20/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "MessagesMenuModel.h"
#import "IQMenuSerializator.h"
#import "IQMenuSection.h"
#import "IQMenuCellFactory.h"
#import "IQMenuItem.h"
#import "MenuCell.h"
#import "MenuConsts.h"
#import "IQCounters.h"

@interface MessagesMenuModel () {
    NSArray *_sections;
    NSIndexPath *_selectedIndexPath;
}

@end

@implementation MessagesMenuModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _selectedIndexPath = [NSIndexPath indexPathForRow:0
                                                    inSection:0];
    }
    return self;
}

#pragma mark - IQMenuModel

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
    if (indexPath.row == 1 && _unreadCount.integerValue > 0) {
        return _unreadCount.stringValue;
    }
    return nil;
}

- (NSIndexPath*)indexPathForSelectedItem {
    return _selectedIndexPath;
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![_selectedIndexPath isEqual:indexPath]) {
        _selectedIndexPath = indexPath;
        [self modelDidChanged];
    }
}

#pragma mark - IQTableModel

- (NSUInteger)numberOfSections {
    return [_sections count];
}

- (NSString*)titleForSection:(NSInteger)section {
    IQMenuSection *menuSection = [_sections objectAtIndex:section];
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

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion {
    _sections = [IQMenuSerializator serializeMenuFromList:@"messages_menu" error:nil];
    if (completion) {
        completion(nil);
    }
}

- (void)clearModelData {
    _sections = nil;
}

- (void)setUnreadCount:(NSNumber *)unreadCount {
    if (![_unreadCount isEqual:unreadCount]) {
        _unreadCount = unreadCount;
        [self modelDidChanged];
    }
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
