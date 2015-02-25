//
//  TasksMenuModel.h
//  IQ300
//
//  Created by Tayphoon on 19.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQMenuModel.h"

@interface TasksMenuModel : NSObject<IQMenuModel>

@property (nonatomic, readonly) NSString * title;
@property (nonatomic, weak)     id<IQTableModelDelegate> delegate;

- (NSString*)folderForMenuItemAtIndexPath:(NSIndexPath*)indexPath;

@end
