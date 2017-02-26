//
//  AppDelegate+analyse.m
//  MitAnalytic
//
//  Created by MENGCHEN on 2017/1/23.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "AppDelegate+MitAnalyse.h"
#import "NSObject+methodSwissing.h"
#import "MitAnalyse.h"
@implementation AppDelegate (MitAnalyse)
+ (void)load{
    //启动
    [NSObject swizzleMethod:[self class] origin:@selector(application:didFinishLaunchingWithOptions:) new:@selector(analyse_application:didFinishLaunchingWithOptions:)];
    //终止
    [NSObject swizzleMethod:[self class] origin:@selector(applicationWillTerminate:) new:@selector(analyse_applicationWillTerminate:)];
    //进入前台
    [NSObject swizzleMethod:[self class] origin:@selector(applicationDidBecomeActive:) new:@selector(analyse_applicationDidBecomeActive:)];
    //将要失去活跃
    [NSObject swizzleMethod:[self class] origin:@selector(applicationWillResignActive:) new:@selector(analyse_applicationDidBecomeActive:)];
    //app即将进入前台
    [NSObject swizzleMethod:[self class] origin:@selector(applicationWillEnterForeground:) new:@selector(analyse_applicationWillEnterForeground:)];
    //app 进入后台
    [NSObject swizzleMethod:[self class] origin:@selector(applicationDidEnterBackground:) new:@selector(analyse_applicationDidEnterBackground:)];

}

#pragma mark action 启动
- (BOOL)analyse_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MitAnalyse trackEventWithClass:[self class] target:self selector:_cmd message:@"app启动"];
    return     [self analyse_application:application didFinishLaunchingWithOptions:launchOptions];
}

 #pragma mark action 终止
- (void)analyse_applicationWillTerminate:(UIApplication *)application{
    [MitAnalyse trackEventWithClass:[self class] target:self selector:_cmd message:@"app终止"];
    return     [self analyse_applicationWillTerminate:application];
}

#pragma mark action 即将活跃
- (void)analyse_applicationDidBecomeActive:(UIApplication *)application{
    [MitAnalyse trackEventWithClass:[self class] target:self selector:_cmd message:@"app变活跃"];
    return [self analyse_applicationWillTerminate:application];
}

#pragma mark action 失去活跃
-(void)analyse_applicationWillResignActive:(UIApplication *)application{
    [MitAnalyse trackEventWithClass:[self class] target:self selector:_cmd message:@"app失去活跃"];
    return [self analyse_applicationWillResignActive:application];
}
#pragma mark action 应用即将进入前台
-(void)analyse_applicationWillEnterForeground:(UIApplication *)application{
    [MitAnalyse trackEventWithClass:[self class] target:self selector:_cmd message:@"app即将进入前台"];
    return [self analyse_applicationWillEnterForeground:application];

}
#pragma mark action 应用进入后台
-(void)analyse_applicationDidEnterBackground:(UIApplication *)application{
    [MitAnalyse trackEventWithClass:[self class] target:self selector:_cmd message:@"app进入后台"];
    return [self analyse_applicationDidEnterBackground:application];
}

@end
