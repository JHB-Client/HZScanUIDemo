//
//  HZCaptureScanViewController.m
//  HZScanUIDemo
//
//  Created by admin on 2020/6/22.
//  Copyright © 2020 admin. All rights reserved.
//

#import "HZCaptureScanViewController.h"
#import "HZCaptureScanManager.h"
#import "HZContentShowViewController.h"
#import "HZCaptureScanMarkView.h"
#import "Masonry.h"
@interface HZCaptureScanViewController ()<HZCaptureScanManagerOutputDelegate>
@property (nonatomic, strong) HZCaptureScanMarkView *markView;
@end

@implementation HZCaptureScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    //1.
    BOOL userAuthority = [self justUserAuthority];

    //2.
    if (userAuthority) {
        //2.1
        [self setBaseUI];
        //
        //2.2
        [self setCaptureScanManager];
    }
}

- (BOOL)justUserAuthority {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusAuthorized || authStatus == AVAuthorizationStatusNotDetermined) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            return true;
        }else{
            NSLog(@"手机不支持相机");
            return false;
        }
    } else {
        
        UIAlertController *logoutAlter = [UIAlertController alertControllerWithTitle:@"提示" message:@"请去设置页面开通相机权限" preferredStyle:UIAlertControllerStyleAlert];
        [logoutAlter addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [logoutAlter addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 无权限 引导去开启
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }]];
        
        [self presentViewController:logoutAlter animated:YES completion:nil];
        return false;
    }
}


- (void)setBaseUI {
    self.markView = [[HZCaptureScanMarkView alloc] initWithFrame:self.view.bounds];
    self.markView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [self.view addSubview:self.markView];
}


- (void)setCaptureScanManager {
    HZCaptureScanManager *manager = [HZCaptureScanManager shareManager];
    manager.outputDelegate = self;
    manager.preview = self.view;
    [manager startScanning];
    self.markView.scanReactHander = ^(CGRect react) {
        manager.interestReact = react;
    };
}



- (void)captureScanManager:(HZCaptureScanManager *)captureScanManager didOutputMetadataObjects:(NSArray *)metadataObjects codeString:(NSString *)codeString {
//    NSLog(@"---sssss---:%@", codeString);
    if (codeString) {
        [[HZCaptureScanManager shareManager] stopScanning];
        HZContentShowViewController *contentShowVCtr = [HZContentShowViewController new];
        contentShowVCtr.contentStr = codeString;
        [self.navigationController pushViewController:contentShowVCtr animated:true];
    }
    
}

- (void)captureScanManager:(HZCaptureScanManager *)captureScanManager didOutputSampleBuffer:(nonnull CMSampleBufferRef)sampleBuffer codeImage:(nonnull UIImage *)codeImage {
//    NSLog(@"---rrrrrr---:%@", codeImage);
//    NSLog(@"---cccc--:%d", captureScanManager.torchNeeds);
    
    self.markView.torchBtn.hidden = !captureScanManager.torchNeeds;
        
    
//    if (codeImage) {
//        [[HZCaptureScanManager shareManager] stopScanning];
//        HZContentShowViewController *contentShowVCtr = [HZContentShowViewController new];
//        contentShowVCtr.contetImage = codeImage;
//        [self.navigationController pushViewController:contentShowVCtr animated:true];
//    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [[HZCaptureScanManager shareManager] stopScanning];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
