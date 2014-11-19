//
//  IQMenuModel.h
//  IQ300
//
//  Created by Tayphoon on 06.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@protocol IQMenuModel <IQTableModel>

@property (nonatomic, readonly) NSString * title;

- (BOOL)canExpandSection:(NSInteger)section;
- (Class)controllerClassForItemAtIndexPath:(NSIndexPath*)indexPath;

@end
