//
//  AppDelegate+analyse.m
//  MitAnalytic
//
//  Created by MENGCHEN on 2017/1/23.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "AppDelegate+analyse.h"
#import "NSObject+methodSwissing.h"
#import "MitAnalyse.h"
@implementation AppDelegate (analyse)
+(void)load{
    
    [NSObject swizzleMethod:[self class] origin:@selector(application:didFinishLaunchingWithOptions:) new:@selector(analyse_application:didFinishLaunchingWithOptions:)];
    
    
}

- (BOOL)analyse_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MitAnalyse trackEventWithClass:[self class] target:self selector:_cmd message:@"app启动"];
    return     [self analyse_application:application didFinishLaunchingWithOptions:launchOptions];

}


@end
