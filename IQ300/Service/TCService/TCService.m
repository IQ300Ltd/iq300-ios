//
//  TCService.m
//  TCService
//
//  Created by Tayphoon on 13.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "TCService.h"
#import "RKMappingResult+Result.h"
#import "ALAssetInputStream.h"
#import "NSError+Extension.h"
#import "TCObjectSerializator.h"

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
        
        NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:self.storeFileName ofType:@"momd"]];
        NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
        RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
        [managedObjectStore createPersistentStoreCoordinator];
        
        NSString * storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:self.storeFileName];
        NSError * error;
        
        BOOL isMigrationNeeded = [self isMigrationNeededForCoordinator:managedObjectStore.persistentStoreCoordinator
                                                              storeUrl:[NSURL fileURLWithPath:storePath]];
        if(isMigrationNeeded) {
            [[NSFileManager defaultManager] removeItemAtPath:storePath error:nil];
        }
        
#ifdef DEBUG
        NSPersistentStore * persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath
                                                                          fromSeedDatabaseAtPath:nil
                                                                               withConfiguration:nil
                                                                                         options:nil
                                                                                           error:&error];
        
        NSAssert(persistentStore, @"Failed to add persistent store with error: %@ for file %@", error, storePath);
#else
        [managedObjectStore addSQLitePersistentStoreAtPath:storePath
                                    fromSeedDatabaseAtPath:nil
                                         withConfiguration:nil
                                                   options:nil
                                                     error:&error];
#endif
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

