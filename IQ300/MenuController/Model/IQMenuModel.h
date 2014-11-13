//
//  IQMenuModel.h
//  IQ300
//
//  Created by Tayphoon on 06.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IQMenuModel;
@class MenuCell;

enum {
    IQModelChangeInsert = 1,
    IQModelChangeDelete = 2,
    IQModelChangeMove = 3,
    IQModelChangeUpdate = 4
    
};
typedef NSUInteger IQModelChangeType;

@protocol IQModelDelegate <NSObject>

@optional

- (void)modelDidChanged:(id<IQMenuModel>)model;

- (void)modelWillChangeContent:(id<IQMenuModel>)model;

- (void)model:(id<IQMenuModel>)model didChangeSectionAtIndex:(NSUInteger)sectionIndex forChangeType:(IQModelChangeType)type;

- (void)model:(id<IQMenuModel>)model didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(IQModelChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;

- (void)modelDidChangeContent:(id<IQMenuModel>)model;

@end

@protocol IQMenuModel <NSObject>

@property (weak) id<IQModelDelegate> delegate;

- (NSUInteger)numberOfSections;

- (NSString*)titleForSection:(NSInteger)section;

- (NSUInteger)numberOfItemsInSection:(NSInteger)section;

- (NSString*)reuseIdentifierForSection:(NSInteger)section;

- (MenuCell*)createCellForSection:(NSInteger)section;

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath;

- (id)itemAtIndexPath:(NSIndexPath*)indexPath;

- (NSIndexPath *)indexPathOfObject:(id)object;

- (Class)controllerClassForItemAtIndexPath:(NSIndexPath*)indexPath;

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion;

- (void)clearModelData;

@end
