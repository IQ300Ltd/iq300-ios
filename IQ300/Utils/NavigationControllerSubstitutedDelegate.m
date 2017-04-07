//
//  NavigationControllerSubstitutedDelegate.m
//  IQ300
//
//  Created by Viktor Shabanov on 4/7/17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import "NavigationControllerSubstitutedDelegate.h"

@implementation NavigationControllerSubstitutedDelegate

#pragma mark - Substitution UINavigationController delegate actoins

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (_defaultDelegate) {
        if ([viewController isKindOfClass:[UICollectionViewController class]]) {
            UICollectionViewController *collection = (UICollectionViewController *)viewController;
            
            if (collection.collectionView.contentSize.height > collection.collectionView.bounds.size.height) {
                CGPoint bottomOffset = CGPointMake(0, collection.collectionView.contentSize.height - collection.collectionView.bounds.size.height);
                [collection.collectionView setContentOffset:bottomOffset animated:YES];
            }
        }
        
        if ([_defaultDelegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
            [_defaultDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
        }
    }
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    
    if (_defaultDelegate) {
        if ([_defaultDelegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
            return [_defaultDelegate navigationController:navigationController
                                animationControllerForOperation:operation
                                             fromViewController:fromVC
                                               toViewController:toVC];
        }
    }
    
    return nil;
}

@end
