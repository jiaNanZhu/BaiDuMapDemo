//
//  FingerDrawLineView.m
//  BaiDuMapDemo
//
//  Created by 朱佳男 on 2018/5/1.
//  Copyright © 2018年 朱佳男. All rights reserved.
//

#import "FingerDrawLineView.h"
@interface FingerDrawLineView()
@property (nonatomic ,strong)NSMutableArray *pointArray;

@end
@implementation FingerDrawLineView
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _pointArray = [NSMutableArray array];
        self.layer.borderColor = [UIColor colorWithRed:192/255.0 green:153/255.0 blue:131/255.0 alpha:1].CGColor;
        self.layer.borderWidth = 4;
    }
    return self;
}

-(void)drawRect:(CGRect)rect{

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    if (self.pointArray.count>0){
        CGContextBeginPath(context);
        CGPoint startP = [self.pointArray[0] CGPointValue];
        CGContextMoveToPoint(context, startP.x, startP.y);
        for (int i =1; i <self.pointArray.count; i ++) {
            if (i != 1) {
                CGPoint lastP = [self.pointArray[i-1] CGPointValue];
                CGContextMoveToPoint(context, lastP.x, lastP.y);
            }
            CGPoint nextP = [self.pointArray[i] CGPointValue];
            CGContextAddLineToPoint(context, nextP.x,nextP.y);
            CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
            CGContextSetLineWidth(context, self.lineWidth+1);
            CGContextStrokePath(context);
        }
    }
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.pointArray removeAllObjects];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [self.pointArray addObject:[NSValue valueWithCGPoint:point]];
    
    [self setNeedsDisplay];
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [self.pointArray addObject:[NSValue valueWithCGPoint:point]];
    
    [self setNeedsDisplay];
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    CGPoint point = [self.pointArray[0] CGPointValue];
    [self.pointArray addObject:[NSValue valueWithCGPoint:point]];
    [self setNeedsDisplay];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(fingerDrawLineViewEndTouchWithPointArray:)]) {
        [self.delegate fingerDrawLineViewEndTouchWithPointArray:[self.pointArray copy]];
    }
}
-(void)clearLine{
    [self.pointArray removeAllObjects];
    [self setNeedsDisplay];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
