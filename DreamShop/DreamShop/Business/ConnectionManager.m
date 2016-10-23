//
//  ConnectionManager.m
//  SimpleTO-DOList
//
//  Created by Cassiano Monteiro on 21/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import "ConnectionManager.h"

@interface ConnectionManager()
@property (nonatomic, strong) RKObjectManager *objectManager;
@property (nonatomic, strong) NSMutableArray<RKObjectRequestOperation *> *operations;
@end

@implementation ConnectionManager

#pragma mark - Initializers

static ConnectionManager *_sharedInstance;
static NSString *DefaultBaseURL = @"https://dreamwishlist-api.herokuapp.com";

static NSString *UserPathPattern    = @"/user";
static NSString *DreamsPathPattern  = @"/api/dreams";
static NSString *LayersPathPattern  = @"/api/layers";
static NSString *FeedPathPattern    = @"/feed/dreams";

+ (ConnectionManager *)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ConnectionManager alloc] initWithBaseURL:[NSURL URLWithString:DefaultBaseURL]];
    });
    
    return _sharedInstance;
}

- (instancetype)initWithBaseURL:(NSURL *)baseURL
{
    self = [super init];
    if (self) {
        self.baseURL = baseURL;
        self.operations = [NSMutableArray array];
    }
    return self;
}

- (NSURL *)baseURL
{
    return self.objectManager.baseURL;
}

- (void)setBaseURL:(NSURL *)baseURL
{
    // Instantiate object manager with webservice base url,
    // and add default routes and response descriptors
    self.objectManager = [RKObjectManager managerWithBaseURL:baseURL];
    self.objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    self.objectManager.managedObjectStore = [RKManagedObjectStore defaultStore];
    [self.objectManager.router.routeSet addRoutes:[self defaultClassRoutes]];
    [self.objectManager addRequestDescriptorsFromArray:[self defaultRequestDescriptors]];
    [self.objectManager addResponseDescriptorsFromArray:[self defaultResponseDescriptors]];
}

- (NSArray *)defaultClassRoutes
{
    return @[
             [RKRoute routeWithClass:[User class] pathPattern:UserPathPattern method:RKRequestMethodPOST],
             [RKRoute routeWithClass:[Dream class] pathPattern:DreamsPathPattern method:RKRequestMethodPOST],
             [RKRoute routeWithClass:[Layer class] pathPattern:LayersPathPattern method:RKRequestMethodPOST],
             [RKRoute routeWithName:DreamsPathPattern pathPattern:DreamsPathPattern method:RKRequestMethodGET],
             [RKRoute routeWithName:FeedPathPattern pathPattern:FeedPathPattern method:RKRequestMethodGET]
             
             ];
}

- (NSArray *)defaultRequestDescriptors
{
    return @[
             [RKRequestDescriptor requestDescriptorWithMapping:[User requestMapping] objectClass:[User class] rootKeyPath:nil method:RKRequestMethodPOST],
             [RKRequestDescriptor requestDescriptorWithMapping:[Dream requestMapping] objectClass:[Dream class] rootKeyPath:nil method:RKRequestMethodPOST],
             [RKRequestDescriptor requestDescriptorWithMapping:[Layer requestMapping] objectClass:[Layer class] rootKeyPath:nil method:RKRequestMethodPOST]
             ];
}

- (NSArray *)defaultResponseDescriptors
{
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // Anything in 2xx
    
    return @[
             [RKResponseDescriptor responseDescriptorWithMapping:[User responseMapping] method:RKRequestMethodPOST pathPattern:UserPathPattern keyPath:nil statusCodes:statusCodes],
             [RKResponseDescriptor responseDescriptorWithMapping:[Dream responseMapping] method:RKRequestMethodPOST pathPattern:DreamsPathPattern keyPath:nil statusCodes:statusCodes],
             [RKResponseDescriptor responseDescriptorWithMapping:[Layer responseMapping] method:RKRequestMethodPOST pathPattern:LayersPathPattern keyPath:nil statusCodes:statusCodes],
             [RKResponseDescriptor responseDescriptorWithMapping:[Dream responseMapping] method:RKRequestMethodGET pathPattern:DreamsPathPattern keyPath:nil statusCodes:statusCodes],
             [RKResponseDescriptor responseDescriptorWithMapping:[Dream responseMapping] method:RKRequestMethodGET pathPattern:FeedPathPattern keyPath:nil statusCodes:statusCodes],
             
             // Add error response descriptor to be tried last
             [self errorResponseDescriptor]
             ];
}

