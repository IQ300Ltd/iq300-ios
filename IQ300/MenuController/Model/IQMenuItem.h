//
//  IQMenuItem.h
//  IQ300
//
//  Created by Tayphoon on 10.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, IQMenuItemType) {
    IQMenuItemTypeDefault = 0,
    IQMenuItemTypeImportant = 1,
};

@interface IQMenuItem : NSObject

@property (nonatomic, strong) NSNumber * itemId;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSNumber * type;

@end
