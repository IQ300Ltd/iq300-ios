//
//  IQSelectionManagedModel.h
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableManagedModel+Subclass.h"
#import "IQSelectionControllerModel.h"

@interface IQSelectionManagedModel : IQTableManagedModel<IQSelectionControllerModel> {
@protected
    NSMutableArray * _selectedIndexPaths;
}

@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, assign) BOOL allowsMultipleSelection;
@property (nonatomic, assign) BOOL allowsDeselection;

- (BOOL)isItemSelectedAtIndexPath:(NSIndexPath *)indexPath;
- (void)makeItemAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected;

@end
