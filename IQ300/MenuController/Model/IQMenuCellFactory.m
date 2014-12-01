//
//  MCSharesCellFactory.m
//  OBI
//
//  Created by Tayphoon on 18.02.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQMenuCellFactory.h"
#import "RMenuCell.h"
#import "IQMenuItem.h"

NSString * const MenuBaseCellReuseIdentifier = @"MenuBaseCellReuseIdentifier";
NSString * const ImporatantMenuCellReuseIdentifier = @"ImporatantMenuCellReuseIdentifier";

@implementation IQMenuCellFactory

+ (NSString*)cellIdentifierForItemType:(NSInteger)type {
    static NSDictionary * _cellsIdentifiers = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _cellsIdentifiers = @{ @(IQMenuItemTypeImportant) : ImporatantMenuCellReuseIdentifier };
    });
    
    if([_cellsIdentifiers objectForKey:@(type)]) {
        return [_cellsIdentifiers objectForKey:@(type)];
    }
    
    return MenuBaseCellReuseIdentifier;
}

+ (Class)cellClassForItemType:(NSInteger)type {
    static NSDictionary * _cellsClasses = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _cellsClasses = @{ @(IQMenuItemTypeImportant) : [RMenuCell class] };
    });
    
    Class cellClass = [_cellsClasses objectForKey:@(type)];
    
    return (cellClass) ? cellClass :  [MenuCell class];
}

@end