- (NSString*)serviceUrl {
    return _serviceUrl;
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

- (void)getObjectsAtPath:(NSString *)path parameters:(NSDictionary *)parameters handler:(ObjectRequestCompletionHandler)handler {
    [self getObjectsAtPath:path
                parameters:parameters
                fetchBlock:nil
                   handler:handler];
}

- (void)getObjectsAtPath:(NSString *)path
              parameters:(NSDictionary *)parameters
              fetchBlock:(NSFetchRequest *(^)(NSURL *URL))fetchBlock
                 handler:(ObjectRequestCompletionHandler)handler {
    NSMutableDictionary * requesParameters = [parameters mutableCopy];
    
    RKObjectRequestOperation * operation = [_objectManager appropriateObjectRequestOperationWithObject:nil
                                                                                                method:RKRequestMethodGET
                                                                                                  path:path
                                                                                            parameters:requesParameters];
    
    [operation setCompletionBlockWithSuccess:[self makeSuccessBlockForHandler:handler]
                                     failure:[self makeFailureBlockForHandler:handler]];
    
    [self processAuthorizationForOperation:operation];
    
    if(fetchBlock && [operation isKindOfClass:[RKManagedObjectRequestOperation class]]) {
        RKManagedObjectRequestOperation * managedOperation = (RKManagedObjectRequestOperation*)operation;
        NSArray * fetchRequestBlocks = managedOperation.fetchRequestBlocks;
        if(!fetchRequestBlocks) {
            fetchRequestBlocks = @[fetchBlock];
        }
        else {
            fetchRequestBlocks = [fetchRequestBlocks arrayByAddingObject:fetchBlock];
        }
        managedOperation.fetchRequestBlocks = fetchRequestBlocks;
    }
    
    [_objectManager enqueueObjectRequestOperation:operation];
}

- (void)deleteObject:(id)object
                path:(NSString *)path
          parameters:(NSDictionary *)parameters
             handler:(ObjectRequestCompletionHandler)handler {
    [self deleteObject:object
                  path:path
            parameters:parameters
            fetchBlock:nil
               handler:handler];
}

- (void)deleteObject:(id)object
                path:(NSString *)path
          parameters:(NSDictionary *)parameters
          fetchBlock:(NSFetchRequest *(^)(NSURL *URL))fetchBlock
             handler:(ObjectRequestCompletionHandler)handler {
    RKManagedObjectRequestOperation * operation = [_objectManager appropriateObjectRequestOperationWithObject:(object) ? object : [self emptyResponse]
                                                                                                       method:RKRequestMethodDELETE
                                                                                                         path:path
                                                                                                   parameters:parameters];
    
    [operation setCompletionBlockWithSuccess:[self makeSuccessBlockForHandler:handler]
                                     failure:[self makeFailureBlockForHandler:handler]];
    
    [self processAuthorizationForOperation:operation];
    
    if(fetchBlock && [operation isKindOfClass:[RKManagedObjectRequestOperation class]]) {
        RKManagedObjectRequestOperation * managedOperation = (RKManagedObjectRequestOperation*)operation;
        NSArray * fetchRequestBlocks = managedOperation.fetchRequestBlocks;
        if(!fetchRequestBlocks) {
            fetchRequestBlocks = @[fetchBlock];
        }
        else {
            fetchRequestBlocks = [fetchRequestBlocks arrayByAddingObject:fetchBlock];
        }
        managedOperation.fetchRequestBlocks = fetchRequestBlocks;
    }

    [_objectManager enqueueObjectRequestOperation:operation];
}

- (void)putObject:(id)object
             path:(NSString *)path
       parameters:(NSDictionary *)parameters
          handler:(ObjectRequestCompletionHandler)handler {
    [self putObject:object
               path:path
         parameters:parameters
         fetchBlock:nil
            handler:handler];
}

- (void)putObject:(id)object
             path:(NSString *)path
       parameters:(NSDictionary *)parameters
       fetchBlock:(NSFetchRequest *(^)(NSURL *URL))fetchBlock
          handler:(ObjectRequestCompletionHandler)handler {
    RKManagedObjectRequestOperation * operation = [_objectManager appropriateObjectRequestOperationWithObject:(object) ? object : [self emptyResponse]
                                                                                                       method:RKRequestMethodPUT
                                                                                                         path:path
                                                                                                   parameters:parameters];
    
    [operation setCompletionBlockWithSuccess:[self makeSuccessBlockForHandler:handler]
                                     failure:[self makeFailureBlockForHandler:handler]];
    
    [self processAuthorizationForOperation:operation];
    
    if(fetchBlock && [operation isKindOfClass:[RKManagedObjectRequestOperation class]]) {
        RKManagedObjectRequestOperation * managedOperation = (RKManagedObjectRequestOperation*)operation;
        NSArray * fetchRequestBlocks = managedOperation.fetchRequestBlocks;
        if(!fetchRequestBlocks) {
            fetchRequestBlocks = @[fetchBlock];
        }
        else {
            fetchRequestBlocks = [fetchRequestBlocks arrayByAddingObject:fetchBlock];
        }
        managedOperation.fetchRequestBlocks = fetchRequestBlocks;
    }
    
    [_objectManager enqueueObjectRequestOperation:operation];
}

- (void)postObject:(id)object
              path:(NSString *)path
        parameters:(NSDictionary *)parameters
           handler:(ObjectRequestCompletionHandler)handler {
    [self postObject:object
                path:path
          parameters:parameters
          fetchBlock:nil
             handler:handler];
}

- (void)postObject:(id)object
              path:(NSString *)path
        parameters:(NSDictionary *)parameters
        fetchBlock:(NSFetchRequest *(^)(NSURL *URL))fetchBlock
           handler:(ObjectRequestCompletionHandler)handler {
    RKManagedObjectRequestOperation * operation = [_objectManager appropriateObjectRequestOperationWithObject: (object) ? object : [self emptyResponse]
                                                                                                       method:RKRequestMethodPOST
                                                                                                         path:path
                                                                                                   parameters:parameters];
    
    [operation setCompletionBlockWithSuccess:[self makeSuccessBlockForHandler:handler]
                                     failure:[self makeFailureBlockForHandler:handler]];
    
    [self processAuthorizationForOperation:operation];
    
    if(fetchBlock && [operation isKindOfClass:[RKManagedObjectRequestOperation class]]) {
        RKManagedObjectRequestOperation * managedOperation = (RKManagedObjectRequestOperation*)operation;
        NSArray * fetchRequestBlocks = managedOperation.fetchRequestBlocks;
        if(!fetchRequestBlocks) {
            fetchRequestBlocks = @[fetchBlock];
        }
        else {
            fetchRequestBlocks = [fetchRequestBlocks arrayByAddingObject:fetchBlock];
        }
        managedOperation.fetchRequestBlocks = fetchRequestBlocks;
    }
    
    [_objectManager enqueueObjectRequestOperation:operation];
}

- (void)postObjects:(NSArray*)objects path:(NSString *)path handler:(ObjectRequestCompletionHandler)handler {
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

- (void)postData:(NSData*)data path:(NSString *)path handler:(ObjectRequestCompletionHandler)handler {
    NSMutableURLRequest * request = [_objectManager requestWithObject:[self emptyResponse]
                                                               method:RKRequestMethodPOST
                                                                 path:path
                                                           parameters:nil];
    
    [request setValue:[NSString stringWithFormat:@"application/json; charset=utf-8"] forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    
    RKObjectRequestOperation * operation = [_objectManager objectRequestOperationWithRequest:request
                                                                                     success:[self makeSuccessBlockForHandler:handler]
                                                                                     failure:[self makeFailureBlockForHandler:handler]];
    [self processAuthorizationForOperation:operation];
    
    [_objectManager enqueueObjectRequestOperation:operation];
}

- (void)postData:(NSData*)fileData
            path:(NSString *)path
      parameters:(NSDictionary *)parameters
fileAttributeName:(NSString*)fileAttributeName
        fileName:(NSString*)fileName
        mimeType:(NSString*)mimeType
         handler:(ObjectRequestCompletionHandler)handler {
    
    void(^dataBlock)(id<AFMultipartFormData> formData) = ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:fileData
                                    name:fileAttributeName
                                fileName:fileName
                                mimeType:mimeType];
    };
    
    NSOperation * operation = [self createPostOperationAtPath:path
                                                   parameters:parameters
                                    constructingBodyWithBlock:dataBlock
                                                      handler:handler];
    // enqueue operation
    [_objectManager enqueueObjectRequestOperation:(RKManagedObjectRequestOperation*)operation];
}

- (void)postAsset:(ALAsset*)asset
             path:(NSString *)path
       parameters:(NSDictionary *)parameters
fileAttributeName:(NSString*)fileAttributeName
         fileName:(NSString*)fileName
         mimeType:(NSString*)mimeType
          handler:(ObjectRequestCompletionHandler)handler {
    ALAssetRepresentation * rep = [asset defaultRepresentation];
    ALAssetInputStream * stream = [[ALAssetInputStream alloc] initWithAsset:asset];
    
    
    void(^dataBlock)(id<AFMultipartFormData> formData) = ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithInputStream:stream
                                       name:fileAttributeName
                                   fileName:fileName
                                     length:rep.size
                                   mimeType:mimeType];
    };
    
    NSOperation * operation = [self createPostOperationAtPath:path
                                                   parameters:parameters
                                    constructingBodyWithBlock:dataBlock
                                                      handler:handler];
    // enqueue operation
    [_objectManager enqueueObjectRequestOperation:(RKManagedObjectRequestOperation*)operation];
}

