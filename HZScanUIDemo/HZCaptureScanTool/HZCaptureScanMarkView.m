//
//  HZCaptureScanMarkView.m
//  HZScanUIDemo
//
//  Created by admin on 2020/6/22.
//  Copyright © 2020 admin. All rights reserved.
//

#import "HZCaptureScanMarkView.h"
#import "Masonry.h"
#include <math.h>
#import <AVFoundation/AVFoundation.h>
@interface HZCaptureScanMarkView ()
//@property (nonatomic, strong) UIView *QRScanView;
@property (nonatomic, strong) UIView *ARScanView;
@property (nonatomic, strong) UIView *bottomToolBar;
@property (nonatomic, strong) UIButton *QRBtn;
@property (nonatomic, strong) UIButton *ARBtn;
//
@property (nonatomic, assign) BOOL isARScan;
@end
@implementation HZCaptureScanMarkView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpSubviews];
    }
    return self;
}

- (void)setUpSubviews {
    //
    [self addSubview:self.QRScanView];
    [self.QRScanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(230, 230));
    }];
    
    
    [self addSubview:self.ARScanView];
    [self.ARScanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(300, 300));
    }];
    
    //
    [self addSubview:self.torchBtn];
    [self.torchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.QRScanView.mas_bottom).offset(50);
        make.centerX.mas_equalTo(self.QRScanView);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    //
    [self addSubview:self.bottomToolBar];
    [self.bottomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.right.bottom.mas_equalTo(0);
           make.height.mas_equalTo(100);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self changeMarskLayer:true];
    });
}

- (UIView *)QRScanView {
    if (_QRScanView == nil) {
        _QRScanView = [UIView new];
    }
    return _QRScanView;
}

- (UIView *)ARScanView {
    if (_ARScanView == nil) {
        _ARScanView = [UIView new];
    }
    return _ARScanView;
}

- (UIButton *)torchBtn {
    if (_torchBtn == nil) {
        _torchBtn = [UIButton new];
        _torchBtn.backgroundColor = [UIColor redColor];
       [_torchBtn setTitle:@"开灯" forState:UIControlStateNormal];
       [_torchBtn setTitle:@"关灯" forState:UIControlStateSelected];
       [_torchBtn addTarget:self action:@selector(lightTorch:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _torchBtn;
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

- (UIView *)bottomToolBar {
    if (_bottomToolBar == nil) {
        _bottomToolBar = [UIView new];
        [_bottomToolBar addSubview:self.QRBtn];
        [_bottomToolBar addSubview:self.ARBtn];
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



- (void)scan:(UIButton *)scanBtn {
    if (scanBtn.isSelected == true) return;
    scanBtn.selected = true;
    if (scanBtn == self.QRBtn) {
        self.isARScan = false;

        //
        self.ARBtn.selected = false;
        self.ARScanView.hidden = true;
        self.QRScanView.hidden = false;
        [self changeMarskLayer:true];
        //
//        if (self.scanReactHander) {
//            self.scanReactHander(self.QRScanView.frame);
//        }
    } else {
        self.isARScan = true;

        //
        self.QRBtn.selected = false;
        self.QRScanView.hidden = true;
        self.ARScanView.hidden = false;
        [self changeMarskLayer:false];
        //
//        if (self.scanReactHander) {
//            self.scanReactHander(self.ARScanView.frame);
//        }
    }
}


- (void)changeMarskLayer:(BOOL)isQRScan {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.frame];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIBezierPath *markPath = [UIBezierPath bezierPath];

            if (isQRScan) {
                markPath = [[UIBezierPath bezierPathWithRect:self.QRScanView.frame] bezierPathByReversingPath];
                [path appendPath:markPath];
            } else {
                CGFloat x = self.ARScanView.frame.origin.x;
                CGFloat y = self.ARScanView.frame.origin.y;
                CGFloat wh = self.ARScanView.bounds.size.width;

                float sin60 = sinf(M_PI/(180/60));
                float sin30 = sinf(M_PI/(180/30));

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
            [self.layer setMask:shapeLayer];
        });
}

- (void)lightTorch:(UIButton *)torchBtn {
    if (torchBtn.selected == false) {
        /** 打开手电筒 */
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        if ([captureDevice hasTorch]) {
            BOOL locked = [captureDevice lockForConfiguration:&error];
            if (locked) {
                captureDevice.torchMode = AVCaptureTorchModeOn;
                [captureDevice unlockForConfiguration];
            }
        }
        
        torchBtn.selected = true;
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)),                  dispatch_get_main_queue(), ^{
              AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
              if ([device hasTorch]) {
                    [device lockForConfiguration:nil];
                    [device setTorchMode: AVCaptureTorchModeOff];
                    [device unlockForConfiguration];
              }
            torchBtn.selected = false;
        });
    }
    
}

@end
