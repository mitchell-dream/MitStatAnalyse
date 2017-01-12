//
//  UIViewController+analyse.m
//  MitAnalytic
//
//  Created by MENGCHEN on 2017/1/11.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "UIViewController+analyse.h"
#import <objc/runtime.h>
#import "NSObject+methodSwissing.h"
#import "MitAnalyse.h"
@implementation UIViewController (analyse)

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSObject swizzleMethod:[self class] origin:@selector(viewWillAppear:) new:@selector(analyse_viewWillAppear:)];
        [NSObject swizzleMethod:[self class] origin:@selector(viewWillDisappear:) new:@selector(analyse_viewWillDisappear:)];
    });
}
- (void)analyse_viewWillAppear:(BOOL)animated{
    [self analyse_viewWillAppear:animated];
    [MitAnalyse trackEventWithClass:objc_getClass([NSStringFromClass([self class]) UTF8String])  target:self selector:@selector(viewWillAppear:) message:nil];
}
- (void)analyse_viewWillDisappear:(BOOL)animated{
    [self analyse_viewWillDisappear:animated];
    [MitAnalyse trackEventWithClass:objc_getClass([NSStringFromClass([self class]) UTF8String])  target:self selector:@selector(viewWillDisappear:) message:nil];

}




@end
