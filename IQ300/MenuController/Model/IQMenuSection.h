//
//  IQMenuSection.h
//  IQ300
//
//  Created by Tayphoon on 10.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IQMenuItem;

@interface IQMenuSection : NSObject

@property (nonatomic, strong) NSNumber * sectionId;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, assign, setter = setExpandable:) BOOL isExpandable;

@property (nonatomic, readonly) NSArray * menuItems;

- (void)addItem:(IQMenuItem*)item;
- (void)removeItem:(IQMenuItem*)item;

@end
