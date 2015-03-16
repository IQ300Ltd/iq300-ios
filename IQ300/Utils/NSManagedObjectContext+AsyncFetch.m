//
//  NSManagedObjectContext+AsyncFetch.m
//  OBI
//
//  Created by Tayphoon on 12.09.13.
//  Copyright (c) 2013 Tayphoon. All rights reserved.
//

#import "NSManagedObjectContext+AsyncFetch.h"

@implementation NSManagedObjectContext (AsyncFetch)

- (void)executeFetchRequest:(NSFetchRequest *)request completion:(void (^)(NSArray *objects, NSError *error))completion {
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    NSFetchRequestResultType resultType = [request resultType];
    
    NSManagedObjectContext * backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [backgroundContext performBlock:^{
        backgroundContext.persistentStoreCoordinator = coordinator;
        
        // Fetch into shared persistent store in background thread
        NSError * error = nil;
        NSArray * fetchedObjects = [backgroundContext executeFetchRequest:request error:&error];
        
        [self performBlock:^{
            if (resultType == NSManagedObjectResultType && fetchedObjects) {
                // Collect object IDs
                NSArray * objectIds = [fetchedObjects valueForKey:@"objectID"];
                
                // Fault in objects into current context by object ID as they are available in the shared persistent store
                NSMutableArray * mutObjects = [[NSMutableArray alloc] initWithCapacity:[objectIds count]];
                for (NSManagedObjectID * objectID in objectIds) {
                    NSManagedObject * obj = [self objectWithID:objectID];
                    [mutObjects addObject:obj];
                }
                
                if (completion) {
                    NSArray *objects = [mutObjects copy];
                    completion(objects, nil);
                }
            }
            else {
                if (completion) {
                    completion(fetchedObjects, error);
                }
            }
        }];
    }];
}

@end