- (void)postFileAtPath:(NSURL*)filePath
                  path:(NSString*)path
            parameters:(NSDictionary*)parameters
     fileAttributeName:(NSString*)fileAttributeName
              fileName:(NSString*)fileName
              mimeType:(NSString*)mimeType
               handler:(ObjectRequestCompletionHandler)handler {
    
    __block NSError * error = nil;
    void(^dataBlock)(id<AFMultipartFormData> formData) = ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:filePath
                                   name:fileAttributeName
                               fileName:fileName
                               mimeType:mimeType
                                  error:&error];
    };
    
    NSOperation * operation = [self createPostOperationAtPath:path
                                                   parameters:parameters
                                    constructingBodyWithBlock:dataBlock
                                                      handler:handler];
    // enqueue operation
    [_objectManager enqueueObjectRequestOperation:(RKManagedObjectRequestOperation*)operation];
}

- (NSOperation *)createPostOperationAtPath:(NSString *)path
                                parameters:(NSDictionary *)parameters
                 constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                                   handler:(ObjectRequestCompletionHandler)handler {
    NSMutableURLRequest * postRequest = [_objectManager multipartFormRequestWithObject:[self emptyResponse]
                                                                                method:RKRequestMethodPOST
                                                                                  path:path
                                                                            parameters:parameters
                                                             constructingBodyWithBlock:block];
    
    RKManagedObjectRequestOperation *postOperation = [_objectManager managedObjectRequestOperationWithRequest:postRequest
                                                                                         managedObjectContext:_objectManager.managedObjectStore.mainQueueManagedObjectContext
                                                                                                      success:[self makeSuccessBlockForHandler:handler]
                                                                                                      failure:[self makeFailureBlockForHandler:handler]];
    [self processAuthorizationForOperation:postOperation];
    
    return postOperation;
}

