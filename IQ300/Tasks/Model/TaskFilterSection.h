//
//  TaskFilterSection.h
//  IQ300
//
//  Created by Tayphoon on 27.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskFilterSection : NSObject

@property (nonatomic, strong) NSString * title;
@property (nonatomic, assign, getter=isExpandable) BOOL expandable;
@property (nonatomic, assign, getter=isSortAvailable) BOOL sortAvailable;

@property (nonatomic, strong) NSArray * items;

@end
