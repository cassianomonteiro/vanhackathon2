//
//  DreamTests.m
//  DreamShop
//
//  Created by Cassiano Monteiro on 22/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RestKit/Testing.h>
#import "Dream.h"

@interface DreamTests : XCTestCase
@property (nonatomic, strong) Dream *dream;
@end

@implementation DreamTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // Configure RKTestFixture
    [RKTestFixture setFixtureBundle:[NSBundle bundleForClass:[self class]]];
    self.dream = [[Dream alloc] init];
//    self.dream.user = [[User alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRequestMapping
{
    // Given
    self.dream.category = @"Category";
    self.dream.subCategory = @"SubCategory";
    
    // When
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[Dream requestMapping] sourceObject:self.dream destinationObject:nil];
    RKPropertyMappingTestExpectation *categoryExpectation = [RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"category" destinationKeyPath:@"category" value:@"Category"];
    RKPropertyMappingTestExpectation *subCategoryExpectation = [RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"subCategory" destinationKeyPath:@"subcategory" value:@"SubCategory"];
    
    // Then
    XCTAssertTrue([mappingTest evaluateExpectation:categoryExpectation error:nil]);
    XCTAssertTrue([mappingTest evaluateExpectation:subCategoryExpectation error:nil]);
}

- (void)testResponseMapping
{
    // Given
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"Dream.json"];
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[Dream responseMapping] sourceObject:parsedJSON destinationObject:self.dream];
    
    // When
    [mappingTest performMapping];
    
    // Then
    XCTAssertEqualObjects(self.dream.dreamId, @1);
    XCTAssertEqualObjects(self.dream.category, @"movie");
    XCTAssertEqualObjects(self.dream.subCategory, @"inception");
    XCTAssertEqualObjects(self.dream.user.userId, @2);
}

@end
