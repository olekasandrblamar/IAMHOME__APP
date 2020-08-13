//
//  HardItemModel.h
//  HardManagerSDK
//
//  Created by xianfei zou on 2020/6/23.
//  Copyright © 2020 xianfei zou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HardItemModel : NSObject

@property (nonatomic,assign)NSInteger itemID;

@property (nonatomic,assign)NSInteger powerOn;

@property (nonatomic,assign)NSInteger message;

@property (nonatomic,assign)NSInteger time;

@end

NS_ASSUME_NONNULL_END
