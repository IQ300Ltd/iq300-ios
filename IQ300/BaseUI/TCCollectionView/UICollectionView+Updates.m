//
//  UICollectionView+Updates.m
//  Tayphoon
//
//  Created by Tayphoon on 27.08.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <objc/runtime.h>

#import "UICollectionView+Updates.h"

/**
 A subclass of `NSBlockOperation` that executes each execution block serially within the calling thread context.
 */
@interface TCBlockOperation : NSBlockOperation

@end

@implementation TCBlockOperation

- (BOOL)isAsynchronous {
    return NO;
}

- (void)start {
    for (void (^executionBlock)(void) in [self executionBlocks]) {
        executionBlock();
    }
}

@end

@interface UICollectionView(UpdatesProperties)

@property (nonatomic, strong) NSBlockOperation * blockOperation;
@property (nonatomic, assign) BOOL shouldReloadCollectionView;
@property (nonatomic, assign, getter = isUpdateProcessing) BOOL updateProcessing;

@end

@implementation UICollectionView (Updates)

#pragma mark - Public methods

- (void)beginUpdates {
    if (!self.isUpdateProcessing) {
        self.updateProcessing = YES;
        self.shouldReloadCollectionView = NO;
        self.blockOperation = nil;
    }
}

- (void)endUpdates {
    if (self.isUpdateProcessing) {
        if (self) {
            if (self.window == nil || self.shouldReloadCollectionView) {
                [self reloadData];
                self.updateProcessing = NO;
            }
            else {
                [self performBatchUpdates:^{
                    [self.blockOperation start];
                } completion:^(BOOL finished) {
                    if (finished) {
                        self.blockOperation = nil;
                    }
                    self.updateProcessing = NO;
                    self.shouldReloadCollectionView = NO;
                }];
            }
        }
    }
}

- (void)insertSections:(NSIndexSet *)sections animated:(BOOL)animated {
    __weak typeof (self) weakSelf = self;
    [self.blockOperation addExecutionBlock:^{
        [weakSelf insertSections:sections];
    }];
}

- (void)deleteSections:(NSIndexSet *)sections animated:(BOOL)animated {
    __weak typeof (self) weakSelf = self;
    [self.blockOperation addExecutionBlock:^{
        [weakSelf deleteSections:sections];
    }];
}

- (void)reloadSections:(NSIndexSet *)sections animated:(BOOL)animated {
    __weak typeof (self) weakSelf = self;
    [self.blockOperation addExecutionBlock:^{
        [weakSelf reloadSections:sections];
    }];
}

- (void)insertItemsAtIndexPaths:(NSArray *)indexPaths animated:(BOOL)animated {
    if (!self.shouldReloadCollectionView) {
        if ([self shouldPerformUpdateForIndexPath:indexPaths]) {
            __weak typeof (self) weakSelf = self;
            [self.blockOperation addExecutionBlock:^{
                [weakSelf insertItemsAtIndexPaths:indexPaths];
            }];
        }
        else {
            self.shouldReloadCollectionView = YES;
        }
    }
}

- (void)deleteItemsAtIndexPaths:(NSArray *)indexPaths animated:(BOOL)animated {
    if (!self.shouldReloadCollectionView) {
        if ([self shouldPerformUpdateForIndexPath:indexPaths]) {
            __weak typeof (self) weakSelf = self;
            [self.blockOperation addExecutionBlock:^{
                [weakSelf deleteItemsAtIndexPaths:indexPaths];
            }];
        }
        else {
            self.shouldReloadCollectionView = YES;
        }
    }
}

- (void)reloadItemsAtIndexPaths:(NSArray *)indexPaths animated:(BOOL)animated {
    if (!self.shouldReloadCollectionView) {
        if ([self shouldPerformUpdateForIndexPath:indexPaths]) {
            __weak typeof (self) weakSelf = self;
            [self.blockOperation addExecutionBlock:^{
                [weakSelf reloadItemsAtIndexPaths:indexPaths];
            }];
        }
        else {
            self.shouldReloadCollectionView = YES;
        }
    }
}

- (BOOL)shouldPerformUpdateForIndexPath:(NSArray*)indexPaths {
    for (NSIndexPath * indexPath in indexPaths) {
        if (![self shouldPerformUpdateForSection:indexPath.section]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)shouldPerformUpdateForSection:(NSInteger)section {
    return ([self numberOfSections] > 0 && [self numberOfItemsInSection:section] > 0);
}

#pragma mark - Synthesize properties

/**
 * Lazily instantiate these collections.
 */

- (NSBlockOperation *)blockOperation {
    NSBlockOperation * blockOperation = objc_getAssociatedObject(self, @selector(blockOperation));
    if (blockOperation == nil) {
        blockOperation = [[TCBlockOperation alloc] init];
        objc_setAssociatedObject(self, @selector(blockOperation), blockOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return blockOperation;
}

- (void)setBlockOperation:(NSBlockOperation *)blockOperation {
    objc_setAssociatedObject(self, @selector(blockOperation), blockOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isUpdateProcessing {
    NSNumber * isUpdateProcessing = objc_getAssociatedObject(self, @selector(isUpdateProcessing));
    if (isUpdateProcessing == nil) {
        isUpdateProcessing = @(NO);
        objc_setAssociatedObject(self, @selector(isUpdateProcessing), isUpdateProcessing, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return [isUpdateProcessing boolValue];
}

- (void)setUpdateProcessing:(BOOL)updateProcessing {
    objc_setAssociatedObject(self, @selector(isUpdateProcessing), @(updateProcessing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)shouldReloadCollectionView {
    NSNumber * shouldReloadCollectionView = objc_getAssociatedObject(self, @selector(shouldReloadCollectionView));
    if (shouldReloadCollectionView == nil) {
        shouldReloadCollectionView = @(NO);
        objc_setAssociatedObject(self, @selector(shouldReloadCollectionView), shouldReloadCollectionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return [shouldReloadCollectionView boolValue];
}

- (void)setShouldReloadCollectionView:(BOOL)shouldReloadCollectionView {
    objc_setAssociatedObject(self, @selector(shouldReloadCollectionView), @(shouldReloadCollectionView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
