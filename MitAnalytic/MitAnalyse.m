//
//  MitAnalyse.m
//  MitAnalytic
//
//  Created by MENGCHEN on 2017/1/11.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "MitAnalyse.h"
#import <objc/runtime.h>
#import "MitStat.h"


static NSString * kJsonFileName =@"MitAnalyseFile";

@interface MitAnalyse()<NSCacheDelegate>
/** 数据集合 */
@property(nonatomic, strong)NSMutableArray * classData;
/** 操作队列*/
@property(nonatomic, strong)NSOperationQueue * queue;
/** 缓存 */
@property(nonatomic, strong)NSCache * analyseCache;
@end

@implementation MitAnalyse
{
    dispatch_queue_t _fileQueue;
}

+(instancetype)sharedManager{
    return [[self alloc]init];
}
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static MitAnalyse * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:zone];
    });
    return manager;
}


#pragma create 内存缓存
-(NSCache *)analyseCache{
    if (!_analyseCache) {
        NSCache * ca = [[NSCache alloc]init];
        ca.delegate = self;
        ca.countLimit = 100;
        _analyseCache = ca;
    }
    return _analyseCache;
}
#pragma create 创建队列
-(NSOperationQueue *)queue{
    if (!_queue) {
        NSOperationQueue * que = [[NSOperationQueue alloc]init];
        que.maxConcurrentOperationCount = 1;
        _queue = que;
    }
    return _queue;
}


#pragma mark ------------------ Action ------------------

#pragma mark action 开始分析
+(void)startAnalyse{
    [MitAnalyse loadJsonFile];
}

#pragma mark action 解析事件
+ (void)trackEventWithClass:(Class)cls target:(id)targes selector:(SEL)selector message:(NSString * _Nullable)message{
    NSString * clsName = NSStringFromClass(cls);
    NSString * targetName = NSStringFromClass([targes class]);
    NSString * methodName = NSStringFromSelector(selector);
    NSLog(@"解析事件：class = %@ target = %@ sel = %@",clsName,targetName,methodName);
    NSString * key = [NSString stringWithFormat:@"%@_%@_%@",clsName,targetName,methodName];
    NSDictionary * dict = [MitAnalyse readDataFromKey:key];
    if (message&&dict) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:dict];
        [dic setValue:message forKey:@"others"];
        dict = [dic copy];
    }
    if (dict) {
        //缓存中有值，打对应的点
        
        [MitStat statWithAnalyseData:dict];
    } else {
        NSDictionary * dic = @{@"class":clsName,@"target":targetName,@"sel":methodName};
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:dic];
        if (message) {
            [dict setValue:message forKey:@"others"];
        }
        //缓存中无值，证明文件中没有这个事件，属于意外打点。
        [MitStat statWithOtherData:dict];
    }
}


#pragma mark action 写缓存
- (void)writeData:(NSDictionary *)dict forKey:(NSString *)key{
    NSString * filePath = [MitAnalyse filePathForKey:key];
    //内存缓存
    if (![MitAnalyseManager.analyseCache objectForKey:key]) {
        [MitAnalyseManager.analyseCache setObject:dict forKey:key];
    }
    //磁盘缓存
    NSError * error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@",error.description);
        return;
    }
//    NSLog(@"dict = %@ key = %@",dict,key);
    if (![[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        dispatch_async([MitAnalyseManager getFileQueue], ^{
            [[NSFileManager defaultManager]createFileAtPath:filePath contents:data attributes:nil];
        });
    };
}

#pragma mark action 获取文件操作队列
-(dispatch_queue_t) getFileQueue{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _fileQueue = dispatch_queue_create(0, DISPATCH_QUEUE_CONCURRENT);
    });
    return _fileQueue;
}


#pragma mark action 根据 key 获取文件路径
+ (NSString *)filePathForKey:(NSString *)key{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory
                                                       , NSUserDomainMask
                                                       , YES);
    NSString * filePath = [NSString stringWithFormat:@"%@/%@.txt",[paths firstObject],key];
    return filePath;
}

#pragma mark action 读取文件
+ (id )readDataFromKey:(NSString *)key{
    if (!key) {
        return nil;
    }
    //因为这里涉及到了内存的问题，如果统计需求过多，都存到内存中，会增大内存的压力，这时可以采用磁盘写入，但是磁盘的 I/O 操作
    __block NSDictionary * dict = nil;
    //读内存
    dict = [MitAnalyseManager.analyseCache objectForKey:key];
    if (dict) {
        NSLog(@"从内存中读取");
        return dict;
    }
    //读磁盘
    NSString * filePath = [MitAnalyse filePathForKey:key];
    if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        NSLog(@"从磁盘中读取");
        NSData * fileData = [[NSFileManager defaultManager]contentsAtPath:filePath];
        NSError* errr = nil;
        dict = [NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingMutableContainers error:&errr];
        if (errr) {
            NSLog(@"%@",errr.description);
        }
        if (fileData) {
            [MitAnalyseManager.analyseCache setObject:dict forKey:key];
        }
    }
    return dict;
}


#pragma mark action 读取 Json 文件
+ (void)loadJsonFile{
    NSString * urlStr = [[NSBundle mainBundle]pathForResource:kJsonFileName ofType:@"json"];
    NSData * data =[NSData dataWithContentsOfFile:urlStr];
    NSError*error = nil;
    id jsonObject=[NSJSONSerialization JSONObjectWithData:data
                                                  options:NSJSONReadingAllowFragments
                                                    error:&error];
    if (![jsonObject objectForKey:@"data"]) {
        return;
    }
    [MitAnalyse handleJsonFile:jsonObject];
}
#pragma mark action 处理 Json 文件
+ (void)handleJsonFile:(id)jsonObject{
    if ([[jsonObject objectForKey:@"data"] isKindOfClass:[NSArray class]]) {
        NSBlockOperation * handleOp = [NSBlockOperation blockOperationWithBlock:^{
                NSArray * arr = (NSArray*)[jsonObject objectForKey:@"data"];
                MitAnalyseManager.classData = [NSMutableArray arrayWithArray:arr];
        }];
        [MitAnalyseManager.queue addOperation:handleOp];
        NSBlockOperation * cacheOp = [NSBlockOperation blockOperationWithBlock:^{
            @autoreleasepool {
                for (NSDictionary * dict  in MitAnalyseManager.classData) {
                    NSString * clsName = [dict valueForKey:@"class"];
                    NSArray * arr = [dict valueForKey:@"methodList"];
                    if (arr.count>0&&clsName.length>0) {
                        for (NSDictionary * littleDict in arr) {
                            NSString * cls = [littleDict valueForKey:@"className"];
                            NSString * targetName = [littleDict valueForKey:@"target"];
                            NSString * methodName = [littleDict valueForKey:@"methodName"];
                            NSString * key = [NSString stringWithFormat:@"%@_%@_%@",cls,targetName,methodName];
                            [MitAnalyseManager writeData:littleDict forKey:key];
                        }
                    }else{
                        continue;
                    }
                }
            }
        }];
        [cacheOp addDependency:handleOp];
        [MitAnalyseManager.queue addOperation:cacheOp];
        
    } else {
        NSLog(@"数据类型错误%@",jsonObject);
    }
}


#pragma mark ------------------ CacheDelegate ------------------
-(void)cache:(NSCache *)cache willEvictObject:(id)obj{
    NSLog(@"cache release = %@",obj);
}




@end
