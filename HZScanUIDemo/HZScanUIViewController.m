//
//  HZScanUIViewController.m
//  HZScanUIDemo
//
//  Created by admin on 2019/11/21.
//  Copyright © 2019 admin. All rights reserved.
//

#import "HZScanUIViewController.h"
#import "Masonry.h"
#import <AVFoundation/AVFoundation.h>
#include <math.h>
@interface HZScanUIViewController ()<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) UIView *bottomToolBar;
@property (nonatomic, strong) UIButton *QRBtn;
@property (nonatomic, strong) UIButton *ARBtn;

@property (nonatomic, strong) UIView *markView;
@property (nonatomic, strong) UIView *QRScanView;
@property (nonatomic, strong) UIView *ARScanView;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@end

@implementation HZScanUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setQRScanUI];
    [self setARScanUI];
    [self setAlphaMarkView];
    [self setBaseUI];
}


- (void)setAlphaMarkView {
    [self.view addSubview:self.markView];
    self.markView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [self changeMarskLayer:true];
}

- (void)changeMarskLayer:(BOOL)isQRScan {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.markView.frame];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIBezierPath *markPath = [UIBezierPath bezierPath];
            
            if (isQRScan) {
                markPath = [[UIBezierPath bezierPathWithRect:self.QRScanView.frame] bezierPathByReversingPath];
                [path appendPath:markPath];
            } else {
                CGFloat x = self.ARScanView.frame.origin.x;
                CGFloat y = self.ARScanView.frame.origin.y;
                CGFloat wh = self.ARScanView.bounds.size.width;
        
                float sin60 = yt_sin(60);
                float sin30 = yt_sin(30);
        
                CGFloat r = wh * 0.5;
                CGPoint point0 = CGPointMake(x + (1 - sin60) * r, y + r * sin30);
                CGPoint point1 = CGPointMake(x + r, y);
                CGPoint point2 = CGPointMake(x + (1 + sin60) * r, y + r * sin30);
                CGPoint point3 = CGPointMake(x + (1 + sin60) * r, y + (1 + sin30) * r);
                CGPoint point4 = CGPointMake(x + r, y + wh);
                CGPoint point5 = CGPointMake(x + (1 - sin60) * r, y + (1 + sin30) * r);
        
                UIBezierPath *ARPath = [UIBezierPath bezierPath];
                [ARPath moveToPoint:point0];
                //
                [ARPath addLineToPoint:point1];
                [ARPath addLineToPoint:point2];
                [ARPath addLineToPoint:point3];
                [ARPath addLineToPoint:point4];
                [ARPath addLineToPoint:point5];
                [ARPath closePath];
                ARPath.lineJoinStyle = kCGLineJoinRound;
                ARPath = [ARPath bezierPathByReversingPath];
                [path appendPath:ARPath];
            }
            CAShapeLayer*shapeLayer = [CAShapeLayer layer];
            shapeLayer.path = path.CGPath;
            [self.markView.layer setMask:shapeLayer];
        });
}


float yt_sin(float angular) {
    float radian = M_PI/(180/angular);
    return sinf(radian);
}


- (void)setBaseUI {
    //
    [self.view addSubview:self.bottomToolBar];
    [self.bottomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(100);
    }];
}

- (void)setARScanUI {
    [self.view addSubview:self.ARScanView];
    self.ARScanView.layer.cornerRadius = 20;
    self.ARScanView.layer.masksToBounds = true;
    self.ARScanView.hidden = true;
    [self.ARScanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.QRScanView);
        make.size.mas_equalTo(CGSizeMake(300, 300));
    }];
}

- (void)setQRScanUI {
    
    [self.view addSubview:self.QRScanView];
    [self.QRScanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(150);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(230, 230));
    }];
    
    // 1、获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 2、创建摄像设备输入流
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    // 3、创建---元数据输出流
//    self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 设置扫描范围（每一个取值0～1，以屏幕右上角为坐标原点）
    // 注：微信二维码的扫描范围是整个屏幕，这里并没有做处理（可不用设置）;
//    metadataOutput.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);
    
    __block CGFloat y = 0;
    __block CGFloat x = 0;
    __block CGFloat h = 0;
    __block CGFloat w = 0;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    // masonry 延迟一下，这里是0秒。就会得到frame，不过必须在block内部来s获取。
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        y = fabs(self.QRScanView.frame.origin.y);
        x = fabs(self.QRScanView.frame.origin.x);
        h = self.QRScanView.bounds.size.height;
        w = self.QRScanView.bounds.size.width;
        NSLog(@"-----aaaaa--:%lf", y);
        self.metadataOutput.rectOfInterest = CGRectMake(y/screenH, x/screenW, h/screenH, w/screenW);
    });
    
    // 4、创建会话对象
//    self.captureSession = [[AVCaptureSession alloc] init];
    // 并设置会话采集率
    self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    
    // 5、添加元数据输出流到会话对象
    [self.captureSession addOutput:self.metadataOutput];

   // 创建摄像数据输出流并将其添加到会话对象上,  --> 用于识别光线强弱
