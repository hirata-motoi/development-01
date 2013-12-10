//
//  SettingViewController.m
//  development-01
//
//  Created by kenjiszk on 2013/11/30.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import "SettingViewController.h"
#import "ScrollView.h"
#import "Session.h"
#import "AppDelegate.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

@synthesize session;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    for (UIView *view in [self.view subviews]) {
        [view removeFromSuperview];
    }
    [self showSettingMenu];
    [self setNavigationBar];
}

-(void)showSettingMenu
{
    AppDelegate *app =  [[UIApplication sharedApplication] delegate];
    ScrollView *scrollView = [[ScrollView alloc] init];
    scrollView.frame = self.view.bounds;
    scrollView.backgroundColor = [UIColor colorWithRed:0.95 green:0.8 blue:0.5 alpha:1.0];
    
    int settingNum = 6;
    int offset = app.naviBarHeight;
    int width = (scrollView.frame.size.width-3)/2;
    for(int i = 0; i < settingNum; i++) {
        UIView *view= [[UIView alloc] init];
//        view.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        int x = i % 2;
        int y = i / 2;
        view.frame = CGRectMake(1*(x+1) + x*width, offset + (1*y) + y*width, width, width);
        view.backgroundColor = [UIColor colorWithRed:1.0 green:0.95 blue:0.95 alpha:1.0];
        if (i == 0) {
            //login
            UIButton *loginButton = [[UIButton alloc] init];
            [loginButton.titleLabel setFont:[UIFont systemFontOfSize:24]];
            loginButton.frame = CGRectMake(0, 70, width, 30);
            [loginButton setTitleColor:[UIColor colorWithRed:0.95 green:0.8 blue:0.5 alpha:1.0] forState:UIControlStateNormal];
            [loginButton setTitle:@"ログイン" forState:UIControlStateNormal];
            [loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:loginButton];
        } else if (i == 1){
            //logout
            UIButton *logoutButton = [[UIButton alloc] init];
            [logoutButton.titleLabel setFont:[UIFont systemFontOfSize:24]];
            logoutButton.frame = CGRectMake(0, 70, width, 30);
            [logoutButton setTitleColor:[UIColor colorWithRed:0.95 green:0.8 blue:0.5 alpha:1.0] forState:UIControlStateNormal];
            [logoutButton setTitle:@"ログアウト" forState:UIControlStateNormal];
            [logoutButton addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:logoutButton];
        }
        [scrollView addSubview:view];
    }
    
    [self.view addSubview:scrollView];
}

-(void)login:(UIButton*)button
{
    session = [[Session alloc] init];
    [session showLoginView:self.view];
}

-(void)logout:(UIButton*)button
{
    session = [[Session alloc] init];
    [session showLogoutView:self.view];
}

- (void)setNavigationBar {
    AppDelegate *app =  [[UIApplication sharedApplication] delegate];
    UINavigationBar * navigationBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width, app.naviBarHeight)];

    // ナビゲーションアイテムを生成
    UINavigationItem* title = [[UINavigationItem alloc] initWithTitle:@"Setting"];
    [navigationBar pushNavigationItem:title animated:YES];

    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};

    NSString *ver = [[UIDevice currentDevice] systemVersion];
    int ver_int = [ver intValue];

    if (ver_int < 7) {
        [navigationBar setTintColor:app.naviBarColor];
    } else {
        navigationBar.barTintColor = app.naviBarColor;
    }

    [self.view addSubview:navigationBar];
}

@end
