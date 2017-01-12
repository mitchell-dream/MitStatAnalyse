//
//  NSObject+methodSwissing.h
//  MitAnalytic
//
//  Created by MENGCHEN on 2017/1/11.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (methodSwissing)
+ (void)swizzleMethod:(Class)cls origin:(SEL)selector new:(SEL)newSelector;
@end
