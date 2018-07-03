//
//  CoordinateModel.h
//  BaiDuMapDemo
//
//  Created by 朱佳男 on 2018/6/10.
//  Copyright © 2018年 朱佳男. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface CoordinateModel : NSObject

/**
 经度
 */
@property (nonatomic ,assign)CGFloat longitude;

/**
 纬度
 */
@property (nonatomic ,assign)CGFloat latitude;
@end
