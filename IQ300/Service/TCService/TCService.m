//
//  TCService.m
//  TCService
//
//  Created by Tayphoon on 13.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "TCService.h"
#import "RKMappingResult+Result.h"

#define STORE_FILE_NAME @"Teametre"

NSString * const TCServiceErrorDomain = @"com.tayphoon.TCService.ErrorDomain";

static id _sharedService = nil;

@interface TCService() {
    NSString * _serviceUrl;
}

#ifdef _SYSTEMCONFIGURATION_H
@property (readwrite, nonatomic, assign) TCServiceReachabilityStatus serviceReachabilityStatus;
@property (readwrite, nonatomic, copy) TCServiceReachabilityStatusBlock serviceReachabilityStatusBlock;
#endif

@end

@implementation TCService

+ (NSString *)executableName {
    NSString *executableName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    if (nil == executableName) {
        NSLog(@"Unable to determine CFBundleExecutable: storing data under RestKit directory name.");
    }
    
    return executableName;
}

+ (NSString *)applicationDataDirectory {
    NSFileManager* sharedFM = [NSFileManager defaultManager];
    
    NSArray* possibleURLs = [sharedFM URLsForDirectory:NSApplicationSupportDirectory
                                             inDomains:NSUserDomainMask];
    NSURL* appSupportDir = nil;
    NSURL* appDirectory = nil;
    
    if ([possibleURLs count] >= 1) {
        appSupportDir = [possibleURLs objectAtIndex:0];
    }
    
    if (appSupportDir) {
        NSString *executableName = [self executableName];
        appDirectory = [appSupportDir URLByAppendingPathComponent:executableName];
        
        
        if(![sharedFM fileExistsAtPath:[appDirectory path]]) {
            NSError* error = nil;
            
            if(![sharedFM createDirectoryAtURL:appDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
                NSLog(@"Unable to create tmp directory: %@", error);
            }
        }
        return [appDirectory path];
    }
    
    return nil;
}

+ (instancetype)sharedService {
    return _sharedService;
}

+ (void)setSharedService:(id)service {
    _sharedService = service;
}

+ (instancetype)serviceWithURL:(NSString *)url andSession:(id)session {
    id service = [[self alloc] initWithURL:url andSession:session];
    if(!_sharedService) {
        [self setSharedService:service];
    }
    return service;
}

+ (instancetype)serviceWithURL:(NSString *)url {
    return  [self serviceWithURL:url andSession:nil];
}

- (id)initWithURL:(NSString *)url {
    return [self initWithURL:url andSession:nil];
}

- (id)initWithURL:(NSString *)url andSession:(id)session {
    if(self = [super init]) {
        _serviceUrl = url;
        _session = session;
        
        _objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:_serviceUrl]];
        [_objectManager.HTTPClient setParameterEncoding:AFJSONParameterEncoding];
        [_objectManager setRequestSerializationMIMEType:RKMIMETypeJSON];
        [_objectManager setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
        
#ifdef _SYSTEMCONFIGURATION_H
       self.serviceReachabilityStatus = (TCServiceReachabilityStatus)_objectManager.HTTPClient.networkReachabilityStatus;
        
        __unsafe_unretained typeof(self) weakSelf = self;
        [_objectManager.HTTPClient setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if(status == AFNetworkReachabilityStatusNotReachable ||
               status == AFNetworkReachabilityStatusUnknown) {
                weakSelf.serviceReachabilityStatus = (TCServiceReachabilityStatus)status;
            }
            else {
                [weakSelf updateServiceReachability];
            }
        }];
#endif
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"dd.MM.YY HH:mm:ss"];
        [[RKValueTransformer defaultValueTransformer] insertValueTransformer:dateFormatter atIndex:0];
        
        //Temporary disable NSURLCache - memory leak issue
        NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
        [NSURLCache setSharedURLCache:sharedCache];
        
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:STORE_FILE_NAME
                                                  withExtension:@"mom"
                                                   subdirectory:[NSString stringWithFormat:@"%@.momd", STORE_FILE_NAME]];
        NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
        [managedObjectStore createPersistentStoreCoordinator];
        
        NSString * storePath = [[TCService applicationDataDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", STORE_FILE_NAME]];
        NSError * error;
        
        BOOL isMigrationNeeded = [self isMigrationNeededForCoordinator:managedObjectStore.persistentStoreCoordinator
                                                              storeUrl:[NSURL fileURLWithPath:storePath]];
        if(isMigrationNeeded) {
            [[NSFileManager defaultManager] removeItemAtPath:storePath error:nil];
        }
        
        NSPersistentStore * persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath
                                                                          fromSeedDatabaseAtPath:nil
                                                                               withConfiguration:nil
                                                                                         options:nil
                                                                                           error:&error];
        
        NSAssert(persistentStore, @"Failed to add persistent store with error: %@ for file %@", error, storePath);
        
        // Create the managed object contexts
        [managedObjectStore createManagedObjectContexts];
        _objectManager.managedObjectStore = managedObjectStore;
        
        [self initDescriptors];
    }
    return self;
}

