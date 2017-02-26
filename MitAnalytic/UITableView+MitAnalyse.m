//
//  UITableView+analyse.m
//  MitAnalytic
//
//  Created by MENGCHEN on 2017/1/12.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "UITableView+MitAnalyse.h"
#import "NSObject+methodSwissing.h"
#import <objc/runtime.h>
#import "MitAnalyse.h"
@implementation UITableView (MitAnalyse)
+ (void)load{
    //代理
    [NSObject swizzleMethod:[self class] origin:@selector(setDelegate:) new:@selector(analyse_setDelegate:)];
    
    
    
}

- (void)analyse_setDelegate:(id <UITableViewDelegate>)delegate{
    [self analyse_setDelegate:delegate];
    Class cls = [delegate class];
    //添加方法
    if(class_addMethod(cls, NSSelectorFromString(@"analyse_didSelectRowAtIndexPath"), (IMP)analyse_didSelectRowAtIndexPath, "v@:@@")){
        //原来的方法
        Method dis_originalMethod = class_getInstanceMethod(cls,@selector(tableView:didSelectRowAtIndexPath:));
        //现在的方法
        Method dis_swizzledMethod = class_getInstanceMethod(cls, NSSelectorFromString(@"analyse_didSelectRowAtIndexPath"));
        //交换实现
        method_exchangeImplementations(dis_originalMethod, dis_swizzledMethod);
    }
}
void analyse_didSelectRowAtIndexPath(id self, SEL _cmd, id tableView, id indexpath)
{
    NSIndexPath * index = indexpath;
    [MitAnalyse trackEventWithClass:[tableView class] target:self selector:_cmd message:[NSString stringWithFormat:@"section=%ld,row=%ld",index.section,index.row]];
}

@end
