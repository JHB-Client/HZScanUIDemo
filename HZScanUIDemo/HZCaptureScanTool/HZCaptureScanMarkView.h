//
//  HZCaptureScanMarkView.h
//  HZScanUIDemo
//
//  Created by admin on 2020/6/22.
//  Copyright © 2020 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ScanReactHander)(CGRect react);
@interface HZCaptureScanMarkView : UIView
@property (nonatomic, copy) ScanReactHander scanReactHander;
@property (nonatomic, strong) UIView *QRScanView;
@property (nonatomic, strong) UIButton *torchBtn;
@end

NS_ASSUME_NONNULL_END
