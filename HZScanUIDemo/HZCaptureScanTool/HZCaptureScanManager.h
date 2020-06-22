//
//  HZCaptureScanManager.h
//  HZScanUIDemo
//
//  Created by admin on 2020/6/22.
//  Copyright © 2020 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class HZCaptureScanManager;
NS_ASSUME_NONNULL_BEGIN
@protocol HZCaptureScanManagerOutputDelegate <NSObject>
- (void)captureScanManager:(HZCaptureScanManager *)captureScanManager didOutputMetadataObjects:(NSArray *)metadataObjects codeString:(NSString *)codeString;
- (void)captureScanManager:(HZCaptureScanManager *)captureScanManager didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer codeImage:(UIImage *)codeImage;
@end
@interface HZCaptureScanManager : NSObject
@property (nonatomic, weak) id <HZCaptureScanManagerOutputDelegate> outputDelegate;
@property (nonatomic, strong) UIView *preview;
@property (nonatomic, assign) CGRect interestReact;
@property (nonatomic, assign) BOOL torchNeeds;
+ (instancetype)shareManager;
- (void)startScanning;
- (void)stopScanning;
@end

NS_ASSUME_NONNULL_END
