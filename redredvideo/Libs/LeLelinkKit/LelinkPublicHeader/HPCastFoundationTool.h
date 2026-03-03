//
//  HPCastFoundationTool.h
//  HPBaseLibrary
//
//  Created by Moss1on on 2017/6/23.
//  Copyright © 2017年 HPPlay. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HPCastKeyChainStore : NSObject

@end

//@interface LBAddressManager : NSObject
//+ (void )getMacAddressFromMDNS;
//@end

#import <net/if_dl.h>
#define DUMMY_MAC_ADDR @"02:00:00:00:00:00"
NS_ASSUME_NONNULL_BEGIN
@interface Address : NSObject
+ (nullable NSString *)currentIPAddressOf: (nonnull NSString *)device;
+ (nullable NSString *)IPv4Ntop: (in_addr_t)addr;
+ (in_addr_t)IPv4Pton: (nonnull NSString *)IPAddr;
@end


@interface HPCastFoundationTool : NSObject

/**
 获取设备型号
 
 @return 设备型号
 */
+ (NSString *)getDeviceModel;

/**
 获取设备名称
 
 @return 设备名称
 */
+ (NSString *)getIphoneName API_UNAVAILABLE(macos);

/// 获取电脑的名称
+ (NSString *_Nullable)getMacName API_UNAVAILABLE(ios);

/**
 获取手机的Mac地址
 
 @return 返回手机的Mac地址
 */
+ (nullable NSString *)getMacAddress;

/**
 获取mac地址新方法

 @return mac地址
 */
+ (NSString *)getMacAddressNew;

/**
 获取手机版本
 
 @return 返回手机版本
 */
+ (NSString *)getIphoneVersion API_UNAVAILABLE(macos);

/// 获取mac版本
+ (NSString *)getMacVersion API_UNAVAILABLE(ios);

/**
 获取ip
 
 @return 返回设备ip
 */
+ (NSString *)getDeviceIPAddress;

/// 用户房间权益  埋点上报用
/// @param membershipType 权益类型 "0:未知；1:会员权益;2:体验权益;3:赠送时长权益;
+ (void)setRoomMembershipType:(NSString *)membershipType;

/// 获取用户房间权益类型  埋点上报用
+ (NSString *)getRoomMembershipType;

/// 是否相同网段
/// @param tvIp tvip
+ (BOOL)isSameNetworkWithIpString:(NSString *)tvIp;
/**
 获取CPU总数目
 
 @return CPU数
 */
+ (NSUInteger)getCPUCount;

/**
 获取系统总内存空间
 
 @return 系统总内存
 */
+ (int64_t)getTotalMemory;

/**
 获得UUID
 
 @return UUID
 */
+ (NSString *)getUUID;

/**
 获取client id
 
 IOS:cut+UUID+bundleid 大写后md5大写（16字节生成）取32位LONG型 hashcode
 cut:1 安卓  2iOS
 @return cu
 */
+ (NSString *)getCU;

/**
 获取sdid
 
 生成规则： md5(当前时间戳 + 随机数 + 本地ip)
 @return sdid
 */
+ (NSString *)getSdid;

/**
 获取client id
 
 IOS:cut+UUID+bundleid 大写后md5（16位）转64位long
 cut:1 安卓  2iOS

 @return cu
 */
+ (NSString *)getCU64;

/// 保存从服务器下发的client id
/// @param cu64 client id
+ (void)saveCU64:(NSString *)cu64;


/// 设置appGroupId
/// @param appGroupId appGroupId
+ (void)setAppGroupId:(NSString *)appGroupId;

/// 设置当前 App 模式
/// @param appMode 0-默认模式 1-游客模式
+ (void)setAppMode:(int)appMode;

/// 获取当前 App 模式 0-默认模式 1-游客模式
+ (int)getAppMode;

/**
 获取手机的ADID
 
 @return 手机的ADID
 */
+ (NSString *)getADID;

/**
 获取本地时间戳
 
 @return 13位本地时间戳
 */
+ (NSString *)getLocal_stamp;

/**
 获取sessionid
 (cu + timestamp)大写，然后32位MD5,再转大写
 
 @return 本次连接的sessionID
 */
