//
//  HZCaptureScanManager.m
//  HZScanUIDemo
//
//  Created by admin on 2020/6/22.
//  Copyright © 2020 admin. All rights reserved.
//

#import "HZCaptureScanManager.h"
@interface HZCaptureScanManager()<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@end

@implementation HZCaptureScanManager
static HZCaptureScanManager* _manager = nil;
+ (instancetype)shareManager {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _manager = [[super allocWithZone:NULL] init] ;
    }) ;
    return _manager ;
}
+(id) allocWithZone:(struct _NSZone *)zone {
    return [HZCaptureScanManager shareManager];
}
-(id)copyWithZone:(NSZone *)zone {
    return [HZCaptureScanManager shareManager];
}
-(id)mutableCopyWithZone:(NSZone *)zone {
    return [HZCaptureScanManager shareManager];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self baseSetting];
    }
    return self;
}

- (void)baseSetting {
    // 1、获取可用的摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 2、创建摄像设备输入流
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        
    // 3、创建---元数据输出流
    [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
    // 设置扫描范围（每一个取值0～1，以屏幕右上角为坐标原点）
    //self.metadataOutput.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);
    
    // 4、创建会话对象
    // 并设置会话采集率
    self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    
    // 5、添加元数据输出流到会话对象
    [self.captureSession addOutput:self.metadataOutput];

   // 创建摄像数据输出流并将其添加到会话对象上,  --> 用于识别光线强弱
   //    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.videoDataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    [self.videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    [self.captureSession addOutput:self.videoDataOutput];
    
    // 6、添加摄像设备输入流到会话对象
    [self.captureSession addInput:deviceInput];

    // 7、设置数据输出类型(如下设置为条形码和二维码兼容)，需要将数据输出添加到会话后，才能指定元数据类型，否则会报错
    self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code,  AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    // 8、实例化预览图层, 用于显示会话对象
    self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    // 保持纵横比；填充层边界
    self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    if (metadataObjects != nil && metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        if (self.outputDelegate && [self.outputDelegate respondsToSelector:@selector(captureScanManager:didOutputMetadataObjects:codeString:)]) {
            [self.outputDelegate captureScanManager:self didOutputMetadataObjects:metadataObjects codeString:[obj stringValue]];
        }
        [self.captureSession stopRunning];
    } else {
        NSLog(@"暂未识别出扫描的二维码");
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    [self getBrightnessValue:sampleBuffer];
        [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        
        UIImage *img = [self imageFromSampleBuffer:sampleBuffer];
        if (img) {
//            UIImage *resultImg = [self yt_imageFromImage:img inRect:self.preview.frame];
            if (self.outputDelegate && [self.outputDelegate respondsToSelector:@selector(captureScanManager:didOutputSampleBuffer:codeImage:)]) {
                [self.outputDelegate captureScanManager:self didOutputSampleBuffer:sampleBuffer codeImage:img];
            }
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

- (UIImage *)yt_imageFromImage:(UIImage *)image inRect:(CGRect)rect{
    
    //把像 素rect 转化为 点rect（如无转化则按原图像素取部分图片）
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat x = rect.origin.x * scale,
    y = rect.origin.y * scale,
    w = rect.size.width*scale,
    h = rect.size.height * scale;
    CGRect pointRect = CGRectMake(x, y, w, h);

    //截取部分图片并生成新图片
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, pointRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    return newImage;
}

// 显示是否要打开灯
- (void)getBrightnessValue:(CMSampleBufferRef)sampleBuffer{
     // 这个方法会时时调用，但内存很稳定
        CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
        NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
        CFRelease(metadataDict);
        NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
        float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
       if (brightnessValue < - 1) {
           self.torchNeeds = true;
        } else {
            self.torchNeeds = false;
        }
}

- (void)setPreview:(UIView *)preview {
    self.videoPreviewLayer.frame = preview.bounds;
    [preview.layer insertSublayer:self.videoPreviewLayer atIndex:0];
    _preview = preview;
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


- (void)setInterestReact:(CGRect)interestReact {
    
    __block CGFloat y = 0, x = 0, h = 0, w = 0;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    // masonry 延迟一下，这里是0秒。就会得到frame，不过必须在block内部来s获取。
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        y = fabs(interestReact.origin.y);
        x = fabs(interestReact.origin.x);
        h = interestReact.size.height;
        w = interestReact.size.width;
        self.metadataOutput.rectOfInterest = CGRectMake(y/screenH, x/screenW, h/screenH, w/screenW);
    });
   
}

- (void)startScanning {
    if (self.captureSession) {
        [self.captureSession startRunning];
    }
}
- (void)stopScanning {
    if (self.captureSession) {
        [self.captureSession stopRunning];
    }
}

- (void)destroy {
    _manager = nil;
    self.outputDelegate = nil;
}
@end