- (NSManagedObjectContext*)context {
    return _objectManager.managedObjectStore.mainQueueManagedObjectContext;
}

#ifdef _SYSTEMCONFIGURATION_H
- (void)setReachabilityStatusChangeBlock:(void (^)(TCServiceReachabilityStatus status))block {
    self.serviceReachabilityStatusBlock = block;
}

- (BOOL)isServiceReachable {
    return _serviceReachabilityStatus == TCServiceReachabilityStatusReachableViaWiFi ||
    _serviceReachabilityStatus == TCServiceReachabilityStatusReachableViaWWAN;
}
#endif

#pragma mark - Private methods

- (void)getObjectsAtPath:(NSString *)path parameters:(NSDictionary *)parameters handler:(ObjectLoaderCompletionHandler)handler {
    [self getObjectsAtPath:path
                parameters:parameters
              fetchRequest:nil
                   handler:handler];
}

- (void)getObjectsAtPath:(NSString *)path
              parameters:(NSDictionary *)parameters
            fetchRequest:(NSFetchRequest*)fetchRequest
                 handler:(ObjectLoaderCompletionHandler)handler {
    NSMutableDictionary * requesParameters = [parameters mutableCopy];
    
    RKObjectRequestOperation * operation = [_objectManager appropriateObjectRequestOperationWithObject:nil
                                                                                                method:RKRequestMethodGET
                                                                                                  path:path
                                                                                            parameters:requesParameters];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if(handler) {
            
            id<TCResponse> response = (id<TCResponse>)[mappingResult firstObject];
            BOOL conformsToProtocol = [[mappingResult firstObject] conformsToProtocol:@protocol(TCResponse)];
            if (conformsToProtocol && [response.statusCode integerValue] != 0) {
                [self processErrorResponse:response handler:handler];
                return;
            }
            
            id returnedValue = (conformsToProtocol) ? response.returnedValue : [mappingResult result];
            handler(YES, returnedValue, operation.HTTPRequestOperation.responseData, nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.HTTPRequestOperation.responseString);
        NSLog(@"%@", error);
        
        [self updateServiceReachabilityByError:error];
        
        [self processError:error
              forOperation:operation
                   handler:handler];
    }];
    
    [self processAuthorizationForOperation:operation];
    
    [_objectManager enqueueObjectRequestOperation:operation];
}

- (void)deleteObject:(id)object path:(NSString *)path parameters:(NSDictionary *)parameters handler:(ObjectLoaderCompletionHandler)handler {
    RKManagedObjectRequestOperation * operation = [_objectManager appropriateObjectRequestOperationWithObject:(object) ? object : [self emptyResponse]
                                                                                                       method:RKRequestMethodDELETE
                                                                                                         path:path
                                                                                                   parameters:parameters];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if(handler) {
            id<TCResponse> response = (id<TCResponse>)[mappingResult firstObject];
            BOOL conformsToProtocol = [[mappingResult firstObject] conformsToProtocol:@protocol(TCResponse)];
            if (conformsToProtocol && [response.statusCode integerValue] != 0) {
                [self processErrorResponse:response handler:handler];
                return;
            }
            
            id returnedValue = (conformsToProtocol) ? response.returnedValue : [mappingResult result];
            handler(YES, returnedValue, operation.HTTPRequestOperation.responseData, nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.HTTPRequestOperation.responseString);
        NSLog(@"%@", error);
        
        [self updateServiceReachabilityByError:error];
        
        [self processError:error
              forOperation:operation
                   handler:handler];
    }];
    
    [self processAuthorizationForOperation:operation];
    
    [_objectManager.operationQueue addOperation:operation];
}

- (void)putObject:(id)object path:(NSString *)path parameters:(NSDictionary *)parameters handler:(ObjectLoaderCompletionHandler)handler {
    RKManagedObjectRequestOperation * operation = [_objectManager appropriateObjectRequestOperationWithObject:(object) ? object : [self emptyResponse]
                                                                                                       method:RKRequestMethodPUT
                                                                                                         path:path
                                                                                                   parameters:parameters];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if(handler) {
            id<TCResponse> response = (id<TCResponse>)[mappingResult firstObject];
            BOOL conformsToProtocol = [[mappingResult firstObject] conformsToProtocol:@protocol(TCResponse)];
            if (conformsToProtocol && [response.statusCode integerValue] != 0) {
                [self processErrorResponse:response handler:handler];
                return;
            }
            
            id returnedValue = (conformsToProtocol) ? response.returnedValue : [mappingResult result];
            handler(YES, returnedValue, operation.HTTPRequestOperation.responseData, nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.HTTPRequestOperation.responseString);
        NSLog(@"%@", error);
        
        [self updateServiceReachabilityByError:error];
        
        [self processError:error
              forOperation:operation
                   handler:handler];
    }];
    
    [self processAuthorizationForOperation:operation];
    
    [_objectManager.operationQueue addOperation:operation];
}

