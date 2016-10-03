//
//  MyTwitterTests.m
//  MyTwitterTests
//
//  Created by Robert Enderson on 15.09.16.
//  Copyright © 2016 Robert Enderson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TwitterHandler.h"
#import "SingletoneStorage.h"
#import "DataBaseHandler.h"

@interface MyTwitterTests : XCTestCase

@end

@implementation MyTwitterTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    NSString *stringFromExternalDatabase = @"Capital of Chad is N'Djamena";
    stringFromExternalDatabase = [stringFromExternalDatabase stringByReplacingOccurrencesOfString:@"'" withString:@""];
    NSLog(@"\n\n%@\n\n",stringFromExternalDatabase);
    
//    DataBaseHandler *db = [[DataBaseHandler alloc] initWithDatabaseFilename:@"twitDB"];
//    [db getSettingsAndAppVariables];
//    printf("\n\n%s\n\n\n",[SingletoneStorage getQueryToSaveSettings]);
    
//    NSLog(@"%@", [SingletoneStorage getAppVariables]);
//    NSLog(@"%@", [SingletoneStorage getSettingsState]);
    
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
