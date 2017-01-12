//
//  ViewControllerTwo.m
//  MitAnalytic
//
//  Created by MENGCHEN on 2017/1/11.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "ViewControllerTwo.h"

@interface ViewControllerTwo ()<UITableViewDelegate,UITableViewDataSource>
/** 列表 */
@property(nonatomic, weak)UITableView * table;
@end

@implementation ViewControllerTwo

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 100, 100);
    [btn setTitle:@"click" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor blackColor];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    self.table.backgroundColor = [UIColor orangeColor];
}
-(UITableView *)table{
    if (!_table) {
        UITableView * tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
        tab.delegate = self;
        tab.dataSource = self;
        [self.view addSubview:tab];
        _table = tab;
    }
    return _table;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld行",indexPath.row];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    
}
- (void)btnClick{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
