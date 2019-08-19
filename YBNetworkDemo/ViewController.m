//
//  ViewController.m
//  YBNetworkDemo
//
//  Created by 波儿菜 on 2019/4/9.
//  Copyright © 2019 波儿菜. All rights reserved.
//

#import "ViewController.h"
#import "TestViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.bounds = CGRectMake(0, 0, 300, 100);
    button.center = self.view.center;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:30];
    [button setTitle:@"跳转" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)clickButton {
    [self.navigationController pushViewController:TestViewController.new animated:YES];
}

@end
