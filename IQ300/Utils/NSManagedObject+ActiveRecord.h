//
//  NSManagedObject+ActiveRecord.h
//  Teaneter
//
//  Created by Tayphoon on 30.08.13.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (ActiveRecord)

/**
 * Fetches all objects from the persistent store identified by the fetchRequest
 */
+ (NSArray*)objectsWithFetchRequest:(NSFetchRequest*)fetchRequest inContext:(NSManagedObjectContext*)context;

/**
 * Fetches all objects from the persistent store via a set of fetch requests and
 * returns all results in a single array.
 */
+ (NSArray*)objectsWithFetchRequests:(NSArray*)fetchRequests inContext:(NSManagedObjectContext*)context;

/**
 * Fetches the first object identified by the fetch request. A limit of one will be
 * applied to the fetch request before dispatching.
 */
+ (id)objectWithFetchRequest:(NSFetchRequest*)fetchRequest inContext:(NSManagedObjectContext*)context;

/**
 * Fetches all objects from the persistent store by constructing a fetch request and
 * applying the predicate supplied. A short-cut for doing filtered searches on the objects
 * of this class under management.
 */
+ (NSArray*)objectsWithPredicate:(NSPredicate*)predicate inContext:(NSManagedObjectContext*)context;

/**
 * Fetches the first object matching a predicate from the persistent store. A fetch request
 * will be constructed for you and a fetch limit of 1 will be applied.
 */
+ (id)objectWithPredicate:(NSPredicate*)predicate inContext:(NSManagedObjectContext*)context;

/**
 * Fetches all managed objects of this class from the persistent store as an array
 */
+ (NSArray*)allObjectsInContext:(NSManagedObjectContext*)context;

/**
 * Returns a count of all managed objects of this class in the persistent store. On
 * error, will populate the error argument
 */
+ (NSUInteger)count:(NSError**)error inContext:(NSManagedObjectContext*)context;

/**
 *	Creates a new managed object and inserts it into the managedObjectContext.
 */
+ (id)objectInContext:(NSManagedObjectContext*)context;

/**
 * Returns YES when an object has not been saved to the managed object context yet
 */
- (BOOL)isNew;

////////////////////////////////////////////////////////////////////////////////////////////////////

+ (void)handleErrors:(NSError *)error;

+ (NSEntityDescription*)entityForContext:(NSManagedObjectContext*)context;
+ (NSArray *)executeFetchRequest:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context;
+ (NSFetchRequest *)createFetchRequestInContext:(NSManagedObjectContext *)context;
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;

+ (id)createInContext:(NSManagedObjectContext *)context;
- (BOOL)deleteInContext:(NSManagedObjectContext *)context;

+ (BOOL)truncateAllInContext:(NSManagedObjectContext *)context;

+ (NSArray *)ascendingSortDescriptors:(id)attributesToSortBy, ...;
+ (NSArray *)descendingSortDescriptors:(id)attributesToSortyBy, ...;

+ (NSNumber *)numberOfEntitiesWithContext:(NSManagedObjectContext *)context;
+ (NSNumber *)numberOfEntitiesWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;

+ (BOOL) hasAtLeastOneEntityInContext:(NSManagedObjectContext *)context;

+ (NSFetchRequest *)requestAllInContext:(NSManagedObjectContext *)context;
+ (NSFetchRequest *)requestAllWhere:(NSString *)property isEqualTo:(id)value inContext:(NSManagedObjectContext *)context;
+ (NSFetchRequest *)requestFirstWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;
+ (NSFetchRequest *)requestFirstByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context;
+ (NSFetchRequest *)requestAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;
+ (NSFetchRequest *)requestAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;

+ (NSArray *)findAllInContext:(NSManagedObjectContext *)context;
+ (NSArray *)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;
+ (NSArray *)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;

+ (NSArray *)findAllWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;

+ (NSNumber *)maxValueFor:(NSString *)property inContext:(NSManagedObjectContext*)context;
+ (id) objectWithMinValueFor:(NSString *)property inContext:(NSManagedObjectContext *)context;

+ (id)findFirstInContext:(NSManagedObjectContext *)context;
+ (id)findFirstWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;
+ (id)findFirstWithPredicate:(NSPredicate *)searchterm sortedBy:(NSString *)property ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;
+ (id)findFirstWithPredicate:(NSPredicate *)searchTerm andRetrieveAttributes:(NSArray *)attributes inContext:(NSManagedObjectContext *)context;
+ (id)findFirstWithPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortBy ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context andRetrieveAttributes:(id)attributes, ...;

+ (id)findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context;
+ (NSArray *)findByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context;
+ (NSArray *)findByAttribute:(NSString *)attribute withValue:(id)searchValue andOrderBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;

@end
