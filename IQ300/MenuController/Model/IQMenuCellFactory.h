//
//  MCSharesCellFactory.h
//  OBI
//
//  Created by Tayphoon on 18.02.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OBIShareChain;

extern NSString * const MenuBaseCellReuseIdentifier;
extern NSString * const ImporatantMenuCellReuseIdentifier;

@interface IQMenuCellFactory : NSObject

+ (NSString*)cellIdentifierForItemType:(NSInteger)type;
+ (Class)cellClassForItemType:(NSInteger)type;

@end
