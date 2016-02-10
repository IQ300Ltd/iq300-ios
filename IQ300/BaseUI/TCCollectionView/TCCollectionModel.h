//
//  TCCollectionModel.h
//  Tayphoon
//
//  Created by Tayphoon on 27.08.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TCCollectionModel;

@protocol TCCollectionModelDelegate <NSObject>

@optional

- (void)modelDidChanged:(id<TCCollectionModel>)model;

- (void)modelWillChangeContent:(id<TCCollectionModel>)model;

- (void)model:(id<TCCollectionModel>)model didChangeSectionAtIndex:(NSUInteger)sectionIndex forChangeType:(NSUInteger)type;

- (void)model:(id<TCCollectionModel>)model
               didChangeObject:(id)anObject
                   atIndexPath:(NSIndexPath *)indexPath
                 forChangeType:(NSUInteger)type
                  newIndexPath:(NSIndexPath *)newIndexPath;

- (void)modelDidChangeContent:(id<TCCollectionModel>)model;

@end

@protocol TCCollectionModel <NSObject>

@property (nonatomic, weak) id<TCCollectionModelDelegate> delegate;

- (NSUInteger)numberOfSections;

- (NSString*)titleForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath*)indexPath;

- (NSUInteger)numberOfItemsInSection:(NSInteger)section;

- (NSString*)reuseIdentifierForCellAtIndexPath:(NSIndexPath*)indexPath;

- (NSString*)reuseIdentifierForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath*)indexPath;

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath*)indexPath constrainedToSize:(CGSize)size;

- (id)itemAtIndexPath:(NSIndexPath*)indexPath;

- (NSIndexPath*)indexPathOfObject:(id)object;

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion;

- (void)clearModelData;

@end

@interface TCCollectionModel : NSObject<TCCollectionModel> {
    NSArray * _items;
}

@property (nonatomic, readonly) NSArray * items;
@property (nonatomic, strong) NSArray * sortDescriptors;

@property (nonatomic, weak) id<TCCollectionModelDelegate> delegate;

@end
