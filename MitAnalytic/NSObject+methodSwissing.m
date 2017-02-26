//
//  NSObject+methodSwissing.m
//  MitAnalytic
//
//  Created by MENGCHEN on 2017/1/11.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "NSObject+methodSwissing.h"
#import <objc/runtime.h>
@implementation NSObject (methodSwissing)



+ (void)swizzleMethod:(Class)cls origin:(SEL)originSelector new:(SEL)newSelector{
    Method originMethod = class_getInstanceMethod(cls, originSelector);
    Method swizzleMethod = class_getInstanceMethod(cls, newSelector);
    BOOL didAddMethod = class_addMethod(cls, originSelector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod));
    if (didAddMethod) {
        class_replaceMethod(cls, newSelector, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    } else {
        method_exchangeImplementations(originMethod, swizzleMethod);
    }
}


@end
