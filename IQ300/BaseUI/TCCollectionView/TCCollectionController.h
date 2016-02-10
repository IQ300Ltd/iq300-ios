//
//  TCCollectionController.h
//  Tayphoon
//
//  Created by Tayphoon on 27.08.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TCCollectionModel.h"
#import "UIViewController+ErrorHandle.h"

@interface TCCollectionController : UIViewController<TCCollectionModelDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, readonly) UICollectionView * collectionView;
@property (nonatomic, strong) UILabel * noDataLabel;
@property (nonatomic, strong) id<TCCollectionModel> model;

- (void)reloadDataWithCompletion:(void (^)(NSError *error))completion;
- (void)updateNoDataLabelVisibility;
- (void)showActivityIndicatorAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)hideActivityIndicatorAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)collectionViewDidScrollToBottom:(UICollectionView*)collectionView;

@end
