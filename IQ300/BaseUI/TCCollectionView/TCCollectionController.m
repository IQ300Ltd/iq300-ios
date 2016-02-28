//
//  TCCollectionController.m
//  Tayphoon
//
//  Created by Tayphoon on 27.08.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TCCollectionController.h"
#import "UICollectionView+Updates.h"

@interface TCCollectionController() {
    UICollectionView * _collectionView;
    UIActivityIndicatorView * _activityIndicator;
    UIEdgeInsets _collectionInsets;

}

@end

@implementation TCCollectionController

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!self.collectionView.superview) {
        [self.view addSubview:self.collectionView];
    }
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (UICollectionView*)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout * collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                             collectionViewLayout:collectionViewFlowLayout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return _collectionView;
}

- (UILabel*)noDataLabel {
    if(!_noDataLabel) {
        _noDataLabel = [[UILabel alloc] init];
        [_noDataLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:15]];
        [_noDataLabel setTextColor:[UIColor colorWithHexInt:0xb3b3b3]];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.backgroundColor = [UIColor clearColor];
        _noDataLabel.numberOfLines = 0;
        _noDataLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _noDataLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _noDataLabel.hidden = YES;
        
        if (self.collectionView) {
            [self.view insertSubview:_noDataLabel belowSubview:self.collectionView];
            _noDataLabel.frame = self.collectionView.frame;
        }
        else {
            [self.view addSubview:_noDataLabel];
            _noDataLabel.frame = self.view.frame;
        }
    }
    return _noDataLabel;
}

- (void)setModel:(id<TCCollectionModel>)model {
    _model.delegate = nil;
    _model = model;
    _model.delegate = self;
}

- (void)reloadDataWithCompletion:(void (^)(NSError *error))completion {
    void (^completionBlock)(NSError *error) = ^(NSError *error) {
        if(!error) {
            [self.collectionView reloadData];
        }
        if (completion) {
            completion(error);
        }
    };
    
    if(self.model) {
        [self.model updateModelWithCompletion:completionBlock];
    }
    else {
        completionBlock(nil);
    }
}

- (void)collectionViewDidScrollToBottom:(UICollectionView*)collectionView {
    
}

#pragma mark - UICollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.model numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.model numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self.model reuseIdentifierForCellAtIndexPath:indexPath]
                                                                            forIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSString * reuseIdentifier = [self.model reuseIdentifierForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    UICollectionReusableView * supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                      withReuseIdentifier:reuseIdentifier
                                                                                             forIndexPath:indexPath];
    
    if ([supplementaryView respondsToSelector:@selector(setTitle:)]) {
        NSString * title = [self.model titleForSupplementaryElementOfKind:kind atIndexPath:indexPath];
        [supplementaryView setValue:title forKey:@"title"];
    }
    
    return supplementaryView;
}

#pragma mark - UICollectionViewLayout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.model sizeForItemAtIndexPath:indexPath constrainedToSize:CGSizeMake(collectionView.frame.size.width, 0)];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat scrollOffset = scrollView.contentOffset.y + scrollView.frame.size.height -
                           scrollView.contentInset.bottom - scrollView.contentInset.top;
    
    if (scrollOffset >= roundf(scrollView.contentSize.height)) {
        [self collectionViewDidScrollToBottom:self.collectionView];
    }
}

#pragma mark - TCCollectionModel Delegate

- (void)modelWillChangeContent:(id<TCCollectionModel>)model {
    [self.collectionView beginUpdates];
}

- (void)model:(id<TCCollectionModel>)model didChangeSectionAtIndex:(NSUInteger)sectionIndex forChangeType:(NSUInteger)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                                       animated:YES];
            break;
        case NSFetchedResultsChangeDelete:
            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                                       animated:YES];
            break;
    }
}

