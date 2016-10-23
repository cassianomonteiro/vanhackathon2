//
//  UserTests.m
//  SimpleTO-DOList
//
//  Created by Cassiano Monteiro on 21/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RestKit/Testing.h>
#import "User.h"

@interface UserTests : XCTestCase
@property (nonatomic, strong) User *user;
@end

@implementation UserTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // Configure RKTestFixture
    [RKTestFixture setFixtureBundle:[NSBundle bundleForClass:[self class]]];
    self.user = [[User alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRequestMapping
{
    // Given
    self.user.name = @"UserName";
    self.user.photoURL = [NSURL URLWithString:@"http://url.to"];
    self.user.firebaseKey = @"UserFirebaseKey";
    
    // When
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[User requestMapping] sourceObject:self.user destinationObject:nil];
    RKPropertyMappingTestExpectation *nameExpectation = [RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"name" destinationKeyPath:@"name" value:@"UserName"];
    RKPropertyMappingTestExpectation *firebaseKeyExpectation = [RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"firebaseKey" destinationKeyPath:@"firebase_key" value:@"UserFirebaseKey"];
    RKPropertyMappingTestExpectation *photoURLExpectation = [RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"photoAbsoluteURL" destinationKeyPath:@"photo_url" value:@"http://url.to"];
    
    // Then
    XCTAssertTrue([mappingTest evaluateExpectation:nameExpectation error:nil]);
    XCTAssertTrue([mappingTest evaluateExpectation:firebaseKeyExpectation error:nil]);
    XCTAssertTrue([mappingTest evaluateExpectation:photoURLExpectation error:nil]);
}

- (void)testResponseMapping
{
    // Given
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"User.json"];
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[User responseMapping] sourceObject:parsedJSON destinationObject:self.user];
    
    // When
    [mappingTest performMapping];
    
    // Then
    XCTAssertEqualObjects(self.user.userId, @1);
    XCTAssertEqualObjects(self.user.name, @"John Doe");
    XCTAssertEqualObjects(self.user.photoURL, [NSURL URLWithString:@"http://www.photo.com"]);
    XCTAssertEqualObjects(self.user.firebaseKey, @"123123");
}

@end
