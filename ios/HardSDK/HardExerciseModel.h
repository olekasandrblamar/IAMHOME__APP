//
//  HardExerciseModel.h
//  HardManagerSDK
//
//  Created by xianfei zou on 2019/11/22.
//  Copyright © 2019 xianfei zou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HardDefine.h"
NS_ASSUME_NONNULL_BEGIN

@interface HardExerciseModel : NSObject



@property (nonatomic,assign)NSInteger type;

// 时间格式:yyyy-MM-dd HH:mm:ss
@property (nonatomic,copy)NSString *date;
@property (nonatomic,copy)NSString *duration;
@property (nonatomic,copy)NSString *calories;
@property (nonatomic,copy)NSString *averageHeart;
@property (nonatomic,copy)NSString *pauseTime;
// 步行以及跑步
@property (nonatomic,copy)NSString *totalSteps;
@property (nonatomic,copy)NSString *stepFrequency;
// 距离
@property (nonatomic,copy)NSString *distances;
// 数据详情
@property (nonatomic,copy)NSArray *detailList;

@end

NS_ASSUME_NONNULL_END
