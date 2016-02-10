//
//  TCCollectionModel.m
//  Tayphoon
//
//  Created by Tayphoon on 27.08.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TCCollectionModel.h"

@implementation TCCollectionModel

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSArray*)items {
    return _items;
}

- (NSUInteger)numberOfSections {
    return 1;
}

- (NSString*)titleForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath*)indexPath {
    return nil;
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    return [_items count];
}

- (NSString*)reuseIdentifierForCellAtIndexPath:(NSIndexPath*)indexPath {
    return nil;
}

- (NSString*)reuseIdentifierForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath*)indexPath {
    return nil;
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath*)indexPath constrainedToSize:(CGSize)size {
    return CGSizeZero;
}

- (id)itemAtIndexPath:(NSIndexPath*)indexPath {
    if(indexPath.section < [self numberOfSections] &&
       indexPath.row < [self numberOfItemsInSection:indexPath.section]) {
        return [_items objectAtIndex:indexPath.row];
    }
    return nil;
}

- (NSIndexPath*)indexPathOfObject:(id)object {
    NSInteger index = [_items indexOfObject:object];
    if (index != NSNotFound) {
        return [NSIndexPath indexPathForRow:index inSection:0];
    }
    return nil;
}

- (Class)controllerClassForItemAtIndexPath:(NSIndexPath*)indexPath {
    return nil;
}

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion {
    if (completion) {
        completion(nil);
    }
}

- (void)clearModelData {
    _items = nil;
}

#pragma mark - Private methods

#pragma mark - Delegate methods

- (void)modelWillChangeContent {
    if ([self.delegate respondsToSelector:@selector(modelWillChangeContent:)]) {
        [self.delegate modelWillChangeContent:self];
    }
}

- (void)modelDidChangeSectionAtIndex:(NSUInteger)sectionIndex forChangeType:(NSInteger)type {
    if ([self.delegate respondsToSelector:@selector(model:didChangeSectionAtIndex:forChangeType:)]) {
        [self.delegate model:self didChangeSectionAtIndex:sectionIndex forChangeType:type];
    }
}

- (void)modelDidChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSInteger)type newIndexPath:(NSIndexPath *)newIndexPath {
    if ([self.delegate respondsToSelector:@selector(model:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
        [self.delegate model:self didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    }
}

- (void)modelDidChangeContent {
    if ([self.delegate respondsToSelector:@selector(modelDidChangeContent:)]) {
        [self.delegate modelDidChangeContent:self];
    }
}

- (void)modelDidChanged {
    if([self.delegate respondsToSelector:@selector(modelDidChanged:)]) {
        [self.delegate modelDidChanged:self];
    }
}

@end