- (void)model:(id<TCCollectionModel>)model didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSUInteger)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                                animated:YES];
            break;
        case NSFetchedResultsChangeDelete:
            [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                                animated:YES];
            break;
        case NSFetchedResultsChangeMove:
            [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                                animated:YES];
            [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                                animated:YES];
            break;
        case NSFetchedResultsChangeUpdate:
            if ([indexPath isEqual:newIndexPath] || newIndexPath == nil) {
                [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                                    animated:YES];
            }
            else if(indexPath && newIndexPath) {
                [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                                    animated:YES];
                [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                                    animated:YES];
            }
            break;
    }
}

- (void)modelDidChangeContent:(id<TCCollectionModel>)model {
    [self updateNoDataLabelVisibility];
    [self.collectionView endUpdates];
}

- (void)modelDidChanged:(id<TCCollectionModel>)model {
    [self updateNoDataLabelVisibility];
    [self.collectionView reloadData];
}

- (void)updateNoDataLabelVisibility {
    if (_noDataLabel) {
        _noDataLabel.hidden = ([self.model numberOfItemsInSection:0] > 0);
    }
}

- (BOOL)isActivityIndicatorShown {
    return _activityIndicator && _activityIndicator.superview;
}

- (void)showActivityIndicatorAnimated:(BOOL)animated completion:(void (^)(void))completion {
    if (self.activityIndicator.isHidden) {
        [self.activityIndicator startAnimating];
        
        CGFloat indicatorHeight = self.activityIndicator.frame.size.height;
        self.activityIndicator.frame = CGRectMake(self.collectionView.frame.origin.x,
                                                  self.collectionView.frame.origin.y - indicatorHeight,
                                                  self.collectionView.frame.size.width,
                                                  self.activityIndicator.frame.size.height);
        [self.collectionView.superview insertSubview:self.activityIndicator aboveSubview:self.collectionView];
        
        self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _collectionInsets = self.collectionView.contentInset;
        CGPoint contentOffset = self.collectionView.contentOffset;
        UIEdgeInsets contentInsets = self.collectionView.contentInset;
        contentInsets.top = indicatorHeight;
        contentOffset.y -= indicatorHeight;
        
        [UIView animateWithDuration:animated ? 0.3 : 0.0
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.activityIndicator.frame = CGRectMake(self.collectionView.frame.origin.x,
                                                                       self.collectionView.frame.origin.y,
                                                                       self.collectionView.frame.size.width,
                                                                       self.activityIndicator.frame.size.height);
                             
                             self.collectionView.contentInset = contentInsets;
                             [self.collectionView setContentOffset:contentOffset animated:NO];
                         }
                         completion:^(BOOL finished) {
                             if (finished && completion) {
                                 completion();
                             }
                         }];
    }
}

- (void)hideActivityIndicatorAnimated:(BOOL)animated completion:(void (^)(void))completion {
    if (self.isActivityIndicatorShown) {
        CGFloat indicatorHeight = self.activityIndicator.frame.size.height;
        
        void (^completionBlock)(BOOL finished) = ^(BOOL finished)
        {
            self.collectionView.contentInset = _collectionInsets;
            [self.activityIndicator stopAnimating];
            [self.activityIndicator removeFromSuperview];
            if (finished && completion) {
                completion();
            }
        };
        
        if (animated) {
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.activityIndicator.frame = CGRectMake(self.collectionView.frame.origin.x,
                                                                           self.collectionView.frame.origin.y - indicatorHeight,
                                                                           self.collectionView.frame.size.width,
                                                                           self.activityIndicator.frame.size.height);
                                 self.collectionView.contentInset = _collectionInsets;
                             }
                             completion:completionBlock];
        }
        else {
            completionBlock(YES);
            [self.collectionView.layer removeAllAnimations];
            [self.collectionView setContentOffset:self.collectionView.contentOffset animated:NO];
        }
    }
}

#pragma mark - Private methods

- (UIActivityIndicatorView*)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.frame = CGRectMake(0.0f, -30, self.view.frame.size.width, 30);
        _activityIndicator.hidesWhenStopped = YES;
        _activityIndicator.hidden = YES;
        _activityIndicator.backgroundColor = [UIColor whiteColor];
    }
    
    return _activityIndicator;
}

@end