+ (NSString *)getSessionID;

/**
 获取bundle id
 
 @return bundle id
 */
+ (NSString *)getPackage;

/**
 32位 md5 加密
 
 @param string 需要加密的字符串
 @return 加密后返回的字符串
 */
+ (NSString *)stringToMD5:(NSString *)string;

/**
 32位 md5 加密
 
 @param data 需要加密的data
 @return 加密后返回的字符串
 */
+ (NSString *)stringToMD5WithData:(NSData *)data;

/**
 异或加密

 @param input 要加密的字符串
 @param keyCode 私钥
 @return 加密后返回的字符串
 */
+ (NSString *)stringToXOR:(NSString *)input keyCode:(NSString *)keyCode;

/**
 异或解密

 @param input 要解密的字符串
 @param key 秘钥
 @return 解密得到的字符串
 */
+ (NSString *)stringDecodeXOR:(NSString *)input keyCode:(NSString *)key;
//
///**
// 异或加密
//
// @param plainText 要加密的字符串
// @param secretKey 秘钥
// @return 加密后返回的字符传
// */
//+ (NSString *)stringXOREncryptWithPlainText:(NSString *)plainText secretKey:(NSString *)secretKey;
//
///**
// 异或解密
// */
//+ (NSString *)stringXORDeocodeWithPlainText:(NSString *)plaintext secretKey:(NSString *)secretKey;

/**
 获取WiFi名称
 
 @return 当前WiFi名称
 */
+ (nullable NSString *)getWifiName;

/**
 获取bssid

 @return 当前WiFi的bssid
 */
+ (nullable NSString *)getBssid;

/**
 获取设备硬件id
 
 @return 设备硬件id
 ios: 取得到ADID的情况：3+(ADID转大写)MD5转大写.16位md5
 取不到ADID的情况：4+（UUID转大写）MD5转大写.16位md5
 */
+ (NSString *)getHid;

/**
 获取设备硬件id
 
 @return 设备硬件id
 @param  shaStr 待转sha256的字符
 SHA256(hid+64位uid+时间戳+随机数)
 */
+ (NSString *)getMacUrlId:(NSString *_Nullable)shaStr;

/**
 获取url id
 
 @param sid 当前sessionId
 @return url id
 */
+ (NSString *)getUrlId:(NSString *_Nullable)sid;

/**
 获取媒体uuid
 
 @param sid 当前sessionId
 @param content 媒体url/data
 @return url str
 */

+ (NSString *)getMediaUuId:(NSString *)sid content:(id)content;


/// 设置SDK的版本号，如果不设置则默认为@“00000”
/// @param version 版本号
+ (void)setSDKVersion:(NSString *)version;

/**
 获取SDK的版本号

 @return SDK的版本号
 */
+ (NSString *)getSDKVersion;

/**
 获取App的版本号
 
 @return App的版本号
 */
+ (NSString *)getAppVersion;

/*
 获取 App 版本号，去掉 . 的版本号，主要用于乐播 App
 
 @return App 去掉 . 的版本号
 */
+ (NSString *)getAppCodeVersion;

/**
 获取tuid

 @return tuid，用户唯一标识
 */
+ (NSString *)getTuid;

/**
 获取bundle identifier

 @return bundle identifier
 */
+ (NSString *)getBundleIdentifier;

/**
 判断是否是乐播投屏APP

 @return YES代表是乐播投屏APP，NO代表不是
 */
+ (BOOL)isLeBoAPP;

/**
 判断是不是乐播demo

 @return YES代表是，NO代表不是
 */
+ (BOOL)isLeBoDemoApp;

/**
 判断是不是朝歌APP

 @return YES代表是，NO代表不是
 */
+ (BOOL)isSunniwellApp;

/**
 根据时区判断是否是海外，用于选择服务器

 @return YES，海外时区；NO，大陆时区。
 */
+ (BOOL)isOverseas;


/**
 获取error.userInfo里面的详细描述，必须是字典类型

 @param dictionary 数据信息
 @return 拼接后的详情描述
 */
+ (NSString *)dictionaryKeyAppendStringValue:(NSDictionary *)dictionary;

