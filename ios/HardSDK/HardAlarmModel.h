//
//  HardAlarmModel.h
//  HardManagerSDK
//
//  Created by xianfei zou on 2019/11/19.
//  Copyright © 2019 xianfei zou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HardAlarmFlag) {
    HardAlarmSunday     = 0x1,       // 周日
    HardAlarmMonday     = 0x1 << 1,  // 周一
    HardAlarmTuesday    = 0x1 << 2,  // 周二
    HardAlarmWednesday  = 0x1 << 3,  // 周三
    HardAlarmThursday   = 0x1 << 4,  // 周四
    HardAlarmFriday     = 0x1 << 5,  // 周五
    HardAlarmSaturday   = 0x1 << 6,  // 周六
    
    /// 整周
    HardAlarmWholeWeek = HardAlarmSunday | HardAlarmMonday | HardAlarmTuesday | HardAlarmWednesday | HardAlarmThursday | HardAlarmFriday | HardAlarmSaturday
};

@interface HardAlarmModel : NSObject
/**
 闹钟周提醒设置
 可多选, 如周一、周二、周五启用闹钟提醒，传入  <HardAlarmMonday | HardAlarmTuesday | HardAlarmFriday> 即可
 */
@property (nonatomic, assign) HardAlarmFlag flag;

/**
 闹钟设置
    普通闹钟 - 最多5个闹钟，传参范围：0 ~ 4
    喝水提醒闹钟 - 最多8个闹钟，传参范围：0 ~ 8
 
    alarmID :代表闹钟编号以及顺序
 */
@property (nonatomic, assign) NSInteger alarmID;
/// 打开或关闭
@property (nonatomic, assign) BOOL powerOn;
/// 闹钟时间，小时数*60 + 分钟数， 如设置闹钟提醒时间为 10:35 应传入635， 24小时制
@property (nonatomic, assign) NSInteger time;

// 以下SDK内部调用使用，可忽略
-(BOOL)sun;
-(BOOL)mon;
-(BOOL)tue;
-(BOOL)wed;
-(BOOL)thu;
-(BOOL)fri;
-(BOOL)sat;

@end

NS_ASSUME_NONNULL_END
