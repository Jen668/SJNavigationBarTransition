//
//  TransparentBarViewController.m
//  SJNavigationBarTransition
//
//  Created by 如约科技 on 2017/9/29.
//  Copyright © 2017年 如约科技. All rights reserved.
//

#import "TransparentBarViewController.h"
#import "TestViewController.h"
#import "SJNavigationBarTransition.h"


@interface TransparentBarViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (weak, nonatomic) UIColor *defaultTintColor;

@property (assign, nonatomic) CGFloat barAlpha;

@end


@implementation TransparentBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.defaultTintColor = self.navigationController.navigationBar.tintColor;
    
    if (@available(iOS 11.0, *))
    {
        self.tableview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.barAlpha = 0.0;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.barAlpha <= 0.1) {
     
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    
    [self.navigationController setNavigationBarBackgroundColor:[UIColor whiteColor] backgroundAlpha:self.barAlpha];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.tintColor = self.defaultTintColor;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"row: %ld",indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TestViewController"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

#pragma mark- UITableViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    
    self.barAlpha = offsetY/186.0;
    
    if (self.barAlpha >= 1.0)
    {
        self.barAlpha = 1.0;
    }
    
    if (self.barAlpha <= 0.0)
    {
        self.barAlpha = 0.0;
    }
    
    if (self.barAlpha <= 0.1) {
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    
    if (self.barAlpha >= 0.9) {
        self.navigationController.navigationBar.tintColor = self.defaultTintColor;
    }
    
    [self.navigationController updateNavigationBarBackgroundAlpha:self.barAlpha];
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
