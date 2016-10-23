//
//  LayerTests.m
//  DreamShop
//
//  Created by Cassiano Monteiro on 23/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RestKit/Testing.h>
#import "Layer.h"

@interface LayerTests : XCTestCase
@property (nonatomic, strong) Layer *layer;
@end

@implementation LayerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // Configure RKTestFixture
    [RKTestFixture setFixtureBundle:[NSBundle bundleForClass:[self class]]];
    self.layer = [[Layer alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testRequestMapping
{
    // Given
    self.layer.layerId = @20;
    self.layer.type = @"LayerType";
    self.layer.layerDescription = @"LayerDescription";
    self.layer.layerURL = [NSURL URLWithString:@"http://url.to"];
    self.layer.productId = @30;
    
    // When
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[Layer requestMapping] sourceObject:self.layer destinationObject:nil];
    RKPropertyMappingTestExpectation *idExpectation = [RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"layerId" destinationKeyPath:@"id" value:@20];
    RKPropertyMappingTestExpectation *typeExpectation = [RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"type" destinationKeyPath:@"type" value:@"LayerType"];
    RKPropertyMappingTestExpectation *descriptionExpectation = [RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"layerDescription" destinationKeyPath:@"description" value:@"LayerDescription"];
    RKPropertyMappingTestExpectation *urlExpectation = [RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"layerAbsoluteURL" destinationKeyPath:@"url" value:@"http://url.to"];
    RKPropertyMappingTestExpectation *productExpectation = [RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"productId" destinationKeyPath:@"product_id" value:@30];
    
    // Then
    XCTAssertTrue([mappingTest evaluateExpectation:idExpectation error:nil]);
    XCTAssertTrue([mappingTest evaluateExpectation:typeExpectation error:nil]);
    XCTAssertTrue([mappingTest evaluateExpectation:descriptionExpectation error:nil]);
    XCTAssertTrue([mappingTest evaluateExpectation:urlExpectation error:nil]);
    XCTAssertTrue([mappingTest evaluateExpectation:productExpectation error:nil]);
}

- (void)testResponseMapping
{
    // Given
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"Layer.json"];
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[Layer responseMapping] sourceObject:parsedJSON destinationObject:self.layer];
    
    // When
    [mappingTest performMapping];
    
    // Then
    XCTAssertEqualObjects(self.layer.layerId, @3);
    XCTAssertEqualObjects(self.layer.type, @"product");
    XCTAssertEqualObjects(self.layer.layerDescription, @"Inception DVD");
    XCTAssertEqualObjects(self.layer.layerURL, [NSURL URLWithString:@"http://assets.ru/product.jpg"]);
    XCTAssertEqualObjects(self.layer.productId, @332);
}

@end