/**
 数据带有中文转义
 
 @param param 需转义的数据
 @return 返回转义后的数据
 */
+ (NSDictionary *)dictionaryContainsChina:(NSDictionary *)param;
/**
 柱形位移加密，加密和解密的列顺序必须相同

 @param forEncryptStr 待加密字符串
 @param orderStr 列顺序，注意列顺序字符串的每个字符均为0~9
 @return 加密后的字符串
 */
+ (nullable NSString *)cylindricalDisplacementEncryptWithString:(NSString *)forEncryptStr columnOrder:(NSString *)orderStr;

/**
 柱形位移加密，加密和解密的列顺序必须相同
 水兔合并版本专用（埋点2.1版本）
 @param forEncryptStr 待加密字符串
 @param orderStr 列顺序，注意列顺序字符串的每个字符均为0~9
 @return 加密后的字符串
 */
+ (nullable NSString *)wrCylindricalDisplacementEncryptWithString:(NSString *)forEncryptStr columnOrder:(NSString *)orderStr;

/**
 柱形位移解密，加密和解密的列顺序必须相同，解密用于验证加密是否OK

 @param forDecryptStr 待解密字符串
 @param orderStr 列顺序，注意列顺序字符串的每个字符均为0~9
 @return 解密后的字符串
 */
+ (nullable NSString *)cylindricalDisplacementDecryptWithString:(NSString *)forDecryptStr columnOrder:(NSString *)orderStr;

/// 字典转换json字符串，去反斜杆和空格
/// @param dict 字典
+ (nullable NSString *)convertToJsonStringWithDictionary:(NSDictionary *)dict;
+ (nullable NSString *)convertToJsonStringForParam:(id)param;


/// 获取网络状态 return 0:无网络 1:2.4Gwifi 2:5Gwifi 3:WWAN 4:热点 5:移动网络
+ (NSInteger)getNetworkStatus;

/// 获取设备剩余磁盘空间MB
+ (long)getDeviceFreeDiskSpaceInMB;


/// AES加密
/// @param conext 待加密内容
/// @param keyData 密钥data
+ (NSString *)aes128ECBEncodeConext:(NSString *)conext keyData:(NSData *)keyData;

/// AES解密
/// @param conext 待解密内容
/// @param keyData 密钥data
+ (NSString *)aes128ECBDecryptConext:(NSString *)conext keyData:(NSData *)keyData;

/// 获取签名，用于广告参数签名
/// @param dictionary 参数字典
/// @param secretKey 密钥
+ (NSString *)signDAParamsDictionary:(NSDictionary *)dictionary secretKey:(NSString *)secretKey;

/// sha256加密
/// @param str 待加密的字符串
+ (NSString *)stringToSHA256:(NSString *)str;

/// 字符大写转md5再大写
/// @param string 待加密的字符串
+ (nullable NSString *)stringToUppercaseMD5Uppercase:(NSString *)string;

/// 字符大写转sha265再大写
/// @param string 待加密的字符串
+ (nullable NSString *)stringToUppercaseSHA256Uppercase:(NSString *)string;

/**
 获取上报关系开关
 
 @return 用户是否设置手机号，YES：同意设置，NO：不同意设置
 */
+ (BOOL)getUserInfoDevicePhoneSwitch;

/**
 设置上报关系开关
 
 @param phone 手机号 （非必传）
 @param enable YES：同意设置，NO：不同意设置
 @param desensitization 脱敏手机号 （必传）
 */
+ (void)setUserInfoDevicePhone:(NSString *)phone desensitization:(NSString *)desensitization deviceSwitch:(BOOL)enable;
/**
 获取上报关系脱敏后的手机号
 
 @return SHA256脱敏后的字符
 */
+ (nullable NSString *)getUserInfoSHA256DevicePhone;
/**
 获取上报关系的手机号
 
 @return 返回手机号
 */
+ (nullable NSString *)getUserInfoDevicePhone;
/**
 查询上报后的关系脱敏后的手机号
 
 @param  shaString 脱敏的字符
 @return SHA256脱敏后的字符
 */