//    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.videoDataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    [self.captureSession addOutput:self.videoDataOutput];

    // 6、添加摄像设备输入流到会话对象
    [self.captureSession addInput:deviceInput];

 // 7、设置数据输出类型(如下设置为条形码和二维码兼容)，需要将数据输出添加到会话后，才能指定元数据类型，否则会报错
    self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code,  AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    // 8、实例化预览图层, 用于显示会话对象
    self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    // 保持纵横比；填充层边界
    self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.videoPreviewLayer.frame = self.view.bounds;
    
    [self.view.layer insertSublayer:self.videoPreviewLayer atIndex:0];
    
    
    // 9、启动会话
    [self.captureSession startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"metadataObjects - - %@", metadataObjects);
    if (metadataObjects != nil && metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        NSLog(@"------%@",[obj stringValue]);
        [self.captureSession stopRunning];
    } else {
        NSLog(@"暂未识别出扫描的二维码");
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
//AVCaptureVideoDataOutput获取实时图像，这个代理方法的回调频率很快，几乎与手机屏幕的刷新频率一样快
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
//    [self getBrightnessValue:sampleBuffer];
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    UIImage *img = [self imageFromSampleBuffer:sampleBuffer];
    NSLog(@"--------------:%@", img);
}

// 显示是否要打开灯
- (void)getBrightnessValue:(CMSampleBufferRef)sampleBuffer{
     // 这个方法会时时调用，但内存很稳定
        CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
        NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
        CFRelease(metadataDict);
        NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
        float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
        NSLog(@"------=====%f",brightnessValue);
       if (brightnessValue < - 1) {
    //        [self.view addSubview:self.lightBtn];
           NSLog(@"------====请打开");
        } else {
    //        if (self.isSelectedFlashlightBtn == NO) {
    //            [self removeFlashlightBtn];
    //        }
            NSLog(@"------====不用打开");
        }
}

//CMSampleBufferRef转NSImage
-(UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    // 释放context和颜色空间
    CGContextRelease(context); CGColorSpaceRelease(colorSpace);
    // 用Quartz image创建一个UIImage对象image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    // 释放Quartz image对象
    CGImageRelease(quartzImage);
    return (image);
}



- (UIView *)bottomToolBar {
    if (_bottomToolBar == nil) {
        _bottomToolBar = [UIView new];
        _bottomToolBar.backgroundColor = [UIColor yellowColor];
        [_bottomToolBar addSubview:self.QRBtn];
        [_bottomToolBar addSubview:self.ARBtn];
        //
        [self.QRBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.mas_offset(0);
            make.width.mas_equalTo(_bottomToolBar.mas_width).multipliedBy(0.5);
        }];
        [self.ARBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.mas_offset(0);
            make.width.mas_equalTo(_bottomToolBar.mas_width).multipliedBy(0.5);
        }];
    }
    return _bottomToolBar;
}

- (UIButton *)QRBtn {
    if (_QRBtn == nil) {
        _QRBtn = [UIButton new];
        _QRBtn.backgroundColor = [UIColor redColor];
        _QRBtn.selected = true;
        [_QRBtn addTarget:self action:@selector(scan:) forControlEvents:UIControlEventTouchUpInside];
        [_QRBtn setTitle:@"QR" forState:UIControlStateNormal];
        [_QRBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_QRBtn setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    }
    return _QRBtn;
}

- (UIButton *)ARBtn {
    if (_ARBtn == nil) {
        _ARBtn = [UIButton new];
        _ARBtn.backgroundColor = [UIColor greenColor];
        [_ARBtn addTarget:self action:@selector(scan:) forControlEvents:UIControlEventTouchUpInside];
        [_ARBtn setTitle:@"AR" forState:UIControlStateNormal];
        [_ARBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_ARBtn setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    }
    return _ARBtn;
}

- (UIView *)markView {
    if (_markView == nil) {
        _markView = [[UIView alloc] initWithFrame:self.view.bounds];
    }
    return _markView;
}


- (UIView *)QRScanView {
    if (_QRScanView == nil) {
        _QRScanView = [UIView new];
//        _QRScanView.layer.borderWidth = 1;
//        _QRScanView.layer.borderColor = [UIColor redColor].CGColor;
    }
    return _QRScanView;
}

- (UIView *)ARScanView {
    if (_ARScanView == nil) {
        _ARScanView = [UIView new];
//        _ARScanView.layer.borderWidth = 1;
//        _ARScanView.layer.borderColor = [UIColor redColor].CGColor;
    }
    return _ARScanView;
}

- (AVCaptureSession *)captureSession {
    if(_captureSession == nil) {
        _captureSession = [AVCaptureSession new];
    }
    return _captureSession;
}

- (AVCaptureMetadataOutput *)metadataOutput {
    if(_metadataOutput == nil) {
           _metadataOutput = [AVCaptureMetadataOutput new];
       }
       return _metadataOutput;
}


- (AVCaptureVideoDataOutput *)videoDataOutput {
    if (_videoDataOutput == nil) {
        _videoDataOutput = [AVCaptureVideoDataOutput new];
    }
    
    return _videoDataOutput;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.captureSession stopRunning];
}

- (void)scan:(UIButton *)scanBtn {
    if (scanBtn.isSelected == true) return;
    scanBtn.selected = true;
    if (scanBtn == self.QRBtn) {
        [self.videoDataOutput setSampleBufferDelegate:nil queue:dispatch_get_main_queue()];
        [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        self.ARBtn.selected = false;
        //
        self.ARScanView.hidden = true;
        self.QRScanView.hidden = false;
        [self changeMarskLayer:true];
    } else {
        [self.metadataOutput setMetadataObjectsDelegate:nil queue:dispatch_get_main_queue()];
        [self.videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        self.QRBtn.selected = false;
        self.QRScanView.hidden = true;
        self.ARScanView.hidden = false;
        [self changeMarskLayer:false];
    }
}

@end