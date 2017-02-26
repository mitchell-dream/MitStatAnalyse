//
//  UIControl+analyse.m
//  MitAnalytic
//
//  Created by MENGCHEN on 2017/1/11.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "UIControl+MitAnalyse.h"
#import <objc/runtime.h>
#import "NSObject+methodSwissing.h"
#import "MitAnalyse.h"
@implementation UIControl (MitAnalyse)
+(void)load{
    [NSObject swizzleMethod:[self class] origin:@selector(sendAction:to:forEvent:) new:@selector(analyse_sendAction:to:forEvent:)];
}
- (void)analyse_sendAction:(SEL)action to:(nullable id)target forEvent:(nullable UIEvent *)event{
    [self analyse_sendAction:action to:target forEvent:event];
    [MitAnalyse trackEventWithClass:[self class] target:target selector:action message:nil];
}

@end
