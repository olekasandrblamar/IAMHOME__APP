typedef NS_ENUM(NSInteger, HardGettingOption) {
    /// 获取电量
    HardGettingBattery = 0,
    /// 获取步数信息（包含总览、每小时数据）
    HardGettingStep,
    /// 获取睡眠数据
    HardGettingSleep,
    /// 获取Heard相关
    HardGettingHeart,
    /// 锻炼数据
    HardGettingExercise = 5, // 5
    /// 获取体温
    HardGettingBodyTemperature,
    /// 获取腕温
    HardGettingArmTemperature,
    /// 体温过高提醒
    HardGettingBodyTemperatureTooHigh,
    /// 体温测量结束
    HardGettingBodyTemperatureMeasurementEnd,
    /// 体温历史记录
    HardGettingBodyTemperatureHistory = 10, // 10
    ///
    HardGettingRealTemperatureHistory,
    HardGettingMeasurementStart,
    /// 心率测量中，通过此项返回数据
    HardGettingMeasuring,
    /// 心率测量结束
    HardGettingMeasurementEnd = 15,
    /// 心率测量错误，大部分错误的原因都是未佩戴手环
    HardGettingMeasurementError,
    HardGettingItemsList,
    /// 升级固件进度
    HardGettingFirmworkUpgradeProgress,
    /// 需要传输的UI数据
    HardGettingUIFilesNeeded,
    /// 文件传输进度
    HardGettingFileTransportProgress,
};

typedef NS_ENUM(NSInteger, HardSettingOption) {
    /// 设置时间
    HardSettingTime,
    /// 设置闹钟
    HardSettingAlarms,
    /// 设置目标
    HardSettingTarget,
    /// 设置天气
    HardSettingWeather,
    /// 设置勿扰模式
    HardSettingDistrub,
    /// 设置气压
    HardSettingPressure,
    /// 设置节拍器
    HardSettingMetronome,
    /// 设置饮水提醒
    HardSettingDrinkAlarms,
    /// 设置翻腕
    HardSettingWristStatus,
    /// 设置亮屏时间
    HardSettingScreenOnTime,
    /// 设置消息推送
    HardSettingNotification,
    /// 设置心率自动测量
    HardSettingAutoHeartTest,
    /// 设置温度单位
    HardSettingTemperatureUnit,
    /// 设置久坐提醒
    HardSettingSedentaryRemind,
    /// 设置用户信息，公英制，时间格式
    HardSettingTimeUnitAndUserProfile,
    /// 设置温度全天测量
    HardSettingTemperatureAllDayPower,
    /// 设置事件提醒
    HardSettingItems,
    /// 开启相机遥控
    HardSettingOpenCameraControl,
    /// 关闭相机遥控
    HardSettingCloseCameraControl,
    /// 维持相机遥控
    HardSettingCameraControlKeepLight,
    
    // 语言文件传输就绪
    HardSettingLanguageTransportReady,
    // 传输文件
    HardSettingTransportFile,
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

typedef NS_ENUM(NSInteger, HardCameraActionType) {
    /// 显示照相机界面，准备拍照
    HardCameraActionTypePrepareToTakePhoto = 1,
    /// 拍照
    HardCameraActionTypeTakePhoto,
    /// 关闭相机界面，结束拍照
    HardCameraActionTypeFinished,
};

typedef NS_ENUM(NSInteger, HardFirmwareUpgradeStep) {
    /// 升级开始
    HardFirmwareUpgradeStepBegin,
    /// 升级初始化
    HardFirmwareUpgradeStepInit,
    /// 固件文件传输中
    HardFirmwareUpgradeStepSending,
    /// 固件文件校验中
    HardFirmwareUpgradeStepChecking,
    /// 固件升级完成
    HardFirmwareUpgradeStepFinished,
};

typedef NS_ENUM(NSInteger, HardFirmwareUpgradStepResult) {
    /// 成功
    HardFirmwareUpgradStepResultSuccess,
    /// 数据大小错误
    HardFirmwareUpgradStepResultDataSizeWrong,
    /// 数据内容错误
    HardFirmwareUpgradStepResultDataWrong,
    /// 指令状态不符
    HardFirmwareUpgradStepResultCommandStatusMismatch,
    /// 指令格式错误
    HardFirmwareUpgradStepResultCommandFormatWrong,
    /// 设备内部错误
    HardFirmwareUpgradStepResultInternalError,
    /// 设备电量过低
    HardFirmwareUpgradStepResultBatteryTooLow,
    /// 未知错误
    HardFirmwareUpgradStepResultUnknown,
};


typedef NS_ENUM(NSInteger, HardExerciseModelType) {
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

// 测量类型
typedef NS_ENUM(NSInteger, HardMeasureType) {
    /// 心率
    HardMeasureTypeHeartRate = 1,
    /// 血压
    HardMeasureTypeBloodPressure,
    /// 血氧
    HardMeasureTypeBloodOxygen,
    /// 血糖
    HardMeasureTypeBloodGlucose,
    /// 胆固醇
    HardMeasureTypeCHOL,
};
