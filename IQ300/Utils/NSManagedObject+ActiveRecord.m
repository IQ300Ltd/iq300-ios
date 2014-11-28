//
//  NSManagedObject+ActiveRecord.m
//
//  Adapted from https://github.com/magicalpanda/MagicalRecord
//  Created by Saul Mora on 11/15/09.
//  Copyright 2010 Magical Panda Software, LLC All rights reserved.
//
//  Created by Chad Podoski on 3/18/11.
//

#import <objc/runtime.h>
#import "NSManagedObject+ActiveRecord.h"

static NSUInteger const kActiveRecordDefaultBatchSize = 10;
static NSNumber * defaultBatchSize = nil;

@implementation NSManagedObject (ActiveRecord)

#pragma mark - RKManagedObject methods

+ (NSEntityDescription*)entityForContext:(NSManagedObjectContext*)context {
	NSString* className = [NSString stringWithCString:class_getName([self class]) encoding:NSASCIIStringEncoding];
	return [NSEntityDescription entityForName:className inManagedObjectContext:context];
}

+ (NSFetchRequest*)fetchRequestForContext:(NSManagedObjectContext*)context {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [self entityForContext:context];
	[fetchRequest setEntity:entity];
	return fetchRequest;
}

+ (NSArray*)objectsWithFetchRequest:(NSFetchRequest*)fetchRequest inContext:(NSManagedObjectContext*)context {
	NSError* error = nil;
	NSArray* objects = [context executeFetchRequest:fetchRequest error:&error];
	return objects;
}

+ (NSArray*)objectsWithFetchRequests:(NSArray*)fetchRequests inContext:(NSManagedObjectContext*)context {
	NSMutableArray* mutableObjectArray = [[NSMutableArray alloc] init];
	for (NSFetchRequest* fetchRequest in fetchRequests) {
		[mutableObjectArray addObjectsFromArray:[self objectsWithFetchRequest:fetchRequest inContext:context]];
	}
	NSArray* objects = [NSArray arrayWithArray:mutableObjectArray];
	return objects;
}

+ (id)objectWithFetchRequest:(NSFetchRequest*)fetchRequest inContext:(NSManagedObjectContext*)context {
	[fetchRequest setFetchLimit:1];
	NSArray* objects = [self objectsWithFetchRequest:fetchRequest inContext:context];
	if ([objects count] == 0) {
		return nil;
	} else {
		return [objects objectAtIndex:0];
	}
}

+ (NSArray*)objectsWithPredicate:(NSPredicate*)predicate inContext:(NSManagedObjectContext*)context {
	NSFetchRequest* fetchRequest = [self fetchRequestForContext:context];
	[fetchRequest setPredicate:predicate];
	return [self objectsWithFetchRequest:fetchRequest inContext:context];
}

+ (id)objectWithPredicate:(NSPredicate*)predicate inContext:(NSManagedObjectContext*)context{
	NSFetchRequest* fetchRequest = [self fetchRequestForContext:context];
	[fetchRequest setPredicate:predicate];
	return [self objectWithFetchRequest:fetchRequest inContext:context];
}

+ (NSArray*)allObjectsInContext:(NSManagedObjectContext*)context {
	return [self objectsWithPredicate:nil inContext:context];
}

+ (NSUInteger)count:(NSError**)error inContext:(NSManagedObjectContext*)context {
	NSFetchRequest* fetchRequest = [self fetchRequestForContext:context];
	return [context countForFetchRequest:fetchRequest error:error];
}

+ (id)objectInContext:(NSManagedObjectContext*)context {
	id object = [[self alloc] initWithEntity:[self entityForContext:context]
              insertIntoManagedObjectContext:context];
	return object;
}

- (BOOL)isNew {
    NSDictionary *vals = [self committedValuesForKeys:nil];
    return [vals count] == 0;
}

#pragma mark - MagicalRecord Ported Methods

+ (void)setDefaultBatchSize:(NSUInteger)newBatchSize {
	@synchronized(defaultBatchSize) {
		defaultBatchSize = [NSNumber numberWithUnsignedInteger:newBatchSize];
	}
}

+ (NSInteger)defaultBatchSize {
	if (defaultBatchSize == nil) 	{
		[self setDefaultBatchSize:kActiveRecordDefaultBatchSize];
	}
	return [defaultBatchSize integerValue];
}

+ (void)handleErrors:(NSError *)error
{
	if (error)
	{
		NSDictionary *userInfo = [error userInfo];
		for (NSArray *detailedError in [userInfo allValues])
		{
			if ([detailedError isKindOfClass:[NSArray class]])
			{
				for (NSError *e in detailedError)
				{
					if ([e respondsToSelector:@selector(userInfo)])
					{
						NSLog(@"Error Details: %@", [e userInfo]);
					}
					else
					{
						NSLog(@"Error Details: %@", e);
					}
				}
			}
			else
			{
				NSLog(@"Error: %@", detailedError);
			}
		}
		NSLog(@"Error Domain: %@", [error domain]);
		NSLog(@"Recovery Suggestion: %@", [error localizedRecoverySuggestion]);
	}
}