+ (nullable NSString *)queryUserInfoDeviceHistory:(NSString *)shaString;
/**
 AES加密
 
 @param  conext 加密参数
 @param  keyData 加密key
 @param  kInitVector 偏移量
 @return 返回加密
 */
+ (NSString *)encode128AESWithData:(NSString *)conext keyData:(NSData *)keyData kInitVector:(nullable NSString *)kInitVector;

/**
 AES解密
 
 @param  conext 加密参数
 @param  keyData 加密key
 @param  kInitVector 偏移量
 @return 返回数据
 */
+ (NSData *)decrypt128AESWithData:(NSData *)conext keyData:(NSData *)keyData kInitVector:(nullable NSString *)kInitVector;

// 计算两个时间戳的差值
// @param start   开始时间
// @param endDate 结束时间
// @return 返回时间戳的差值
+ (NSString *)timerIntervalStartDate:(NSDate *)start endDate:(NSDate *)endDate;

/// 持久化数据，保存在NSApplicationSupportDirectory
/// @param data 数据
/// @param fileName 文件名或key
+ (BOOL)saveDataToASBID:(NSData *)data withFileName:(NSString *)fileName;

/// 取数据
/// @param fileName 文件名或key
+ (NSData *)dataASBIDWithFileName:(NSString *)fileName;


/// 持久化string数据，保存在NSApplicationSupportDirectory
/// @param string string
/// @param fileName 文件名或key
+ (BOOL)saveStringToASBID:(NSString *)string withFileName:(NSString *)fileName;

/// 取string数据
/// @param fileName 文件名或key
+ (NSString *)stringASBIDWithFileName:(NSString *)fileName;

/// 判断是不是当天
+ (BOOL)checkToday:(NSDate *)date;

/// 程序是否处于后台，YES：是处于后台，NO：不处于后台(在前台)
+ (BOOL)isProgramInTheBackground;
/// SDK第一次安装启动标识
+ (void)sdkDidFinishInstal;
/// SDK是否第一次安装启动
+ (BOOL)sdkIsFirstInstall;

/// 判断是否是字符串，并且字符串是否不为空
/// @param string 目标字符串
+ (BOOL)isNotEmptyString:(NSString *_Nullable)string;

/// 判断当前数组是否不为空
/// @param array 数组
+ (BOOL)isNotEmptyArray:(NSArray *_Nullable)array;

/// 判断当前字典是否不为空
/// @param dictionary 目标字典
+ (BOOL)isNotEmptyDictionary:(NSDictionary *_Nullable)dictionary;

/// 获取物理内存大小，单位M
+ (NSInteger)getTotalPhysicalMemory;

/// 高内存设备，15pro机型，物理内存8G，获取到的内存大小7G
+ (BOOL)isHighMemory7GMoreDevice;

@end

#pragma mark - C code

#ifndef LB_OUT
#define LB_OUT
#endif

#ifndef LB_IN
#define LB_IN
#endif

/**
 柱形位移加密，加密和解密的列顺序必须相同
 
 @param forEncrypt 待加密字符串
 @param columOrder 列顺序，注意列顺序字符串的每个字符均为0~9,必须能重新排列为0~n的自然数
 @param encryptedPtr 加密后的字符串，注意，该字符串在使用后需要释放，free（）
 @return 0代表加密成功，-1代表失败
 */
int cylindricalDisplacementEncrypt(LB_IN const char * forEncrypt, LB_IN const char * columOrder, LB_OUT char *_Nullable* _Nullable encryptedPtr);

/**
 柱形位移解密，加密和解密的列顺序必须相同，解密用于验证加密是否OK
 
 @param forDecrypt 待解密字符串
 @param columOrder 列顺序，注意列顺序字符串的每个字符均为0~9,必须能重新排列为0~n的自然数
 @param decryptedPtr 解密后的字符串，注意，该字符串在使用后需要释放，free（）
 @return 0代表加密成功，-1代表失败
 */
int cylindricalDisplacementDecrypt(LB_IN const char * forDecrypt, LB_IN const char * columOrder, LB_OUT char *_Nullable* _Nullable decryptedPtr);

NS_ASSUME_NONNULL_END
