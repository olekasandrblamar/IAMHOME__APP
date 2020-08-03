//
//  HardAlarmModel.h
//  HardManagerSDK
//
//  Created by xianfei zou on 2019/11/19.
//  Copyright © 2019 xianfei zou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HardAlarmModel : NSObject

@property (nonatomic,assign)NSInteger alarmID;

@property (nonatomic,assign)NSInteger powerOn;

@property (nonatomic,assign)NSInteger flag;

@property (nonatomic,assign)NSInteger time;

-(BOOL)sun;

-(BOOL)mon;

-(BOOL)tue;

-(BOOL)wed;

-(BOOL)thu;

-(BOOL)fri;

-(BOOL)sat;

@end

NS_ASSUME_NONNULL_END
