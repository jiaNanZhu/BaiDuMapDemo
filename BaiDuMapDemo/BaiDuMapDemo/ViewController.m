//
//  ViewController.m
//  BaiDuMapDemo
//
//  Created by 朱佳男 on 2018/5/1.
//  Copyright © 2018年 朱佳男. All rights reserved.
//

#import "ViewController.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Map/BMKOverlay.h>
#import <BaiduMapAPI_Map/BMKPolygon.h>
#import <BaiduMapAPI_Map/BMKPolygonView.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <BaiduMapAPI_Map/BMKAnnotation.h>
#import <BaiduMapAPI_Map/BMKPinAnnotationView.h>
#import "Masonry.h"
#import "CoordinateModel.h"
#import "FingerDrawLineView.h"
@interface ViewController ()<BMKMapViewDelegate,FingerDrawLineViewDelegate>
{
    BMKPolygon *polygon;
    CGFloat     navHeight;
}

@property (nonatomic ,strong)BMKMapView *mapView;
@property (nonatomic ,strong)FingerDrawLineView *lineView;
@property (nonatomic ,copy)NSArray *xArray;//多边形边界点 x坐标集合
@property (nonatomic ,copy)NSArray *yArray;//多边形边界点 y坐标集合
@property (nonatomic ,copy)NSArray *modelArr;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CoordinateModel *model1 = [[CoordinateModel alloc]init];
    model1.latitude = 39.915;
    model1.longitude = 116.404;
    
    CoordinateModel *model2 = [[CoordinateModel alloc]init];
    model2.latitude = 39.830;
    model2.longitude = 116.404;
    
    CoordinateModel *model3 = [[CoordinateModel alloc]init];
    model3.latitude = 39.710;
    model3.longitude = 116.408;
    
    self.modelArr = @[model1,model2,model3];
    
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"画圈找房" style:UIBarButtonItemStylePlain target:self action:@selector(findHouseButtonClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
    CGRect statuBarRect = [[UIApplication sharedApplication] statusBarFrame];
    CGRect navRect = self.navigationController.navigationBar.frame;
    navHeight = navRect.size.height+statuBarRect.size.height;
    [self.view addSubview:self.mapView];
    
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(self->navHeight, 0, 0, 0));
    }];
    // Do any additional setup after loading the view, typically from a nib.
}

-(BMKMapView *)mapView{
    if (!_mapView) {
        _mapView = [[BMKMapView alloc]init];
        _mapView.delegate = self;
        /*-----------隐藏百度地图左下角logoView的一种方法------------*/
        UIView *mView = _mapView.subviews.firstObject;
        for (id logoView in mView.subviews) {
            if ([logoView isKindOfClass:[UIImageView class]]) {
                UIImageView *lgView = (UIImageView *)logoView;
                
                lgView.hidden = YES;
            }
        }
        /*------------------------------------------------------*/
        _mapView.showsUserLocation = YES;
        _mapView.userTrackingMode = BMKUserTrackingModeNone;
        
    }
    return _mapView;
}
-(FingerDrawLineView *)lineView{
    if (!_lineView) {
        _lineView = [[FingerDrawLineView alloc]initWithFrame:CGRectMake(0, navHeight, self.mapView.bounds.size.width, self.mapView.bounds.size.height)];
        _lineView.delegate = self;
        _lineView.lineColor = [UIColor colorWithRed:192/255.0 green:153/255.0 blue:131/255.0 alpha:1];
        _lineView.lineWidth = 2.5;
        
    }
    return _lineView;
}
#pragma mark-FingerDrawLineViewDelegate
-(void)fingerDrawLineViewEndTouchWithPointArray:(NSArray *)pointArray{
    CLLocationCoordinate2D coordArr[pointArray.count];
    NSMutableArray *tempXArr = [NSMutableArray array];
    NSMutableArray *tempYArr = [NSMutableArray array];
    for (int i = 0; i <pointArray.count; i ++) {
        CGPoint point = [pointArray[i] CGPointValue];
        CLLocationCoordinate2D mCorrd = [self.mapView convertPoint:point toCoordinateFromView:self.lineView];
        coordArr[i] = mCorrd;
        [tempXArr addObject:@(mCorrd.longitude)];
        [tempYArr addObject:@(mCorrd.latitude)];
    }
    self.xArray = tempXArr;
    self.yArray = tempYArr;
    polygon = [BMKPolygon polygonWithCoordinates:coordArr count:pointArray.count];
    [self.mapView addOverlay:polygon];
    [self.lineView clearLine];
    [self.lineView removeFromSuperview];
}
#pragma mark-BMKMapViewDelegate
// Override
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay{
    if ([overlay isKindOfClass:[BMKPolygon class]]){
        BMKPolygonView* polygonView = [[BMKPolygonView alloc] initWithOverlay:overlay];
        polygonView.strokeColor = [UIColor colorWithRed:192/255.0 green:153/255.0 blue:131/255.0 alpha:1];
        polygonView.fillColor = [UIColor colorWithRed:192/255.0 green:153/255.0 blue:131/255.0 alpha:0.2];
        polygonView.lineWidth =1.5;
        //        polygonView.lineDash = YES;
        return polygonView;
    }
    return nil;
}
- (void)mapView:(BMKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews{
    if (self.modelArr.count == 0) {
        return;
    }
    for (CoordinateModel *model in self.modelArr) {
        BOOL b = [self pnpolyWithArrayCount:self.xArray.count boundariesX:self.xArray boundariesY:self.yArray testX:model.longitude testY:model.latitude];
        if (b) {
            BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
//            annotation.coordinate = CLLocationCoordinate2DMake(39.915, 116.404);
            annotation.coordinate = CLLocationCoordinate2DMake(model.latitude, model.longitude);
            annotation.title = @" ";
            [_mapView addAnnotation:annotation];
        }
    }
}
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        BMKPinAnnotationView*annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil) {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.pinColor = BMKPinAnnotationColorPurple;
        annotationView.canShowCallout= YES;      //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop=YES;         //设置标注动画显示，默认为NO
        annotationView.draggable = YES;          //设置标注可以拖动，默认为NO
        return annotationView;
    }
    return nil;
}
/**
 判断测试点是否在某一区域内

 @param arrCount 组成区域的边界点的数组
 @param xArr 多边形边界点x坐标集合
 @param YArr 多边形边界点y坐标集合
 @param testX 测试点x坐标
 @param testY 测试点x坐标
 @return YES 在多边形内  NO 在多边形外部
 */
-(BOOL)pnpolyWithArrayCount:(NSInteger)arrCount boundariesX:(NSArray *)xArr boundariesY:(NSArray *)YArr testX:(CGFloat)testX testY:(CGFloat)testY{
    NSInteger i, j;
    BOOL c=NO;
    for (i = 0, j = arrCount-1; i < arrCount; j = i++) {
        
        if ( ( ([YArr[i] floatValue]>testY) != ([YArr[j] floatValue]>testY) ) &&
            (testX < ([xArr[j] floatValue]-[xArr[i] floatValue]) * (testY-[YArr[i] floatValue]) / ([YArr[j] floatValue]-[YArr[i] floatValue]) + [xArr[i] floatValue]) )
            c = !c;
    }
    return c;
}

-(void)findHouseButtonClick{
    NSLog(@"画圈找房");
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlay:polygon];
//    self.mapView.zoomLevel = 18;
    [self.view addSubview:self.lineView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