/**
 * Response descriptor default for 4xx and 5xx errors with JSON content {"errorMessage": "xxx"}
 *
 * @returns RKResponseDescriptor object
 */
- (RKResponseDescriptor *)errorResponseDescriptor
{
    // Error JSON looks like {"errorMessage": "xxx"}
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    // The entire value at the source key path containing the errors maps to the message
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    
    // Index status codes for 4xx and 5xx ranges
    NSMutableIndexSet *errorCodes = [[NSMutableIndexSet alloc] initWithIndexSet:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    [errorCodes addIndexes:RKStatusCodeIndexSetForClass(RKStatusCodeClassServerError)];
    
    // Any error response with an "errorMessage" key path uses this mapping
    return [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"errorMessage" statusCodes:errorCodes];
}

- (void)requestUserCreation:(User *)user forDelegate:(id<ConnectionManagerDelegate>)delegate
{
    [self sendRequestForObject:user withMethod:RKRequestMethodPOST andPath:nil andBodyParameters:nil andHeaderParameters:nil forDelegate:delegate];
}

- (void)requestDreamCreation:(Dream *)dream forDelegate:(id<ConnectionManagerDelegate>)delegate
{
    [self sendRequestForObject:dream withMethod:RKRequestMethodPOST andPath:nil andBodyParameters:nil andHeaderParameters:nil forDelegate:delegate];
}

- (void)requestLayerCreation:(Layer *)layer forDelegate:(id<ConnectionManagerDelegate>)delegate
{
    [self sendRequestForObject:layer withMethod:RKRequestMethodPOST andPath:nil andBodyParameters:nil andHeaderParameters:nil forDelegate:delegate];
}

- (void)requestUserDreamsForDelegate:(id<ConnectionManagerDelegate>)delegate
{
    [self sendRequestForObject:[Dream new] withMethod:RKRequestMethodGET andPath:DreamsPathPattern andBodyParameters:nil andHeaderParameters:nil forDelegate:delegate];
}

- (void)requestDreamsFeedForDelegate:(id<ConnectionManagerDelegate>)delegate
{
    [self sendRequestForObject:[Dream new] withMethod:RKRequestMethodGET andPath:FeedPathPattern andBodyParameters:nil andHeaderParameters:nil forDelegate:delegate];
}

#pragma mark - Helpers

- (void)sendRequestForObject:(id)object withMethod:(RKRequestMethod)requestMethod andPath:(NSString *)path andBodyParameters:(NSDictionary *)bodyParameters andHeaderParameters:(NSDictionary<NSString *, NSString *> *)headerParameters forDelegate:(id<ConnectionManagerDelegate>)delegate
{
    // Create a request
    NSMutableURLRequest *request;
    if (path) {
        // Get route with given path as route name
        request = [self.objectManager requestWithPathForRouteNamed:path object:object parameters:bodyParameters];
    }
    else {
        // Get route by class
        request = [self.objectManager requestWithObject:object method:requestMethod path:nil parameters:bodyParameters];
    }
    
    // Set request fixed HTTP header fields
    [request setValue:self.firebaseKey?:@"" forHTTPHeaderField:@"firebase_key"];
    
    // Set request custom HTTP header fields
    if (headerParameters) {
        [headerParameters enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [request setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    void(^successBlock)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) = ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        // Release executed operation
        [self.operations removeObject:operation];
        [delegate connectionManager:self didCompleteRequestWithReturnedObjects:mappingResult.array];
    };
    
    void(^failureBlock)(RKObjectRequestOperation *operation, NSError *error) = ^(RKObjectRequestOperation *operation, NSError *error) {
        // Release executed operation
        [self.operations removeObject:operation];
        [delegate connectionManager:self didFailRequestWithError:error];
    };
    
    RKObjectRequestOperation *operation;
    
    if (object) {
        // Create object request operation
        operation = [self.objectManager objectRequestOperationWithRequest:request
                                                                  success:successBlock
                                                                  failure:failureBlock];
    }
    else {
        // Create managed object request operation
        operation = [self.objectManager managedObjectRequestOperationWithRequest:request
                                                            managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                         success:successBlock
                                                                         failure:failureBlock];
    }
    
    // Add metadata for base URL
    operation.mappingMetadata = @{@"baseURL" : self.baseURL};
    
    // Hold onto operation with a strong pointer
    [self.operations addObject:operation];
    
    // DEBUG: Useful command to debug HTTPBody of a HTTP POST Request
    // po [[NSString alloc] initWithData:operation.HTTPRequestOperation.request.HTTPBody encoding:NSUTF8StringEncoding]
    
    // Start request operation asynchronously
    [operation start];
}

@end
