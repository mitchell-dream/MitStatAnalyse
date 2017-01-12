//
//  MitAnalyse+cache.m
//  MitAnalytic
//
//  Created by MENGCHEN on 2017/1/12.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "MitAnalyse+cache.h"
#import <objc/runtime.h>
@implementation MitAnalyse (Cache)

-(void)setAnalyseCache:(NSCache *)analyseCache{
    objc_setAssociatedObject(self, @selector(analyseCache), analyseCache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSCache *)analyseCache{
    return objc_getAssociatedObject(self, @selector(analyseCache));
}



@end
