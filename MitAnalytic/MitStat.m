//
//  MitStat.m
//  MitAnalytic
//
//  Created by MENGCHEN on 2017/1/12.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "MitStat.h"
#import "NSString+Encryption.h"



#define MitStatManager [MitStat sharedManager]
#define kMaxFileSize 5*1024*1024//默认最大文件阈值

static NSString * const kMITFolderName = @"MITStat";//文件夹名称
static NSString * const kMITFileName = @"MITStat.txt";//文件名称
static NSString * const kMITFileZipName = @"MITStat.zip";//压缩包名称
static NSInteger kBactchIdentifier = 0;//启动时发送标识符
static CGFloat kUploadTimeInterval = 28800.0;//默认上传时间间隔
static NSString * const kLastUpdateTime = @"kLastMitStatUpload";//上传标识符
//检查是否应该上传
static inline bool shouldUpload(){
    NSTimeInterval time = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastUpdateTime] doubleValue];
    BOOL shouldCheck = ([[NSDate date] timeIntervalSince1970] - time ) > kUploadTimeInterval;
    return shouldCheck;
}
//获取时间戳
static inline NSString * timeStamp(){
    return [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
}


@interface MitStat()
/** app 版本 */
@property (nonatomic, strong) NSString * appVers;
/** appKey */
@property (nonatomic, strong) NSString * appKey;
/** 报告策略 */
@property (nonatomic, assign) MitReportPolicy policy;
/** 渠道号 */
@property (nonatomic, strong) NSString * channelId;
/** 一次性交互标识 */
@property (nonatomic, strong) NSString  * onceIdentifier;
/** 用户Id */
@property (nonatomic, strong) NSString * userId;
/** 上传时间 */
@property(nonatomic, assign) CGFloat uploadTime;

@end
@interface MitStat (OnceIdentifier)
- (void)createRandomIdentifier;
- (NSString *)onceIdentifier;
- (NSString *)uuid;
@end

@interface MitStat (FileHandle)
/**
 *  文件目录
 */
+ (NSString *)dirDoc;
/**
 *  是否存在文件
 */
+ (BOOL)existFile:(NSString *)fileName;


/**
 *  获取文件夹路径
 */
+ (NSString *)folderPath;

/**
 *  获取文件路径
 */
+ (NSString *)filePath;

/**
 *  获取压缩文件路径
 */
+ (NSString *)zipFilePath;
/**
 *  创建文件夹
 */
+ (BOOL)createFolder;
/**
 *  创建文件
 */
+ (BOOL)createFile;
/**
 *  写入文件
 */
+ (void)writeToFile:(NSString *)stringData;
- (void)writeData:(NSString *)stringData;
/**
 *  读文件
 */
+ (void)readFile;

/**
 *  删除文件
 */
+ (void)deleteFileWithPath:(NSString *)filePath;

/**
 *  上传打点文件
 */
+ (void)checkStatFile;

/**
 *  压缩文件
 */
+ (void)zipFileWithHandler:(void(^)(BOOL succeed))completion;



@end

@implementation MitStat
{
    dispatch_queue_t _queue;
    dispatch_semaphore_t _lock;
}


#pragma mark ------------------ Init ------------------

+(instancetype)sharedManager{
    static MitStat * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MitStat alloc]init];

    });
    return manager;
}

