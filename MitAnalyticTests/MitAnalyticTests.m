//
//  MitAnalyticTests.m
//  MitAnalyticTests
//
//  Created by MENGCHEN on 2017/2/26.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DemoButton.h"
#import "MitAnalyse.h"
@interface MitAnalyticTests : XCTestCase

@end

@implementation MitAnalyticTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    

    
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        //	10000次 8秒左右 seconds
        DemoButton * vc = [[DemoButton alloc]init];
        [MitAnalyse trackEventWithClass:[vc class] target:vc selector:@selector(class) message:nil];
    }];
    
    
}
- (void)testPerformMuitiTimes{
    [self measureBlock:^{
        //	10000次 8秒左右 seconds
        for (int i = 0; i<100; i++) {
            DemoButton * vc = [[DemoButton alloc]init];
            [MitAnalyse trackEventWithClass:[vc class] target:vc selector:@selector(class) message:nil];
        }
        
    }];
    
    
    
}

@end
