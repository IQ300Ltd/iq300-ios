//
//  IQTableModel+Subclass.h
//  IQ300
//
//  Created by Tayphoon on 14.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableManagedModel.h"

@interface IQTableModel(Subclass)

- (void)modelWillChangeContent;

- (void)modelDidChangeSectionAtIndex:(NSUInteger)sectionIndex forChangeType:(NSInteger)type;

- (void)modelDidChangeObject:(id)anObject
                 atIndexPath:(NSIndexPath *)indexPath
               forChangeType:(NSInteger)type
                newIndexPath:(NSIndexPath *)newIndexPath;

- (void)modelDidChangeContent;

- (void)modelDidChanged;

- (void)modelCountersDidChanged;

@end