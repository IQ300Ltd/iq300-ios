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
}

@end

@implementation NotificationsMenuModel

- (id)init {
    self = [super init];
    
    if (self) {
    }
    
    return self;
}

- (NSString*)title {
    return NSLocalizedString(@"Tasks", @"Tasks");
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

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion {
    _sections = [IQMenuSerializator serializeMenuFromList:@"notifications_menu" error:nil];
    if(completion) {
        completion(nil);
    }
}

- (void)clearModelData {
    _sections = nil;
}

@end
