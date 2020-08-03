//
//  HardDefine.h
//  HardManagerSDK
//
//  Created by xianfei zou on 2019/11/20.
//  Copyright © 2019 xianfei zou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HardDefine : NSObject

typedef NS_ENUM(NSInteger, HardGettingOption) {
    
    HardGettingBattery,
    HardGettingStep,
    HardGettingStepDetail,
    HardGettingSleep,
    HardGettingHeart,
    HardGettingExercise, // 5
    HardGettingBodyTemperature,
    HardGettingArmTemperature,
    HardGettingBodyTemperatureTooHigh,
    HardGettingBodyTemperatureMeasurementEnd,
    HardGettingBodyTemperatureHistory, // 10
    HardGettingRealTemperatureHistory,
    HardGettingNewFirmware,
    HardGettingMeasurementStart,
    HardGettingMeasuring,
    HardGettingMeasurementEnd, // 15
    HardGettingMeasurementError,
    HardGettingFirmworkDownloadProgress,
    HardGettingFirmworkUpgradeProgress,
    HardGettingUIFilesNeeded,
    HardGettingFileTransportProgress,
    
};

typedef NS_ENUM(NSInteger, HardSettingOption) {
    
    HardSettingTime,
    HardSettingAlarms,
    HardSettingTarget,
    HardSettingWeather,
    HardSettingDistrub,
    HardSettingPressure,
    HardSettingMetronome,
    HardSettingDrinkAlarms,
    HardSettingWristStatus,
    HardSettingScreenOnTime,
    HardSettingNotification,
    HardSettingAutoHeartTest,
    HardSettingTemperatureUnit,
    HardSettingSedentaryRemind,
    HardSettingTimeUnitAndUserProfile,
    HardSettingTemperatureAllDayPower,
    HardSettingDFUResult,
    HardSettingTransportFile,
    HardSettingLanguageTransportReady,
};

typedef NS_ENUM(NSInteger, HardOptionStatus) {
    
    HardStatusError,
    HardStatusSuccess,
    
};

typedef NS_ENUM(NSInteger, HardDFUOptionStatus) {
    
    HardDFUStatusSuccess,//0
    HardDFUStatusErrorSize,
    HardDFUStatusErrorData,
    HardDFUStatusErrorState,
    HardDFUStatusErrorFormat,
    HardDFUStatusErrorFlashOperate,//5
    HardDFUStatusErrorLowerPower,
    HardDFUStatusErrorCreate,
    HardDFUStatusErrorOpen,
    HardDFUStatusErrorCrcPass,
    HardDFUStatusErrorUnknow,//10
    
};


typedef NS_ENUM(NSInteger, HardExerciseModelType)
{
    
    
    /*!  走路*/
    HardExerciseModelTypeWalk = 0x00,
    /*!  跑步*/
    HardExerciseModelTypeRun = 0x01,
    /*!  爬山*/
    HardExerciseModelTypeClimb = 0x02,
    /*!  骑行*/
    HardExerciseModelTypeRide = 0x03,
    /*!  游泳*/
    HardExerciseModelTypeSwim = 0x04,
    /*!  有氧运动*/
    HardExerciseModelTypeOxygen = 0x05,
    /*!  室内运动*/
    HardExerciseModelTypeSportInDoor = 0x06,
    /*!  潜水*/
    HardExerciseModelTypeDiving = 0x07,
    /*!  球类运动*/
    HardExerciseModelTypeBallSport = 0x08,
    /*!  计时器*/
    HardExerciseModelTypeTimer = 0x09,
    /*!  篮球*/
    HardExerciseModelTypeBasketball = 0x0a,
    /*!  羽毛球*/
    HardExerciseModelTypeBadminton = 0x0b,
    /*!  足球*/
    HardExerciseModelTypeFootball = 0x0c,
    /*!  码表*/
    HardExerciseModelTypeStopWatch = 0x0d,
    /*!  无*/
    HardExerciseModelTypeNone = 0x0e,
    /*!  网球*/
    HardExerciseModelTypeTennis = 0x0f,
    /*!  挥拍*/
    HardExerciseModelTypeHuiPai = 0x10,
    /*!  健身*/
    HardExerciseModelTypeBodyBuilding = 0x11,
    /*!  跳绳*/
    HardExerciseModelTypeRopeSkipping = 0x12,
    
};

@end
