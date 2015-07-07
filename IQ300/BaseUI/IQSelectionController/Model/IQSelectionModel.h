//
//  IQSelectionModel.h
//  IQ300
//
//  Created by Tayphoon on 24.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableModel+Subclass.h"
#import "IQSelectionControllerModel.h"

@interface IQSelectionModel : IQTableModel<IQSelectionControllerModel> {
    @protected
    NSMutableArray * _selectedIndexPaths;
}

@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, assign) BOOL allowsMultipleSelection;
@property (nonatomic, assign) BOOL allowsDeselection;

- (BOOL)isItemSelectedAtIndexPath:(NSIndexPath *)indexPath;
- (void)makeItemAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected;

@end
