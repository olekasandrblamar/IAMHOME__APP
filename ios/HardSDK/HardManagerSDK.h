//
//  HardManagerSDK.h
//  HardManagerSDK
//
//  Created by xianfei zou on 2019/11/19.
//  Copyright © 2019 xianfei zou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "HardDefine.h"
#import "HardAlarmModel.h"
#import "HardExerciseModel.h"
#import "HardItemModel.h"

@class HardManagerSDK;

@protocol HardManagerSDKDelegate <NSObject>

@optional

-(void)didFindDevice:(CBPeripheral *)device;
-(void)didFindDeviceDict:(NSDictionary *)deviceDict;

-(void)deviceDidConnected;
-(void)deviceDidDisconnected;

-(void)settingFallBack:(HardSettingOption)option status:(HardOptionStatus)status;
-(void)gettingFallBack:(HardGettingOption)option values:(NSDictionary *)values;


/// 已连接设备的MAC地址已更新
-(void)connectedDeviceMacDidUpdate:(HardManagerSDK *)manager;
/// 已获得链接设备的固件版本
-(void)connectedDeviceFirmwareVersionDidReceived:(HardManagerSDK *)manager;

/**
 固件升级已完成步骤以及执行回执
 @param step 当前已执行步骤，
 @param result 执行结果
 */
-(void)hardManager:(HardManagerSDK *)manager firmwareUpgradeStep:(HardFirmwareUpgradeStep)step result:(HardFirmwareUpgradStepResult)result;
/// 固件升级即将执行下一个步骤
-(void)hardManager:(HardManagerSDK *)manager firmwareUpgradeNextStep:(HardFirmwareUpgradeStep)step;

/// 相机事件
-(void)hardManager:(HardManagerSDK *)manager receiveCommandWithCameraAction:(HardCameraActionType)action;

@end



typedef void(^temperatureMeasureDisturb)(BOOL disturb);
typedef void(^temperatureDanger)(BOOL Danger);

@interface HardManagerSDK : NSObject

@property (nonatomic,weak) id<HardManagerSDKDelegate>delegate;

/// 协议回调队列， Nil时默认在主线程回调
@property (nonatomic,weak) dispatch_queue_t delegateCallBackQueue;

/**
 当前已连接蓝牙设备的MAC地址
 
 当连接设备时并不会马上更新，成功连接设别后，会调用协议 HardManagerSDKDelegate —> connectedDeviceMacDidUpdate:(HardManagerSDK *)hardManager
 当断开连接时会置为nil（调用 HardManagerSDKDelegate —>  deviceDidDisconnected 之前便会置为nil）
 */
@property (nonatomic, copy, getter=getConnectedDeviceMAC) NSString *connectedDeviceMAC;
/// 已连接设备的固件版本，当设备已连接回调时，不一定会又值，拿到固件版本后会调用     -(void)connectedDeviceFirmwareVersionDidReceived:(HardManagerSDK *)manager;
@property (nonatomic, copy, getter=getFirmwareVersion) NSString *firmwareVersion;

#pragma mark - bool value

/// 蓝牙是否已打开
@property (nonatomic, assign) BOOL isPowerOn;
/// 设备是否已连接
@property (nonatomic, assign) BOOL isConnected;
/// 数据是否同步中
@property (nonatomic, assign) BOOL isSyncing;
/// 心率是否测量中
@property (nonatomic, assign) BOOL isMeasuring;

#pragma mark - ble action

+(instancetype)shareBLEManager;


/**
搜索设备，返回带温度的广播内容。需要传入广播手环系列数组，例如ABC、XYZ手环，则数组为@[@"ABC",@"XYZ"]，如不需要，可穿nil
*/
-(void)scanDevices:(NSArray *)bandSers;
/**
停止搜索设备
*/
-(void)stopScanDevice;
/**
连接设备
 @param uuid  传入手环UUID
*/
-(void)startConnectDeviceWithUUID:(NSString *)uuid;
/**
断开蓝牙设备
*/
-(void)disconnectHardDevice;

#pragma mark - getting action

/// 获取设备电量
-(void)getHardBattery;

/// 查找设备
-(void)getHardBandAction;

/// 恢复出厂设置
- (void)restoreFactorySettings;

