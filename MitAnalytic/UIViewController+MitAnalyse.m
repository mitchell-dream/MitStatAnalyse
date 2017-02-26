//
//  UIViewController+analyse.m
//  MitAnalytic
//
//  Created by MENGCHEN on 2017/1/11.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "UIViewController+MitAnalyse.h"
#import <objc/runtime.h>
#import "NSObject+methodSwissing.h"
#import "MitAnalyse.h"
@implementation UIViewController (MitAnalyse)

+(void)load{
    //界面加载
    [NSObject swizzleMethod:[self class] origin:@selector(viewDidLoad) new:@selector(analyse_viewDidLoad)];
    //界面将要出现
    [NSObject swizzleMethod:[self class] origin:@selector(viewWillAppear:) new:@selector(analyse_viewWillAppear:)];
    //界面出现
    [NSObject swizzleMethod:[self class] origin:@selector(viewDidAppear:) new:@selector(analyse_viewDidAppear:)];
    //界面将要消失
    [NSObject swizzleMethod:[self class] origin:@selector(viewWillDisappear:) new:@selector(analyse_viewWillDisappear:)];
    //界面消失
    [NSObject swizzleMethod:[self class] origin:@selector(viewDidDisappear:) new:@selector(analyse_viewDidDisappear:)];
}



#pragma mark action 界面即将出现
- (void)analyse_viewWillAppear:(BOOL)animated{
    [self analyse_viewWillAppear:animated];
    [MitAnalyse trackEventWithClass:objc_getClass([NSStringFromClass([self class]) UTF8String])  target:self selector:@selector(viewWillAppear:) message:nil];
}

#pragma mark action 界面即将消失
- (void)analyse_viewWillDisappear:(BOOL)animated{
    [self analyse_viewWillDisappear:animated];
    [MitAnalyse trackEventWithClass:objc_getClass([NSStringFromClass([self class]) UTF8String])  target:self selector:@selector(viewWillDisappear:) message:nil];
}

#pragma mark action 界面加载
- (void)analyse_viewDidLoad{
    [self analyse_viewDidLoad];
    [MitAnalyse trackEventWithClass:objc_getClass([NSStringFromClass([self class]) UTF8String])  target:self selector:@selector(viewDidLoad) message:nil];

}

#pragma mark action 界面出现
- (void)analyse_viewDidAppear:(BOOL)animated{
    [self analyse_viewDidAppear:animated];
    [MitAnalyse trackEventWithClass:objc_getClass([NSStringFromClass([self class]) UTF8String])  target:self selector:@selector(viewDidAppear:) message:nil];
}

#pragma mark action 界面消失
- (void)analyse_viewDidDisappear:(BOOL)animated{
    [self analyse_viewDidDisappear:animated];
    [MitAnalyse trackEventWithClass:objc_getClass([NSStringFromClass([self class]) UTF8String])  target:self selector:@selector(viewDidDisappear:) message:nil];
}




@end
