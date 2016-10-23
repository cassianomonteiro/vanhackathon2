//
//  ConnectionManagerTests.m
//  SimpleTO-DOList
//
//  Created by Cassiano Monteiro on 21/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "ConnectionManager.h"

@interface ConnectionManagerTests : XCTestCase
@property (nonatomic, strong) XCTestExpectation *expectation;
@property (nonatomic, strong) ConnectionManager *manager;
@property (nonatomic, strong) id delegateMock;
@end

@implementation ConnectionManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.manager = [[ConnectionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://localhost:4567"]];
    self.delegateMock = OCMProtocolMock(@protocol(ConnectionManagerDelegate));
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Initialization tests

- (void)testInitWithBaseURL
{
    // Given
    ConnectionManager *manager = [[ConnectionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://test.url.com"]];
    // Then
    XCTAssertEqualObjects(manager.baseURL, [NSURL URLWithString:@"http://test.url.com"]);
}

- (void)testSetBaseURL
{
    // When
    self.manager.baseURL = [NSURL URLWithString:@"http://anotherurl"];
    // Then
    XCTAssertEqualObjects(self.manager.baseURL.absoluteString, @"http://anotherurl");
}

- (void)testDefaultManagerShouldHaveDefaultBaseURL
{
    // Given
    ConnectionManager *manager = [ConnectionManager defaultManager];
    NSString *expectedURLString = @"https://dreamwishlist-api.herokuapp.com";
    // Then
    XCTAssertEqualObjects(manager.baseURL.absoluteString, expectedURLString);
}

- (void)testDefaultManagerShouldBeSingleton
{
    // Given
    ConnectionManager *manager1 = [ConnectionManager defaultManager];
    ConnectionManager *manager2 = [ConnectionManager defaultManager];
    // Then
    XCTAssertEqualObjects(manager1, manager2);
}

#pragma mark - User tests

- (void)testRequestUserCreation
{
    [self evaluateRequestBlock:^{
        
        // Given
        User *user = [[User alloc] init];
        user.firebaseKey = @"abcde";
        user.name = @"John Armless";
        user.photoURL = [NSURL URLWithString:@"http://www.photo.com"];
        self.manager.firebaseKey = user.firebaseKey;
        
        // When
        [self.manager requestUserCreation:user forDelegate:self.delegateMock];
        
    } withEvaluationBlock:^(NSArray *returnedObjects) {
        
        XCTAssertEqual(returnedObjects.count, 1);
        XCTAssertTrue([returnedObjects.firstObject isKindOfClass:[User class]]);
        XCTAssertEqualObjects([returnedObjects.firstObject userId], @1);
        XCTAssertEqualObjects([returnedObjects.firstObject name], @"John Doe");
        XCTAssertEqualObjects([returnedObjects.firstObject photoURL], [NSURL URLWithString:@"http://www.photo.com"]);
        XCTAssertEqualObjects([returnedObjects.firstObject firebaseKey], @"123123");
    }];
}

#pragma mark - Dreams tests

- (void)testRequestDreams
{
    [self evaluateRequestBlock:^{
        
        // Given
        self.manager.firebaseKey = @"abcde";
        
        // When
        [self.manager requestUserDreamsForDelegate:self.delegateMock];
        
    } withEvaluationBlock:^(NSArray *returnedObjects) {
        
        XCTAssertEqual(returnedObjects.count, 2);
        XCTAssertTrue([returnedObjects.firstObject isKindOfClass:[Dream class]]);
        XCTAssertEqualObjects([returnedObjects.firstObject dreamId], @1);
        XCTAssertEqualObjects([returnedObjects.firstObject category], @"movie");
    }];
}

- (void)testRequestAllDreams
{
    [self evaluateRequestBlock:^{
        
        // Given
        self.manager.firebaseKey = @"abcde";
        
        // When
        [self.manager requestDreamsFeedForDelegate:self.delegateMock];
        
    } withEvaluationBlock:^(NSArray *returnedObjects) {
        
        XCTAssertEqual(returnedObjects.count, 8);
        XCTAssertTrue([returnedObjects.firstObject isKindOfClass:[Dream class]]);
        XCTAssertEqualObjects([returnedObjects.firstObject dreamId], @8);
        XCTAssertEqualObjects([returnedObjects.firstObject category], @"popular");
    }];
}

- (void)testRequestDreamCreation
{
    [self evaluateRequestBlock:^{
        
        // Given
        Dream *dream = [[Dream alloc] init];
        dream.category = @"sport";
        dream.subCategory = @"football";
        self.manager.firebaseKey = @"abcde";
        
        // When
        [self.manager requestDreamCreation:dream forDelegate:self.delegateMock];
        
    } withEvaluationBlock:^(NSArray *returnedObjects) {
        
        XCTAssertEqual(returnedObjects.count, 1);
        XCTAssertTrue([returnedObjects.firstObject isKindOfClass:[Dream class]]);
        Dream *createdDream = returnedObjects.firstObject;
        XCTAssertEqualObjects(createdDream.dreamId, @1);
        XCTAssertEqualObjects(createdDream.category, @"movie");
        XCTAssertEqualObjects(createdDream.subCategory, @"inception");
    }];
}

- (void)testRequestLayerCreation
{
    [self evaluateRequestBlock:^{
        
        // Given
        Layer *layer = [[Layer alloc] init];
        layer.dream = [[Dream alloc] init];
        layer.dream.dreamId = @10;
        layer.type = @"photo";
        layer.layerDescription = @"layerDescription";
        layer.layerURL = [NSURL URLWithString:@"http://url.to"];
        layer.productId = @20;
        self.manager.firebaseKey = @"abcde";
        
        // When
        [self.manager requestLayerCreation:layer forDelegate:self.delegateMock];
        
    } withEvaluationBlock:^(NSArray *returnedObjects) {
        
        XCTAssertEqual(returnedObjects.count, 1);
        XCTAssertTrue([returnedObjects.firstObject isKindOfClass:[Layer class]]);
        Layer *createdLayer = returnedObjects.firstObject;
        XCTAssertEqualObjects(createdLayer.layerId, @3);
        XCTAssertEqualObjects(createdLayer.type, @"product");
        XCTAssertEqualObjects(createdLayer.layerDescription, @"Inception DVD");
        XCTAssertEqualObjects(createdLayer.layerURL, [NSURL URLWithString:@"http://assets.ru/product.jpg"]);
        XCTAssertEqualObjects(createdLayer.productId, @332);
    }];
}

#pragma mark - Helpers

- (void)evaluateRequestBlock:(void (^)())requestBlock withEvaluationBlock:(void(^)(NSArray *returnedObjects))evaluationBlock
{
    // Given
    self.expectation = [self expectationWithDescription:@"Request Evaluation"];
    
    // Then (Asynchronous)
    void (^expectationFulfillment)(NSInvocation *) = ^(NSInvocation *invocation) {
        
        // Need to retain invocation arguments in order to retrieve returned objects without EXC_BAD_ACCESS error
        [invocation retainArguments];
        
        NSArray *returnedObjects;
        [invocation getArgument:&returnedObjects atIndex:3];
        
        evaluationBlock(returnedObjects);
        
        // Fulfill expectation after evaluation to make sure asserts are done before finishing running test case
        [self.expectation fulfill];
    };
    
    // When
    [[[self.delegateMock stub] andDo:expectationFulfillment] connectionManager:self.manager didCompleteRequestWithReturnedObjects:OCMOCK_ANY];
    
    requestBlock();
    
    // Wait asynchronously for the test completion
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        XCTAssertNil(error, @"Error completing expectation");
    }];
}

@end