+ (NSArray *)executeFetchRequest:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context {
	NSError *error = nil;
	
	NSArray *results = [context executeFetchRequest:request error:&error];
	[self handleErrors:error];
	return results;	
}

+ (id)executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context {
	[request setFetchLimit:1];
	
	NSArray *results = [self executeFetchRequest:request inContext:context];
	if ([results count] == 0)
	{
		return nil;
	}
	return [results objectAtIndex:0];
}

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context {
    NSString *entityName = NSStringFromClass([self class]);
    return [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
}

+ (NSArray *)propertiesNamed:(NSArray *)properties inContext:(NSManagedObjectContext *)context {
	NSEntityDescription *description = [self entityDescriptionInContext:context];
	NSMutableArray *propertiesWanted = [NSMutableArray array];
	
	if (properties)
	{
		NSDictionary *propDict = [description propertiesByName];
		
		for (NSString *propertyName in properties)
		{
			NSPropertyDescription *property = [propDict objectForKey:propertyName];
			if (property)
			{
				[propertiesWanted addObject:property];
			}
			else
			{
				NSLog(@"Property '%@' not found in %lu properties for %@", propertyName, (unsigned long)[propDict count], NSStringFromClass(self));
			}
		}
	}
	return propertiesWanted;
}

+ (NSArray *)sortAscending:(BOOL)ascending attributes:(id)attributesToSortBy, ... {
	NSMutableArray *attributes = [NSMutableArray array];
	
	if ([attributesToSortBy isKindOfClass:[NSArray class]])
	{
		id attributeName;
		va_list variadicArguments;
		va_start(variadicArguments, attributesToSortBy);
		while ((attributeName = va_arg(variadicArguments, id))!= nil)
		{
			NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:attributeName ascending:ascending];
			[attributes addObject:sortDescriptor];
		}
		va_end(variadicArguments);
        
	}
	else if ([attributesToSortBy isKindOfClass:[NSString class]])
	{
		va_list variadicArguments;
		va_start(variadicArguments, attributesToSortBy);
		[attributes addObject:[[NSSortDescriptor alloc] initWithKey:attributesToSortBy ascending:ascending]];
		va_end(variadicArguments);
	}
	
	return attributes;
}

+ (NSArray *)ascendingSortDescriptors:(id)attributesToSortBy, ... {
	return [self sortAscending:YES attributes:attributesToSortBy];
}

+ (NSArray *)descendingSortDescriptors:(id)attributesToSortyBy, ... {
	return [self sortAscending:NO attributes:attributesToSortyBy];
}

+ (NSFetchRequest *)createFetchRequestInContext:(NSManagedObjectContext *)context {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[self entityDescriptionInContext:context]];
	
	return request;	
}

#pragma mark -
#pragma mark Number of Entities

+ (NSNumber *)numberOfEntitiesWithContext:(NSManagedObjectContext *)context {
	NSError *error = nil;
	NSUInteger count = [context countForFetchRequest:[self createFetchRequestInContext:context] error:&error];
	[self handleErrors:error];
	
	return [NSNumber numberWithUnsignedInteger:count];	
}

+ (NSNumber *)numberOfEntitiesWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context {
	NSError *error = nil;
	NSFetchRequest *request = [self createFetchRequestInContext:context];
	[request setPredicate:searchTerm];
	
	NSUInteger count = [context countForFetchRequest:request error:&error];
	[self handleErrors:error];
	
	return [NSNumber numberWithUnsignedInteger:count];	
}

+ (BOOL)hasAtLeastOneEntityInContext:(NSManagedObjectContext *)context {
    return [[self numberOfEntitiesWithContext:context] intValue] > 0;
}

#pragma mark -
#pragma mark Reqest Helpers

+ (NSFetchRequest *)requestAllInContext:(NSManagedObjectContext *)context {
	return [self createFetchRequestInContext:context];
}

+ (NSFetchRequest *)requestAllWhere:(NSString *)property isEqualTo:(id)value inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [self createFetchRequestInContext:context];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", property, value]];
    
    return request;
}

+ (NSFetchRequest *)requestFirstWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [self createFetchRequestInContext:context];
    [request setPredicate:searchTerm];
    [request setFetchLimit:1];
    
    return request;
}

