//
//  FingerDrawLineView.h
//  BaiDuMapDemo
//
//  Created by 朱佳男 on 2018/5/1.
//  Copyright © 2018年 朱佳男. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FingerDrawLineViewDelegate<NSObject>
-(void)fingerDrawLineViewEndTouchWithPointArray:(NSArray *)pointArray;
@end;
@interface FingerDrawLineView : UIView
@property (nonatomic ,weak)id<FingerDrawLineViewDelegate>delegate;
/**
 线段颜色
 */
@property (nonatomic ,strong)UIColor *lineColor;

/**
 线段宽度
 */
@property (nonatomic ,assign)CGFloat lineWidth;

/**
 清空所画线段
 */
-(void)clearLine;
@end
