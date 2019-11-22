//
//  HZContentShowViewController.m
//  HZScanUIDemo
//
//  Created by admin on 2019/11/22.
//  Copyright © 2019 admin. All rights reserved.
//

#import "HZContentShowViewController.h"
#import "Masonry.h"
#import "NSString+urlJudge.h"
@interface HZContentShowViewController ()
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *contentImgView;
@end

@implementation HZContentShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    if (self.contentStr && [self.contentStr stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0) {
        [self showContentStr];
    } else if (self.contetImage) {
        [self showContetImage];
    }
}




- (UIImageView *)contentImgView {
    if (_contentImgView == nil) {
        _contentImgView = [UIImageView new];
        [self.view addSubview:_contentImgView];

        [_contentImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(80, 20, 20, 20));
        }];
    }
    
    return _contentImgView;
}

- (UILabel *)contentLabel {
    if (_contentLabel == nil) {
        _contentLabel = [UILabel new];
        [_contentLabel sizeToFit];
        _contentLabel.numberOfLines = 0;
        _contentLabel.userInteractionEnabled = true;
        [self.view addSubview:_contentLabel];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.view);
        }];
    }
    return _contentLabel;
}

- (void)showContentStr {
    [self.contentImgView removeFromSuperview];
    self.contentImgView = nil;
    //
    if ([self.contentStr isUrl]) {
        NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
        NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:self.contentStr attributes:attribtDic];
        self.contentLabel.attributedText = attribtStr;
        self.contentLabel.textColor = [UIColor blueColor];
        //
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(visitUrl)];
        [self.contentLabel addGestureRecognizer:tap];
        
    } else {
        self.contentLabel.text = self.contentStr;
    }
}

- (void)visitUrl {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.contentStr] options:@{} completionHandler:nil];
}

- (void)showContetImage {
    self.contentImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentImgView setImage:self.contetImage];
}

- (void)back {
    [self.navigationController popToRootViewControllerAnimated:true];
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