/**
获取计步数据（包含总览、以及详情信息）
 @param daysAgo  0->今天 1->昨天...以次类推
*/
-(void)getHardStepDaysAgo:(int)daysAgo;
/**
获取睡眠数据
 @param daysAgo  0->今天 1->昨天...以次类推
*/
-(void)getHardSleepDaysAgo:(int)daysAgo;
/**
获取心率数据
 @param daysAgo  0->今天 1->昨天...以次类推
*/
-(void)getHardHeartDaysAgo:(int)daysAgo;
/**
获取锻炼数据
 @param date  获取传入日期之后的锻炼数据
*/
-(void)getHardExerciseWithDate:(NSDate *)date;
/**
获取实时温度
*/
-(void)getHardCurrentTemperature;
/**
@param date  获取传入日期之后的直接温度历史数据
*/
-(void)getHardHistoryRealTemperature:(NSDate *)date;
/**
@param date  获取传入日期之后的直接温度历史数据
@prarm deadline 停止接收数据时间，时间后的不再处理
*/
-(void)getHardHistoryRealTemperature:(NSDate *)date deadline:(NSDate *)deadline;
/**
@param date  获取传入日期之后测出人体的温度历史数据
*/
-(void)getHardHistoryBodyTemperature:(NSDate *)date;
/**
@param date  获取传入日期之后测出人体的温度历史数据
@prarm deadline 停止接收数据时间，时间后的不再处理，
*/
-(void)getHardHistoryBodyTemperature:(NSDate *)date deadline:(NSDate *)deadline;;
/**
从这里查询手环缺失的UI文件
*/
-(void)getHardBandImageFileNeeded;
/*
获取事件提醒集合
*/
-(void)getHardEventItem;

#pragma mark - setting action

/**
设置翻腕亮屏
 @param isOpen  开关
 @param left  左右佩戴
*/
-(void)setHardWristStatus:(BOOL)isOpen leftHand:(BOOL)left;
/**
 手环复位
*/
-(void)setHardRebootAction;
/**
设置亮屏时长
 @param screenOnTime  亮屏时长，单位：s
*/
-(void)setHardScreenOnTime:(int)screenOnTime;
/**
设置勿扰
 @param disturbTimeSwitch  开关
 @param startTime  开始时间，例：上午10:23 -->623
 @param endTime  结束时长
*/
-(void)setHardDistrub:(BOOL)disturbTimeSwitch startTime:(int)startTime endTime:(int)endTime;
/**
设置基本信息
 @param is12  12小时制
 @param isMeter  公英制
 @param sex  用户性别 男->1 女->0
 @param age  年龄
 @param weight  体重 单位:kg
 @param height  身高 单位:cm
 @param sbp 收缩率
 @param dbp 扩张率
 @param heartWarning 心率预警值
 @param chol 胆固醇
*/
-(void)setHardTimeUnitAndUserProfileIs12:(BOOL)is12 isMeter:(BOOL)isMeter sex:(int)sex age:(int)age weight:(int)weight height:(int)height sbp:(int)sbp dbp:(int)dbp heartWarning:(int)heartWarning chol:(float)chol;
/**
开启全天心率
 @param isAuto  开关
*/
-(void)setHardAutoHeartTest:(BOOL)isAuto;
/**
设置目标步数，卡路里，距离
 @param step  步数 单位:步
 @param calories  卡路里 单位:cal
 @param distance  距离 单位:米
*/
-(void)setHardTarget:(int)step calories:(int)calories distance:(int)distance;

