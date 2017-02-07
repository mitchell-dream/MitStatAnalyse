//
//  UITableView+analyse.m
//  MitAnalytic
//
//  Created by MENGCHEN on 2017/1/12.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "UITableView+analyse.h"
#import "NSObject+methodSwissing.h"
#import <objc/runtime.h>
#import "MitAnalyse.h"
@implementation UITableView (analyse)
+(void)load{
    [NSObject swizzleMethod:[self class] origin:@selector(setDelegate:) new:@selector(analyse_setDelegate:)];
}


- (void)analyse_setDelegate:(id <UITableViewDelegate>)delegate{
    [self analyse_setDelegate:delegate];
    Class cls = [delegate class];
    if(class_addMethod(cls, NSSelectorFromString(@"analyse_didSelectRowAtIndexPath"), (IMP)analyse_didSelectRowAtIndexPath, "v@:@@")){
        Method dis_originalMethod = class_getInstanceMethod(cls, NSSelectorFromString(@"analyse_didSelectRowAtIndexPath"));
        Method dis_swizzledMethod = class_getInstanceMethod(cls, @selector(tableView:didSelectRowAtIndexPath:));
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
