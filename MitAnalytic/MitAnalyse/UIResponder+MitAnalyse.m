//
//  UIResponder+analyse.m
//  MitAnalytic
//
//  Created by MENGCHEN on 2017/1/23.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "UIResponder+MitAnalyse.h"
#import "NSObject+methodSwissing.h"
#import "MitAnalyse.h"

@implementation UIResponder (MitAnalyse)
+ (void)load{
//    [NSObject swizzleMethod:[self class] origin:@selector(touchesBegan:withEvent:) new:@selector(analyse_touchesBegan:withEvent:)];
}

- (void)analyse_touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self analyse_touchesBegan:touches withEvent:event];
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:touch.view];
    [MitAnalyse trackEventWithClass:[self class] target:self selector:_cmd message:[NSString stringWithFormat:@"touchView=%@,point=%@",NSStringFromClass([touch.view class]),NSStringFromCGPoint(point)]];
    //这个地方如果 hook 了 touchesBegan 方法 会导致 tableView 的 didselect 方法相应错误，问题还需进一步探究。

    
    

}
@end
