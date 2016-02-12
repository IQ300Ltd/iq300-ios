//
//  UICollectionView+Updates.h
//  Tayphoon
//
//  Created by Tayphoon on 27.08.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (Updates)

- (void)beginUpdates;
- (void)endUpdates;

- (void)insertSections:(NSIndexSet *)sections animated:(BOOL)animated;
- (void)deleteSections:(NSIndexSet *)sections animated:(BOOL)animated;
- (void)reloadSections:(NSIndexSet *)sections animated:(BOOL)animated;

- (void)insertItemsAtIndexPaths:(NSArray *)indexPaths animated:(BOOL)animated;
- (void)deleteItemsAtIndexPaths:(NSArray *)indexPaths animated:(BOOL)animated;
- (void)reloadItemsAtIndexPaths:(NSArray *)indexPaths animated:(BOOL)animated;

@end
