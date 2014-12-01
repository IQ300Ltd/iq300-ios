//
//  NSManagedObjectContext+AsyncFetch.h
//  OBI
//
//  Created by Tayphoon on 12.09.13.
//  Copyright (c) 2013 Tayphoon. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (AsyncFetch)

- (void)executeFetchRequest:(NSFetchRequest *)request completion:(void (^)(NSArray *objects, NSError *error))completion;

@end
