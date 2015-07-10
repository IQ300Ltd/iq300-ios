//
//  IQSelectionManagedModel.m
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQSelectionManagedModel.h"
#import "IQSelectableTextCell.h"

@implementation IQSelectionManagedModel

- (id)init {
    self = [super init];
    if (self) {
        _selectedIndexPaths = [[NSMutableArray alloc] init];
    }
    return self;
}

- (Class)cellClass {
    return [IQSelectableTextCell class];
}

- (BOOL)isItemSelectedAtIndexPath:(NSIndexPath *)indexPath {
    return [_selectedIndexPaths containsObject:indexPath];
}

- (void)makeItemAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected {
    if (self.allowsMultipleSelection) {
        if (selected && ![_selectedIndexPaths containsObject:indexPath]) {
            [_selectedIndexPaths addObject:indexPath];
        }
        else if(!selected && [_selectedIndexPaths containsObject:indexPath]) {
            [_selectedIndexPaths removeObject:indexPath];
        }
    }
    else {
        [_selectedIndexPaths removeAllObjects];
        if (selected) {
            [_selectedIndexPaths addObject:indexPath];
        }
    }
}

- (NSIndexPath*)selectedIndexPathForSection:(NSInteger)section {
    return [[_selectedIndexPaths filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"section == %d", section]] firstObject];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self itemAtIndexPath:indexPath];
    return [IQSelectableTextCell heightForItem:item detailTitle:nil width:self.cellWidth];
}

- (NSArray*)selectedItems {
    if ([_selectedIndexPaths count] > 0) {
        NSMutableArray * items = [NSMutableArray array];
        for (NSIndexPath * indexPath in _selectedIndexPaths) {
            id item = [self itemAtIndexPath:indexPath];
            if (item) {
                [items addObject:item];
            }
        }
        return [items copy];
    }
    return nil;
}

@end
