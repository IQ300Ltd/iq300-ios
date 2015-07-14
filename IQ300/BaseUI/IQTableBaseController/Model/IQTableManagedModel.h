//
//  IQTableManagedModel.h
//  IQ300
//
//  Created by Tayphoon on 14.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@interface IQTableManagedModel : NSObject<IQTableModel, NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController * _fetchController;
}

@property (nonatomic, readonly) NSArray * items;
@property (nonatomic, readonly) NSString * entityName;
@property (nonatomic, readonly) NSString * sectionNameKeyPath;
@property (nonatomic, readonly) NSString * cacheFileName;
@property (nonatomic, readonly) NSManagedObjectContext * context;

@property (nonatomic, assign) NSInteger section;
@property (nonatomic, strong) NSArray * sortDescriptors;

@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

- (NSPredicate*)fetchPredicate;

- (void)reloadModelSourceControllerWithCompletion:(void (^)(NSError * error))completion;

- (Class)cellClassForIndexPath:(NSIndexPath*)indexPath;

@end