/**
设置久坐
 @param isOpen  开关
 @param interval  间隔时长 单位:分钟
 @param startTime  开始时间，例：上午10:23 -->623
 @param endTime  结束时长
 @param flag  周期 例如周日打开flag二进制为0000 0001 ， 周日周三周四打开flag二进制为 0001 1001 ，全打开为0111 1111
*/
-(void)setHardSedentaryRemindCommand:(BOOL)isOpen interval:(int)interval startTime:(int)startTime endTime:(int)endTime flag:(int)flag;
/**
设置闹钟
 @param alarms  闹钟集合（最多支持5个闹钟）
*/
-(void)setHardAlarms:(NSArray <HardAlarmModel*> *)alarms;
/**
设置饮水提醒
 @param alarms  饮水闹钟集合（最多支持8个闹钟）
*/
-(void)setHardDrinkAlarm:(NSArray <HardAlarmModel*> *)alarms;
/**
设置消息推送开关（必须配对后才生效）
*/
-(void)setHardNotificationPhoneCall:(BOOL)call message:(BOOL)message qq:(BOOL)qq wechat:(BOOL)wechat facebook:(BOOL)facebook whatsApp:(BOOL)whatsApp twitter:(BOOL)twitter skype:(BOOL)skype line:(BOOL)line linkedln:(BOOL)linkedln instagram:(BOOL)instagram tim:(BOOL)tim snapchat:(BOOL)snapchat other:(BOOL)other;
/**
设置温度单位
 @param isF 华氏度
*/
-(void)setHardTemperatureType:(BOOL)isF;
/**
设置天气
 @param serial 本条天气的序号 （例如当前共发送5天的天气，序号为0~4）
 @param date 日期，格式为yyyy-MM-dd
 @param weatherType 0=未知，1=晴，2=多云，3 =雨，4=雪，5=雾霾，6=雷电
 @param temMin 最低温度 (带符号，范围-128~127)
 @param temMax 最高温度 (带符号，范围-128~127)
 @param wet 湿度 (0~100)
 @param umbralle 是否带伞
*/
-(void)setHardWeatherSerial:(int)serial date:(NSString *)date weatherType:(int)weatherType temMin:(NSInteger)temMin temMax:(NSInteger)temMax wet:(int)wet umbralle:(BOOL)umbralle;
/**
设置当前气压
 @param pressure 当前气压
*/
-(void)setHardPressure:(NSInteger)pressure;
/**
设置节拍器
 @param bpm 次/分钟
*/
-(void)setHardMetronome:(NSInteger)bpm;
/**
开始体温测量
*/
-(void)setHardBodyTemperatureMeasurement;
/**
设置全天体温检测
 @param power 开关
*/
-(void)setHardAllDayTemperature:(BOOL)power;
/**
获取腋下温度
 @param second 0->开始 -1->结束 其余正数均为发给手环的秒数
*/
-(void)setStartArmTemperatureTesting:(NSInteger)second;
/**
心率数据一键测量
*/
-(void)setStartHeartMeasurement;
/**
血压数据一键测量，注意：一定需要传入用户数据后才有值。否则只有心率数据
*/
-(void)setStartBloodPressureMeasurement;
/**
血氧数据一键测量，注意：一定需要传入用户数据后才有值。否则只有心率数据
*/
-(void)setStartBloodOxygenMeasurement;
/*
血糖数据一键测量
 */
-(void)setStartBloodSugerMeasurement;
/*
胆固醇数据一键测量
 */
-(void)setStartCholesterolMeasurement;
/*
 @param app  app类型
 0：来电提醒 1：短信提醒 2：QQ提醒 3：微信提醒 4：来电接听或挂电话 5：Facebook消息提醒 6：WhatsApp消息提醒 7：Twitter消息提醒 8：Skype消息提醒 9：Line消息提醒 10: Linkedln 11: Instagram 12: TIM消息 13: Snapchat 14: others其它类型通知
 @param message 推送的消息,不可为空
 
 iOS调用对应提醒前，需要将对应App的消息推送开关打开，否则可能不生效
 */
-(void)setPushNoti:(NSInteger)app message:(NSString *)message;

/**
设置事件
 @param items  事件集合
*/
-(void)setHardEvenItems:(NSArray <HardItemModel *>*)items;
/**
测量血糖、胆固醇结束后返回到手环的数据
  @param type 1->心率 2->血压 3->血氧 4->血糖 5->胆固醇 (此接口目前只接受血糖，胆固醇的结果返回)
  @param result 返回到手环的数据 如需要显示值为5.13，则传入的值为513;
*/
-(void)hardSetMeasurementResultWithType:(HardMeasureType)type result:(NSInteger)result;


/// 显示设备的相机控制视图
- (void)setShowCamereControl;
/// 退出设备的相机控制视图
- (void)setDismissCamereControl;
/// 保持设备不熄屏（为了设备保持相机控制功能，需要重复调用此方法，建议3 ~ 4秒调用一次）
- (void)setCameraControlKeepingLight;

@end


#pragma mark - 升级相关：固件升级，UI、语言文件传输
@interface HardManagerSDK (Upgrade)

/**
 尝试升级固件
 @param filePath 固件升级文件（xxxx.bin）
 @param error 文件路径初步检测的错误信息
 */
-(void)setUpgradeDeviceFirmwareWithFilePath:(NSString *)filePath error:(NSError **)error;

/**
传输语言文件前调用，否则手环有可能复位
  @param language zh、en、fr、es、ru、ja、pt、de、it、ar
*/
-(void)setReadyTransportLanguage:(NSString *)language error:(NSError **)error;
/**
传输UI文件、语言文件通道
  @param filePath 本地文件路径
*/
-(void)setStartTransportLocalFile:(NSString *)filePath error:(NSError **)error;

@end

#pragma mark - 风格自定义
@interface HardManagerSDK (DIY)

/**
设置表盘背景图 — 状态回调同UI -(void)setStartTransportLocalFile
 @param image 图片大小必须是特定像素大小，目前UMG手环需使用240x240
 */
- (void)setDiyBackgroundImage:(UIImage *)image error:(NSError **)error;

/**
跳转可自定义表盘页
 */
- (void)showDiyBackgroundPage;

@end
