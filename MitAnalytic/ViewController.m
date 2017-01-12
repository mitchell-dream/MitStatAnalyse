//
//  ViewController.m
//  MitAnalytic
//
//  Created by MENGCHEN on 2017/1/11.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "ViewController.h"
#import "ViewControllerTwo.h"
#import "DemoButton.h"
@interface ViewController ()

@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"%s",__func__);
    
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    DemoButton * btn = [DemoButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(200, 200, 100, 100);
    btn.backgroundColor = [UIColor blackColor];
    [btn setTitle:@"点击" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)btnClick:(UIButton*)btn{
    
    NSLog(@"点击了");
    
}

- (IBAction)push:(id)sender {
    ViewControllerTwo * vc = [[ViewControllerTwo alloc]init];
    [self presentViewController:vc animated:true completion:nil];
    
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    NSLog(@"点击了界面1");
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
