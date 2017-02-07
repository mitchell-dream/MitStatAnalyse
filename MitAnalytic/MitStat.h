//
//  MitStat.h
//  MitAnalytic
//
//  Created by MENGCHEN on 2017/1/12.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MitStat : NSObject


//发送类型
typedef NS_OPTIONS(NSUInteger, MitReportPolicy) {
    REALTIME = 1 << 0,      //实时发送
    BATCH = 1 << 1,         //启动时发送
    SEND_INTERVAL = 1 << 2, //最小间隔发送
};


//打点类型
typedef NS_ENUM(NSUInteger, MitStatType) {
    MITStatTypeRecord,      //记录类型
    MITStatTypeDuration,    //时常类型
};



/**
 *  初始化方法
 *  channelId： 渠道号
 *  userId：用户 Id
 */
+ (void)MitStatWithChannelId:(NSString *)channelId UserId:(NSString *)userId;

/**
 *  开始打点
 */
+ (void)startStat;


/**
 *  设置策略
 *  @param policy 策略
 */
+ (void)setPolicy:(MitReportPolicy)policy;
/**
 *  app 版本号
 *
 *  @param appVersion 版本号
 */
+ (void)setAppVersion:(NSString *)appVersion;
/**
 *  设置最小上报时间间隔
 *
 *  @param duration 时间间隔
 */
+ (void)setUpLoadMinTime:(CGFloat)duration;
/**
 *  设置用户 Id
 *
 *  @param userId 用户 Id
 */
+ (void)setUserId:(NSString *)userId;

/**
 *  设置渠道号
 *
 *  @param channelId 渠道号
 */+ (void)setChannelId:(NSString *)channelId;








+ (void)statWithOtherData:(NSDictionary *)dict;
+ (void)statWithAnalyseData:(NSDictionary *)dict;


@end