-(instancetype)init{
    if (self = [super init]) {
        //1.创建打点文件
        [MitStat createFolder];
        [MitStat createFile];
        //2.创建一次性交互标示
        [self createRandomIdentifier];
        //3.创建串行队列
        _queue = dispatch_queue_create("MitStatQueue", DISPATCH_QUEUE_SERIAL);
        //4.创建信号量
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}
#pragma mark - create: 获取用户 Id
- (NSString *)userId{
    if (!_userId) {
        NSString *uId = @"";
        if (_userId&&_userId.length>0) {
            uId = _userId;
        }else{
            uId = [self uuid];
        }
        _userId = uId;
    }

    return _userId;
}

#pragma mark ------------------ Action ------------------
#pragma mark action 设置渠道号，设置用户 ID
+ (void)MitStatWithChannelId:(NSString *)channelId UserId:(NSString *)userId{
    MitStatManager.channelId = channelId;
    MitStatManager.userId = userId;
    MitStatManager.policy = SEND_INTERVAL;
}
#pragma mark action 开始打点
+ (void)startStat{
    [MitStat checkStatFile];
}
#pragma mark action 设置上传策略
+(void)setPolicy:(MitReportPolicy)policy{
    MitStatManager.policy = policy;
}
#pragma mark action 设置应用版本
+(void)setAppVersion:(NSString *)appVersion{
    MitStatManager.appVers = appVersion;
}
#pragma mark action 设置用户 ID
+(void)setUserId:(NSString *)userId{
    MitStatManager.userId = userId;
}
#pragma mark action 设置渠道号
+(void)setChannelId:(NSString *)channelId{
    MitStatManager.channelId = channelId;
}
#pragma mark action 设置上传间隔
+(void)setUpLoadMinTime:(CGFloat)duration{
    kUploadTimeInterval = duration;
}

#pragma mark ------------------ 打点方法 ------------------
+(void)statWithAnalyseData:(NSDictionary *)dict{
    [MitStatManager statWithAnalyseData:dict];
}
- (void)statWithAnalyseData:(NSDictionary *)dict{
//    NSLog(@"策略内打点:%@",dict);
    __block NSString * detail = [NSString stringWithFormat:@"onceIdentifier=%@|userId=%@|timeStamp=%@|",self.onceIdentifier,self.userId,timeStamp()];
    NSInteger total = [dict allKeys].count;
    NSInteger num = 0;
    for (NSString * key in [dict allKeys]) {
        num++;
        id obj = [dict valueForKey:key];
        if (num < total) {
            detail = [NSString stringWithFormat:@"%@%@=%@|",detail,key,obj];
        }else{
            detail = [NSString stringWithFormat:@"%@%@=%@",detail,key,obj];
            dispatch_semaphore_signal(_lock);
        }
    }
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
//    NSLog(@"统计详情 = %@",detail);
    [MitStatManager writeData:detail];
    
}
+(void)statWithOtherData:(NSDictionary *)dict{
//    NSLog(@"策略外打点:%@",dict);

    [MitStatManager statWithOtherData:dict];
    
}

- (void)statWithOtherData:(NSDictionary *)dict{
    __block NSString * detail = [NSString stringWithFormat:@"onceIdentifier=%@|userId=%@|timeStamp=%@|",self.onceIdentifier,self.userId,timeStamp()];
    NSInteger total = [dict allKeys].count;
    NSInteger num = 0;
    for (NSString * key in [dict allKeys]) {
        num++;
        id obj = [dict valueForKey:key];
        if (num < total) {
            detail = [NSString stringWithFormat:@"%@%@=%@|",detail,key,obj];
        }else{
            detail = [NSString stringWithFormat:@"%@%@=%@",detail,key,obj];
            dispatch_semaphore_signal(_lock);
        }
    }
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [MitStatManager writeData:detail];
}

@end


@implementation MitStat (OnceIdentifier)
#pragma mark - OnceIdentifier: 创建随机一次性交互标识
- (void)createRandomIdentifier{
    if (self.onceIdentifier&&self.onceIdentifier.length>0) {
        return;
    }
    NSString * fromString = @"";
    if (self.userId) {
        fromString = [[NSString stringWithFormat:@"%@%.0f",self.userId,[[NSDate date] timeIntervalSince1970]] MD5String];
    }else{
        fromString = [[NSString stringWithFormat:@"%@%.0f",[self uuid],[[NSDate date] timeIntervalSince1970]] MD5String];
    }
    self.onceIdentifier = [fromString length] > 16 ? [fromString substringWithRange:NSMakeRange(0, 16)] : fromString;
}
#pragma mark - OnceIdentifier: 获取一次性标识符
-(NSString *)onceIdentifier{
    if (!_onceIdentifier) {
        NSString * fromString = @"";
        if (self.userId) {
            fromString = [[NSString stringWithFormat:@"%@%.0f",self.userId,[[NSDate date] timeIntervalSince1970]] MD5String];
        }else{
            fromString = [[NSString stringWithFormat:@"%@%.0f",[self uuid],[[NSDate date] timeIntervalSince1970]] MD5String];
        }
        _onceIdentifier = [fromString length] > 16 ? [fromString substringWithRange:NSMakeRange(0, 16)] : fromString;
    }
    return _onceIdentifier;
}

-(NSString *)uuid{
    return [[NSUUID UUID] UUIDString];
}
@end


@implementation MitStat (FileHandle)
#pragma mark - 文件: 获取 Document 目录
+ (NSString *)dirDoc{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}
#pragma mark - 文件: 是否存在文件
+ (BOOL)existFile:(NSString *)fileName{
    NSFileManager * manager = [NSFileManager defaultManager];
    BOOL res = [manager fileExistsAtPath:fileName];
    NSLog(@"是否存在文件 = %d",res);
    return res;
}
#pragma mark - 文件: 获取文件夹路径
+ (NSString *)folderPath{
    NSString *documentDir = [MitStat dirDoc];
    NSString * filePath = [documentDir stringByAppendingPathComponent:kMITFolderName];
    return filePath;
}
#pragma mark - 文件: 获取文件路径
+ (NSString *)filePath{
    NSString * documentDir = [MitStat dirDoc];
    NSString * filePath = [documentDir stringByAppendingPathComponent:kMITFolderName];
    filePath = [filePath stringByAppendingString:@"/"];
    filePath = [filePath stringByAppendingString:kMITFileName];
    return filePath;
}
#pragma mark - 文件: 获取压缩文件路径
+ (NSString *)zipFilePath{
    NSString *documentDir = [MitStat dirDoc];
    NSString * filePath = [documentDir stringByAppendingPathComponent:kMITFolderName];
    filePath = [filePath stringByAppendingString:@"/"];
    filePath = [filePath stringByAppendingString:kMITFileZipName];
    return filePath;
}

#pragma mark - 文件: 创建文件夹
+ (BOOL)createFolder{
    NSString * documentsPath = [self dirDoc];
    NSString * testDirectory = [documentsPath stringByAppendingPathComponent:kMITFolderName];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    // 创建目录
    BOOL res = [fileManager createDirectoryAtPath:testDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    if (res) {
        NSLog(@"文件夹创建成功");
        res = true;
    }else{
        NSLog(@"文件夹创建失败");
        res = false;
    }
    return res;
}

#pragma mark - 文件: 创建文件夹回调
+ (void)createFolderWithHandler:(void(^)(BOOL succeed))completion{
    if (completion) {
        completion([MitStat createFolder]);
    }
    
}
#pragma mark - 文件: 创建文件
+ (BOOL)createFile{
    BOOL res = false;
    NSFileManager * fileManager = [NSFileManager defaultManager];
    res = [fileManager createFileAtPath:[MitStat filePath] contents:nil attributes:nil];
    if (res) {
        NSLog(@"文件创建成功: %@" ,[MitStat filePath]);
        res = true;
    }else{
        NSLog(@"文件创建失败:%@",[MitStat filePath]);
        res  = false;
    }
    return res;
}
#pragma mark - 文件: 创建文件回调
+ (void)createFileWithHandler:(void(^)(BOOL succeed))completion{
    if (completion) {
        completion([MitStat createFile]);
    }
}

#pragma mark - 文件: 写入文件
+(void)writeToFile:(NSString *)stringData{
    [MitStatManager writeData:stringData];
}
- (void)writeData:(NSString *)stringData{
    dispatch_async(_queue, ^{
        NSString * content= [NSString stringWithFormat:@"%@",stringData];
        NSLog(@"打点数据  %@",content);
        //创建文件成功，写入文件
        NSFileHandle * fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:[MitStat filePath]];
        [fileHandle seekToEndOfFile];
        NSData * stringDat  = [content dataUsingEncoding:NSUTF8StringEncoding];
        [fileHandle writeData:stringDat];
        [fileHandle closeFile];
        //检查文件大小是否超过阈值，如果超过启动上传逻辑
        NSError * err = nil;
        NSFileManager* manager = [NSFileManager defaultManager];
        unsigned long long size = [[manager attributesOfItemAtPath:[MitStat filePath] error:&err] fileSize];
        if (size > kMaxFileSize) {
            [MitStat upLoadFile];
        }        
    });
}
#pragma mark - 文件: 读文件
+ (void)readFile{
    NSError * error = nil;
    NSString * content=[NSString stringWithContentsOfFile:[MitStat filePath] encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@",error.description);
    }else{
        NSLog(@"文件读取成功 \n 内容 = %@",content);
    }
}

#pragma mark - 文件: 删除文件
+ (void)deleteFileWithPath:(NSString *)filePath{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSLog(@"filePath = %@",filePath);
    //如果文件存在，删除
    if ([fileManager isExecutableFileAtPath:filePath]) {
        BOOL res=[fileManager removeItemAtPath:filePath error:nil];
        if (res) {
            NSLog(@"文件删除成功");
        }else{
            NSLog(@"文件删除失败");
        }
    }else{
        NSLog(@"没找到文件");
    }
}

#pragma mark  - 文件：上传文件
+ (void)upLoadFile{
    NSLog(@"%s",__func__);
    //如果成功，那么重置时间，并且删除文件和压缩包。
    NSData *fileSize =[NSData dataWithContentsOfFile:[MitStat filePath]];
    if (fileSize.length == 0) {
        return;
    }
    
    //网络请求代码逻辑
    NSLog(@"开始上传文件");
    
    
    
    
    //是否上传成功，上传成功删除文件
    BOOL uploadSucceed = false;
    if (uploadSucceed) {
        NSLog(@"上传打点文件成功");
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] forKey:kLastUpdateTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [MitStat deleteFileWithPath:[MitStat folderPath]];
    } else {
        NSLog(@"上传打点文件失败");
        NSFileManager * manager = [NSFileManager defaultManager];
        if ([manager isExecutableFileAtPath:[MitStat zipFilePath]]) {
            if ([manager isDeletableFileAtPath:[MitStat zipFilePath]]) {
                NSLog(@"删除 zip 文件成功");
            } else {
                NSLog(@"删除 zip 文件失败");
            }
        }
    }

}
#pragma mark - 文件：压缩文件
+ (void)zipFileWithHandler:(void(^)(BOOL succeed))completion{
    //压缩成功之后上传
//        if ([SSZipArchive createZipFileAtPath:[self zipFilePath] withFilesAtPaths:@[[MitStat filePath]]]) {
//            completion(true);
//        }else{
//            completion(false);
//        }
    if (1) {
        completion(true);
    }else{
        completion(false);
    }
}

#pragma mark - 文件：检查文件
+ (void)checkStatFile{
    /**
     *  默认每隔 8 小时上传文件
     */
    //如果有开启上传策略
    if ((MitStatManager.policy & BATCH) !=0&&kBactchIdentifier == 0) {
        kBactchIdentifier ++;
        [MitStat zipFileWithHandler:^(BOOL succeed) {
            if (succeed) {
                NSLog(@"压缩成功，开始上传");
                [MitStat upLoadFile];
            }
        }];
        return;
    }
    
    //如果有间隔上传策略
    if ((MitStatManager.policy & SEND_INTERVAL)!=0) {
        [MitStat checkIntervalUpload];
    }
}

#pragma mark action 启动间隔上传
+ (void)checkIntervalUpload{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kLastUpdateTime] ) {
        NSLog(@"有最后一次的字段");
        if (shouldUpload()) {
            //压缩文件
            [MitStat zipFileWithHandler:^(BOOL succeed) {
                if (succeed) {
                    NSLog(@"压缩成功，开始上传");
                    [MitStat upLoadFile];
                }
            }];
        }
    } else {
        NSLog(@"没有最后一次的字段");
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] forKey:kLastUpdateTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}




@end
