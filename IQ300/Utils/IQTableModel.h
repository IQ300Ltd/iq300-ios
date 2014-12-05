//
//  IQTableModel.h
//  IQ300
//
//  Created by Tayphoon on 14.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IQTableModel;

@protocol IQTableModelDelegate <NSObject>

@optional

- (void)modelDidChanged:(id<IQTableModel>)model;

- (void)modelWillChangeContent:(id<IQTableModel>)model;

- (void)model:(id<IQTableModel>)model didChangeSectionAtIndex:(NSUInteger)sectionIndex forChangeType:(NSUInteger)type;

- (void)model:(id<IQTableModel>)model didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSUInteger)type newIndexPath:(NSIndexPath *)newIndexPath;

- (void)modelDidChangeContent:(id<IQTableModel>)model;

- (void)modelCountersDidChanged:(id<IQTableModel>)model;

@end

@protocol IQTableModel <NSObject>

@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

- (NSUInteger)numberOfSections;

- (NSString*)titleForSection:(NSInteger)section;

- (NSUInteger)numberOfItemsInSection:(NSInteger)section;

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath;

- (id)createCellForIndexPath:(NSIndexPath*)indexPath;

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath;

- (id)itemAtIndexPath:(NSIndexPath*)indexPath;

- (NSIndexPath *)indexPathOfObject:(id)object;

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion;

- (void)clearModelData;

@end
