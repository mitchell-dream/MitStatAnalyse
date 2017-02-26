//
//  MitAnalyse.h
//  MitAnalytic
//
//  Created by MENGCHEN on 2017/1/11.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MitAnalyseManager [MitAnalyse sharedManager]
@interface MitAnalyse : NSObject
+ (_Nullable instancetype)sharedManager;
//开始分析
+ (void)startAnalyse;
/*追踪事件
 * kclass: 类
 * target：目标
 * selector：方法
 * message：其他信息
 */
+ (void)trackEventWithClass:(_Nonnull Class)klass target:(nonnull id)targes selector:(_Nonnull SEL)selector message:(NSString * _Nullable )message;
@end
