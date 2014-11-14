//
//  MenuModel.m
//  IQ300
//
//  Created by Tayphoon on 06.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "MenuModel.h"
#import "MenuCell.h"
#import "IQMenuSerializator.h"
#import "IQMenuSection.h"

static NSString * CellReuseIdentifier = @"CellReuseIdentifier";

@interface MenuModel() {
    NSArray * _sections;
}

@end

@implementation MenuModel

- (id)init {
    self = [super init];
    
    if (self) {
        _sections = [IQMenuSerializator serializeMenuFromList:@"" error:nil];
    }
    
    return self;
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

- (NSString*)reuseIdentifierForSection:(NSInteger)section {
    return CellReuseIdentifier;
}

- (MenuCell*)createCellForSection:(NSInteger)section {
    return [[MenuCell alloc] initWithStyle:UITableViewCellStyleDefault
                           reuseIdentifier:[self reuseIdentifierForSection:section]];
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
}

- (void)clearModelData {
}

@end