+ (NSFetchRequest *)requestFirstByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [self createFetchRequestInContext:context];
    [request setPropertiesToFetch:[self propertiesNamed:[NSArray arrayWithObject:attribute] inContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", attribute, searchValue]];
    
    return request;
}

+ (NSFetchRequest *)requestAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context {
	NSFetchRequest *request = [self requestAllInContext:context];
	
	NSSortDescriptor *sortBy = [[NSSortDescriptor alloc] initWithKey:sortTerm ascending:ascending];
	[request setSortDescriptors:[NSArray arrayWithObject:sortBy]];
	
	return request;
}

+ (NSFetchRequest *)requestAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context {
	NSFetchRequest *request = [self requestAllInContext:context];
	[request setPredicate:searchTerm];
	[request setIncludesSubentities:NO];
	[request setFetchBatchSize:[self defaultBatchSize]];
	
	if (sortTerm != nil){
		NSSortDescriptor *sortBy = [[NSSortDescriptor alloc] initWithKey:sortTerm ascending:ascending];
		[request setSortDescriptors:[NSArray arrayWithObject:sortBy]];
	}
	
	return request;
}

#pragma mark Finding Data
#pragma mark -

+ (NSArray *)findAllInContext:(NSManagedObjectContext *)context {
	return [self executeFetchRequest:[self requestAllInContext:context] inContext:context];	
}

+ (NSArray *)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context {
	NSFetchRequest *request = [self requestAllSortedBy:sortTerm ascending:ascending inContext:context];	
	return [self executeFetchRequest:request inContext:context];
}

+ (NSArray *)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context {
	NSFetchRequest *request = [self requestAllSortedBy:sortTerm 
											 ascending:ascending
										 withPredicate:searchTerm
											 inContext:context];
	
	return [self executeFetchRequest:request inContext:context];
}

#pragma mark -
#pragma mark NSFetchedResultsController helpers

#pragma mark -

+ (NSArray *)findAllWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context {
	NSFetchRequest *request = [self createFetchRequestInContext:context];
	[request setPredicate:searchTerm];
	
	return [self executeFetchRequest:request 
						   inContext:context];
}

+ (id)findFirstInContext:(NSManagedObjectContext *)context {
	NSFetchRequest *request = [self createFetchRequestInContext:context];
	
	return [self executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (id)findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context {	
	NSFetchRequest *request = [self requestFirstByAttribute:attribute withValue:searchValue inContext:context];
    [request setPropertiesToFetch:[self propertiesNamed:[NSArray arrayWithObject:attribute] inContext:context]];
    
	return [self executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (id)findFirstWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [self requestFirstWithPredicate:searchTerm inContext:context];
    
    return [self executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (id)findFirstWithPredicate:(NSPredicate *)searchterm sortedBy:(NSString *)property ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context {
	NSFetchRequest *request = [self requestAllSortedBy:property ascending:ascending withPredicate:searchterm inContext:context];
    
	return [self executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (id)findFirstWithPredicate:(NSPredicate *)searchTerm andRetrieveAttributes:(NSArray *)attributes inContext:(NSManagedObjectContext *)context {
	NSFetchRequest *request = [self createFetchRequestInContext:context];
	[request setPredicate:searchTerm];
	[request setPropertiesToFetch:[self propertiesNamed:attributes inContext:context]];
	
	return [self executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (id)findFirstWithPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortBy ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context andRetrieveAttributes:(id)attributes, ... {
	NSFetchRequest *request = [self requestAllSortedBy:sortBy 
											 ascending:ascending
										 withPredicate:searchTerm
											 inContext:context];
	[request setPropertiesToFetch:[self propertiesNamed:attributes inContext:context]];
	
	return [self executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (NSArray *)findByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context {
	NSFetchRequest *request = [self createFetchRequestInContext:context];
	
	[request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", attribute, searchValue]];
	
	return [self executeFetchRequest:request inContext:context];
}

+ (NSArray *)findByAttribute:(NSString *)attribute withValue:(id)searchValue andOrderBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context {
	NSPredicate *searchTerm = [NSPredicate predicateWithFormat:@"%K = %@", attribute, searchValue];
	NSFetchRequest *request = [self requestAllSortedBy:sortTerm ascending:ascending withPredicate:searchTerm inContext:context];
	
	return [self executeFetchRequest:request inContext:context];
}

+ (id)createInContext:(NSManagedObjectContext *)context {
    NSString *entityName = NSStringFromClass([self class]);
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
}

- (BOOL)deleteInContext:(NSManagedObjectContext *)context {
	[context deleteObject:self];
	return YES;
}

+ (BOOL)truncateAllInContext:(NSManagedObjectContext *)context {
    NSArray *allEntities = [self findAllInContext:context];
    for (NSManagedObject *obj in allEntities)
    {
        [obj deleteInContext:context];
    }
    return YES;
}

+ (NSNumber *)maxValueFor:(NSString *)property inContext:(NSManagedObjectContext*)context {
	NSManagedObject *obj = [[self class] findFirstByAttribute:property
													withValue:[NSString stringWithFormat:@"max(%@)", property]
                                                    inContext:context];
	
	return [obj valueForKey:property];
}

+ (id)objectWithMinValueFor:(NSString *)property inContext:(NSManagedObjectContext *)context {
	NSFetchRequest *request = [[self class] createFetchRequestInContext:context];
    
	NSPredicate *searchFor = [NSPredicate predicateWithFormat:@"SELF = %@ AND %K = min(%@)", self, property, property];
	[request setPredicate:searchFor];
	
	return [[self class] executeFetchRequestAndReturnFirstObject:request inContext:context];
}

@end
