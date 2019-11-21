//
//  ViewController.m
//  HZScanUIDemo
//
//  Created by admin on 2019/11/21.
//  Copyright © 2019 admin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.navigationController pushViewController:[NSClassFromString(@"HZScanUIViewController") new] animated:true];
}

@end
