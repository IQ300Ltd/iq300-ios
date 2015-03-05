//
//  ExpandableTableView.m
//  IQ300
//
//  Created by Tayphoon on 06.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "ExpandableTableView.h"

@interface ExpandableTableView() {
    id<ExpandableTableViewDataSource> _targetDataSource;
    id<ExpandableTableViewDelegate> _targetDelegate;
    NSMutableIndexSet * _expandedSections;
    BOOL _isDrawingComplete;
}

@end

@implementation ExpandableTableView

- (id)init {
    self = [super init];
    
    if (self) {
        _expandedSections = [[NSMutableIndexSet alloc] init];
        _isDrawingComplete = NO;
    }
    
    return self;
}

#pragma mark - Public methods

- (NSIndexSet*)expandedSections {
    return [_expandedSections copy];
}

- (void)setDataSource:(id<ExpandableTableViewDataSource>)dataSource {
    _targetDataSource = dataSource;
    [super setDataSource:(_targetDataSource) ? self : nil];
}

- (void)expandSection:(NSInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    BOOL isSectionExpanded = [_expandedSections containsIndex:section];
    if([self canExpandSection:section] && !isSectionExpanded) {
        [_expandedSections addIndex:section];
        
        NSInteger numberOfRows = [_targetDataSource tableView:self numberOfRowsInSection:section];
      
        if(_isDrawingComplete && numberOfRows > 0) {
            BOOL animated = (animation != UITableViewRowAnimationNone);
            [self willExpandSection:section animated:animated];
            
            if(animated) {
                NSArray * indexPaths = [self indexPathsForSection:section numberOfRows:numberOfRows];
                [self beginUpdates];
                [self insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
                [self endUpdates];
                
                void(^completionBlock)(void) = ^{
                    [self didExpandSection:section animated:animated];
                };

                [CATransaction setCompletionBlock:completionBlock];
            }
            else {
                [self reloadData];
            }
        }
    }
}

- (void)collapseSection:(NSInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    BOOL isSectionExpanded = [_expandedSections containsIndex:section];
    if([self canExpandSection:section] && isSectionExpanded) {
        [_expandedSections removeIndex:section];
        
        NSInteger numberOfRows = [_targetDataSource tableView:self numberOfRowsInSection:section];
        
        if(_isDrawingComplete && numberOfRows > 0) {
            BOOL animated = (animation != UITableViewRowAnimationNone);
            [self willCollapseSection:section animated:animated];
            
            if(animated) {
                NSArray * indexPaths = [self indexPathsForSection:section numberOfRows:numberOfRows];
                [self beginUpdates];
                [self deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
                [self endUpdates];
                
                void(^completionBlock)(void) = ^{
                    [self didCollapseSection:section animated:animated];
                };
                
                [CATransaction setCompletionBlock:completionBlock];
            }
            else {
                [self reloadData];
            }
        }
    }
}

- (void)expandCollapseSection:(NSInteger)section animated:(BOOL)animated {
    if ([self canExpandSection:section]) {
        BOOL isSectionExpanded = [_expandedSections containsIndex:section];
        if(isSectionExpanded) {
            [self collapseSection:section withRowAnimation:(animated) ? UITableViewRowAnimationTop :
                                                                        UITableViewRowAnimationNone];
        }
        else {
            [self expandSection:section withRowAnimation:(animated) ? UITableViewRowAnimationTop :
                                                                      UITableViewRowAnimationNone];
        }
    }
}

#pragma mark - Private methods

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    _isDrawingComplete = YES;
}

- (NSArray*)indexPathsForSection:(NSInteger)section numberOfRows:(NSInteger)numberOfRows {
    NSMutableArray * indexPaths = [NSMutableArray array];
    for (NSInteger i = 0; i < numberOfRows; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    return [indexPaths copy];
}

#pragma mark - Internal DataSource Methods

- (BOOL)canExpandSection:(NSInteger)section {
    if([_targetDataSource respondsToSelector:@selector(tableView:canExpandSection:)]) {
        return [_targetDataSource tableView:self canExpandSection:section];
    }
    return NO;
}

#pragma mark - Internal Delegate Methods

- (void)willExpandSection:(NSUInteger)section animated:(BOOL)animated {
    if([_targetDelegate respondsToSelector:@selector(tableView:willExpandSection:animated:)]) {
        [_targetDelegate tableView:self willExpandSection:section animated:animated];
    }
}

- (void)didExpandSection:(NSUInteger)section animated:(BOOL)animated {
    if([_targetDelegate respondsToSelector:@selector(tableView:willExpandSection:animated:)]) {
        [_targetDelegate tableView:self didExpandSection:section animated:animated];
    }
}

- (void)willCollapseSection:(NSUInteger)section animated:(BOOL)animated {
    if([_targetDelegate respondsToSelector:@selector(tableView:willExpandSection:animated:)]) {
        [_targetDelegate tableView:self willCollapseSection:section animated:animated];
    }
}

- (void)didCollapseSection:(NSUInteger)section animated:(BOOL)animated {
    if([_targetDelegate respondsToSelector:@selector(tableView:willExpandSection:animated:)]) {
        [_targetDelegate tableView:self didCollapseSection:section animated:animated];
    }
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    BOOL isSectionExpanded = [_expandedSections containsIndex:section];
    BOOL canExpandSection = [self canExpandSection:section];
    if(!canExpandSection || (canExpandSection && isSectionExpanded)) {
        return [_targetDataSource tableView:self numberOfRowsInSection:section];
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_targetDataSource tableView:self cellForRowAtIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    SEL selector = @selector(numberOfSectionsInTableView:);
    if ([_targetDataSource respondsToSelector:selector]) {
        return [_targetDataSource numberOfSectionsInTableView:self];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    SEL selector = @selector(tableView:titleForHeaderInSection:);
    if ([_targetDataSource respondsToSelector:selector]) {
        return [_targetDataSource tableView:self titleForHeaderInSection:section];
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    SEL selector = @selector(tableView:canEditRowAtIndexPath:);
    if ([_targetDataSource respondsToSelector:selector]) {
        return [_targetDataSource tableView:self canEditRowAtIndexPath:indexPath];
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    SEL selector = @selector(tableView:canMoveRowAtIndexPath:);
    if ([_targetDataSource respondsToSelector:selector]) {
        return [_targetDataSource tableView:self canMoveRowAtIndexPath:indexPath];
    }
    return NO;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    SEL selector = @selector(sectionIndexTitlesForTableView:);
    if ([_targetDataSource respondsToSelector:selector]) {
        return [_targetDataSource sectionIndexTitlesForTableView:self];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    SEL selector = @selector(tableView:sectionForSectionIndexTitle:atIndex:);
    if ([_targetDataSource respondsToSelector:selector]) {
        return [_targetDataSource tableView:self sectionForSectionIndexTitle:title atIndex:index];
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]);
    if ([_targetDataSource respondsToSelector:selector]) {
        [_targetDataSource tableView:self commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]);
    if ([_targetDataSource respondsToSelector:selector]) {
        [_targetDataSource tableView:self moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    }
}

@end