- (void)postObject:(id)object path:(NSString *)path parameters:(NSDictionary *)parameters handler:(ObjectLoaderCompletionHandler)handler {
    RKManagedObjectRequestOperation * operation = [_objectManager appropriateObjectRequestOperationWithObject: (object) ? object : [self emptyResponse]
                                                                                                       method:RKRequestMethodPOST
                                                                                                         path:path
                                                                                                   parameters:parameters];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if(handler) {
            id<TCResponse> response = (id<TCResponse>)[mappingResult firstObject];
            BOOL conformsToProtocol = [[mappingResult firstObject] conformsToProtocol:@protocol(TCResponse)];
            if (conformsToProtocol && [response.statusCode integerValue] != 0) {
                [self processErrorResponse:response handler:handler];
                return;
            }
            
            id returnedValue = (conformsToProtocol) ? response.returnedValue : [mappingResult result];
            handler(YES, returnedValue, operation.HTTPRequestOperation.responseData, nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.HTTPRequestOperation.responseString);
        NSLog(@"%@", error);
        
        [self updateServiceReachabilityByError:error];
        
        [self processError:error
              forOperation:operation
                   handler:handler];
    }];
    
    [self processAuthorizationForOperation:operation];
    
    [_objectManager.operationQueue addOperation:operation];
}

- (void)postObjects:(NSArray*)objects path:(NSString *)path handler:(ObjectLoaderCompletionHandler)handler {
    NSError * error = nil;
    NSData * data = [NSJSONSerialization dataWithJSONObject:objects
                                                    options:0
                                                      error:&error];
    if(!error) {
        [self postData:data
                  path:path
               handler:handler];
    }
    else if(handler) {
        handler(NO, nil, nil, error);
    }
}

- (void)postData:(NSData*)data path:(NSString *)path handler:(ObjectLoaderCompletionHandler)handler {
    NSMutableURLRequest * request = [_objectManager requestWithObject:[self emptyResponse]
                                                               method:RKRequestMethodPOST
                                                                 path:path
                                                           parameters:nil];
    [request setValue:[NSString stringWithFormat:@"application/json; charset=utf-8"] forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    
    void (^success)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) = ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if(handler) {
            id<TCResponse> response = (id<TCResponse>)[mappingResult firstObject];
            BOOL conformsToProtocol = [[mappingResult firstObject] conformsToProtocol:@protocol(TCResponse)];
            if (conformsToProtocol && [response.statusCode integerValue] != 0) {
                [self processErrorResponse:response handler:handler];
                return;
            }
            
            id returnedValue = (conformsToProtocol) ? response.returnedValue : [mappingResult result];
            handler(YES, returnedValue, operation.HTTPRequestOperation.responseData, nil);
        }
    };
    
    void (^failure)(RKObjectRequestOperation *operation, NSError *error) = ^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.HTTPRequestOperation.responseString);
        NSLog(@"%@", error);
        
        [self updateServiceReachabilityByError:error];
        
        [self processError:error
              forOperation:operation
                   handler:handler];

    };
    
    RKObjectRequestOperation * operation = [_objectManager objectRequestOperationWithRequest:request
                                                                                     success:success
                                                                                     failure:failure];
    
    [self processAuthorizationForOperation:operation];
    
    [_objectManager.operationQueue addOperation:operation];
}

- (id<TCResponse>)emptyResponse {
    if(self.responseClass) {
        return [[(Class)self.responseClass alloc] init];
    }
    return nil;
}

#pragma mark - Override Methods

- (void)processErrorResponse:(id<TCResponse>)response handler:(ObjectLoaderCompletionHandler)handler {
    if(handler) {
        handler(NO, nil, nil, [self makeErrorWithDescription:response.errorMessage code:[response.statusCode integerValue]]);
    }
}

- (void)processError:(NSError*)error
        forOperation:(RKObjectRequestOperation*)operation
             handler:(ObjectLoaderCompletionHandler)handler {
    
    if(handler) {
        handler(NO, nil, operation.HTTPRequestOperation.responseData, error);
    }
}

- (void)updateServiceReachability {
}

- (void)updateServiceReachabilityByError:(NSError*)error {
}

- (void)initDescriptors {
    
}

- (void)processAuthorizationForOperation:(RKObjectRequestOperation*)operation {
    
}

- (NSError*)makeErrorWithDescription:(NSString*)errorDescription code:(NSInteger)code {
    NSError * error = [NSError errorWithDomain:TCServiceErrorDomain
                                          code:code
                                      userInfo:@{ @"NSLocalizedDescription" : (errorDescription) ? errorDescription : @"" }];
    return error;
}

#pragma mark - Private BD Helper methods

- (BOOL)isMigrationNeededForCoordinator:(NSPersistentStoreCoordinator*)persistentStoreCoordinator storeUrl:(NSURL*)storeUrl {
    NSError *error = nil;
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                              URL:storeUrl
                                                                                            error:&error];
    if(!error && sourceMetadata) {
        NSManagedObjectModel * destinationModel = [persistentStoreCoordinator managedObjectModel];
        BOOL isCompatibile = [destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata];
        return !isCompatibile;
    }
    return NO;
}

@end