- (id<TCResponse>)emptyResponse {
    if(self.responseClass) {
        return [[(Class)self.responseClass alloc] init];
    }
    return nil;
}

#pragma mark - Override Methods

- (void)processErrorResponse:(id<TCResponse>)response handler:(ObjectRequestCompletionHandler)handler {
    if(handler) {
        handler(NO, nil, nil, [self makeErrorWithDescription:response.errorMessage code:[response.statusCode integerValue]]);
    }
}

- (void)processError:(NSError*)error
            response:(id<TCResponse>)response
        forOperation:(RKObjectRequestOperation*)operation
             handler:(ObjectRequestCompletionHandler)handler {
    
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

- (void(^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))makeSuccessBlockForHandler:(ObjectRequestCompletionHandler)handler {
    void (^success)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) = ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if(handler) {
            BOOL conformsToProtocol = [[mappingResult firstObject] conformsToProtocol:@protocol(TCResponse)];
            id<TCResponse> response = (conformsToProtocol) ? (id<TCResponse>)[mappingResult firstObject] : nil;
            if (conformsToProtocol && [response.statusCode integerValue] != 0) {
                [self processErrorResponse:response handler:handler];
                return;
            }
            
            id returnedValue = (conformsToProtocol) ? response.returnedValue : [mappingResult result];
            handler(YES, returnedValue, operation.HTTPRequestOperation.responseData, nil);
        }
    };
    return success;
}

- (void(^)(RKObjectRequestOperation *operation, NSError *error))makeFailureBlockForHandler:(ObjectRequestCompletionHandler)handler {
    void (^failure)(RKObjectRequestOperation *operation, NSError *error) = ^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.HTTPRequestOperation.responseString);
        NSLog(@"%@", error);
        
        [self updateServiceReachabilityByError:error];
        
        id errorResponseObject = error.userInfo[RKObjectMapperErrorObjectsKey];
        errorResponseObject = ([[errorResponseObject class]isSubclassOfClass:[NSArray class]]) ? [errorResponseObject firstObject] : errorResponseObject;
        BOOL conformsToProtocol = [errorResponseObject conformsToProtocol:@protocol(TCResponse)];
        id<TCResponse> response = (conformsToProtocol) ? (id<TCResponse>)errorResponseObject : nil;
        
        if(!response && self.responseClass && [operation.HTTPRequestOperation.responseString length] > 0) {
            NSError * serializeError = nil;
            response = [self trySerializeResponseObjectFromString:operation.HTTPRequestOperation.responseString
                                                            error:&serializeError];
        }
        
        if ([response.errorMessage length] > 0) {
            NSInteger serviceCode = [response.statusCode integerValue];
            NSInteger code = (serviceCode != 0) ? serviceCode : error.code;
            NSError * serviceError = [self makeErrorWithDescription:response.errorMessage code:code];
            error = [serviceError errorWithUnderlyingError:error];
        }
        
        [self processError:error
                  response:response
              forOperation:operation
                   handler:handler];
    };
    
    return failure;
}

- (id<TCResponse>)trySerializeResponseObjectFromString:(NSString*)responseString error:(NSError**)error {
    id<TCResponse> response = nil;
    NSError * serializeError = nil;
    NSDictionary * responseObject = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                                                                 options:0
                                                                   error:&serializeError];
    if (!serializeError && responseObject) {
        response = [TCObjectSerializator objectFromDictionary:@{ NSStringFromClass(self.responseClass) : responseObject }
                                             destinationClass:self.responseClass
                                                        error:&serializeError];
    }
    
    if (serializeError && error) {
        *error = serializeError;
    }
    
    return response;
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
