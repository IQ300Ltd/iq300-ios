//
//  TaskModel.h
//  IQ300
//
//  Created by Tayphoon on 14.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableModel+Subclass.h"

@class IQTask;

@interface TaskModel : IQTableModel

@property (nonatomic, strong) IQTask * task;
@property (nonatomic, strong) NSArray * executers;
@property (nonatomic, strong) NSManagedObjectContext * context;
@property (nonatomic, assign) CGFloat cellWidth;

- (NSString*)placeholderForItemAtIndexPath:(NSIndexPath*)indexPath;

@end
