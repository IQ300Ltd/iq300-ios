//
//  IQFakeService.m
//  IQ300
//
//  Created by Tayphoon on 18.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQFakeService.h"
#import "RKMappingResult+Result.h"

static NSArray *IQFilteredArrayOfResponseDescriptorsMatchingPathAndMethod(NSArray *responseDescriptors, NSString *path, RKRequestMethod method)
{
    NSIndexSet *indexSet = [responseDescriptors indexesOfObjectsPassingTest:^BOOL(RKResponseDescriptor *responseDescriptor, NSUInteger idx, BOOL *stop) {
        return [responseDescriptor matchesPath:path] && (method & responseDescriptor.method);
    }];
    return [responseDescriptors objectsAtIndexes:indexSet];
}

@implementation IQFakeService

+ (NSString*)fileFixtureForPath:(NSString*)path {
    static NSDictionary * _pathToFileRoute = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _pathToFileRoute = @{ @"StudycardID" : @"" };
    });
    
    if([_pathToFileRoute objectForKey:path]) {
        return [_pathToFileRoute objectForKey:path];
    }
    return nil;
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password handler:(RequestCompletionHandler)handler {
    if(handler) {
        self.session = [IQSession sessionWithEmail:email andPassword:password token:@""];
        handler(YES, nil, nil);
    }
}

#pragma mark - Private methods

- (void)processAuthorizationForOperation:(RKObjectRequestOperation *)operation {
    if(self.session) {
        NSString * token = [NSString stringWithFormat:@"%@ %@", self.session.tokenType, self.session.token];
        [((NSMutableURLRequest*)operation.HTTPRequestOperation.request) addValue:token forHTTPHeaderField:@"Authorization"];
    }
}

- (NSString *)MIMETypeForFixture:(NSString *)fixtureName
{
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:fixtureName ofType:nil];
    if (resourcePath) {
        return RKMIMETypeFromPathExtension(resourcePath);
    }
    
    return nil;
}

- (id)parsedObjectWithContentsOfFixture:(NSString *)fixtureName
{
    NSError *error = nil;
    NSData *resourceContents = [self dataWithContentsOfFixture:fixtureName];
    NSAssert(resourceContents, @"Failed to read fixture named '%@'", fixtureName);
    NSString *MIMEType = [self MIMETypeForFixture:fixtureName];
    NSAssert(MIMEType, @"Failed to determine MIME type of fixture named '%@'", fixtureName);
    
    id object = [RKMIMETypeSerialization objectFromData:resourceContents MIMEType:MIMEType error:&error];
    NSAssert(object, @"Failed to parse fixture name '%@' in bundle %@. Error: %@", fixtureName, [NSBundle mainBundle], [error localizedDescription]);
    return object;
}

- (NSData *)dataWithContentsOfFixture:(NSString *)fixtureName
{
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:fixtureName ofType:nil];
    if (! resourcePath) {
        RKLogWarning(@"Failed to locate Fixture named '%@' in bundle %@: File Not Found.", fixtureName, [NSBundle mainBundle]);
        return nil;
    }
    
    return [NSData dataWithContentsOfFile:resourcePath];
}

- (void)getLocalObjects:(id)object atPath:(NSString *)path parameters:(NSDictionary *)parameters method:(RKRequestMethod)method handler:(ObjectLoaderCompletionHandler)handler {
    NSString * filePath = [IQFakeService fileFixtureForPath:path];
    id responseData = [self parsedObjectWithContentsOfFixture:filePath];
    if(responseData) {
        RKManagedObjectStore *managedObjectStore = self.objectManager.managedObjectStore;
        NSArray *matchingDescriptors = IQFilteredArrayOfResponseDescriptorsMatchingPathAndMethod(self.objectManager.responseDescriptors, path, method);
        NSDictionary * mappingsDictionary = [self buildMappingsDictionaryFrom:matchingDescriptors];
        RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:responseData mappingsDictionary:mappingsDictionary];
        RKManagedObjectMappingOperationDataSource *dataSource = [[RKManagedObjectMappingOperationDataSource alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext
                                                                                                                                          cache:nil];
        mapper.mappingOperationDataSource = dataSource;
        [mapper start];
        
        if(!mapper.error) {
            id<TCResponse> response = (id<TCResponse>)[mapper.mappingResult firstObject];
            BOOL conformsToProtocol = [[mapper.mappingResult firstObject] conformsToProtocol:@protocol(TCResponse)];
            if (conformsToProtocol && [response.statusCode integerValue] != 0) {
                [self processErrorResponse:response handler:handler];
                return;
            }
            
            id returnedValue = (conformsToProtocol) ? response.returnedValue : [mapper.mappingResult result];
            handler(YES, returnedValue, nil, nil);
        }
    }
}

- (NSDictionary *)buildMappingsDictionaryFrom:(NSArray*)matchingDescriptors
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (RKResponseDescriptor *responseDescriptor in matchingDescriptors) {
        [dictionary setObject:responseDescriptor.mapping forKey:(responseDescriptor.keyPath ?: [NSNull null])];
    }
    
    return dictionary;
}

@end
