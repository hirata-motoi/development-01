//
//  Session.m
//  development-01
//
//  Created by kenjiszk on 2013/12/08.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import "Session.h"

@implementation Session

@synthesize baseView;

-(void)showLoginView:(UIView*)view
{
    NSLog(@"show login view");
    baseView = view;
    [self setBackgroundView];
    UIView *loginView = [[UIView alloc] init];
    int offset_x = 20;
    int offset_y = 100;
    loginView.frame = CGRectMake(offset_x, offset_y, baseView.frame.size.width-2*offset_x, baseView.frame.size.height-2*offset_y);
    loginView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    [baseView addSubview:loginView];
    
    int offset_button = loginView.frame.size.height / 5;
    UIButton *loginButtonNo = [[UIButton alloc] init];
    [loginButtonNo.titleLabel setFont:[UIFont systemFontOfSize:24]];
    loginButtonNo.frame = CGRectMake(0, offset_button*4, baseView.frame.size.width, 30);
    [loginButtonNo setTitleColor:[UIColor colorWithRed:0.95 green:0.8 blue:0.5 alpha:1.0] forState:UIControlStateNormal];
    [loginButtonNo setTitle:@"キャンセル" forState:UIControlStateNormal];
    [loginButtonNo addTarget:self action:@selector(logoutNo:) forControlEvents:UIControlEventTouchUpInside];

    loginView.tag = 999;
    [loginView addSubview:loginButtonNo];
}

-(void)showLogoutView:(UIView*)view
{
    NSLog(@"show logout view");
    baseView = view;
    [self setBackgroundView];
    UIView *logoutView = [[UIView alloc] init];
    int offset_x = 20;
    int offset_y = 100;
    logoutView.frame = CGRectMake(offset_x, offset_y, baseView.frame.size.width-2*offset_x, baseView.frame.size.height-2*offset_y);
    logoutView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    [baseView addSubview:logoutView];
    UILabel *logoutLabel = [[UILabel alloc] init];
    logoutLabel.text = @"ログアウトしますか？";
    logoutLabel.textAlignment = NSTextAlignmentCenter;
    int offset_button = logoutView.frame.size.height / 4;
    logoutLabel.frame = CGRectMake(0, offset_button, baseView.frame.size.width, 30);

    UIButton *logoutButtonYes = [[UIButton alloc] init];
    [logoutButtonYes.titleLabel setFont:[UIFont systemFontOfSize:24]];
    logoutButtonYes.frame = CGRectMake(0, offset_button*2, baseView.frame.size.width, 30);
    [logoutButtonYes setTitleColor:[UIColor colorWithRed:0.95 green:0.8 blue:0.5 alpha:1.0] forState:UIControlStateNormal];
    [logoutButtonYes setTitle:@"はい" forState:UIControlStateNormal];
    [logoutButtonYes addTarget:self action:@selector(logoutYes:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *logoutButtonNo = [[UIButton alloc] init];
    [logoutButtonNo.titleLabel setFont:[UIFont systemFontOfSize:24]];
    logoutButtonNo.frame = CGRectMake(0, offset_button*3, baseView.frame.size.width, 30);
    [logoutButtonNo setTitleColor:[UIColor colorWithRed:0.95 green:0.8 blue:0.5 alpha:1.0] forState:UIControlStateNormal];
    [logoutButtonNo setTitle:@"いいえ" forState:UIControlStateNormal];
    [logoutButtonNo addTarget:self action:@selector(logoutNo:) forControlEvents:UIControlEventTouchUpInside];

    logoutView.tag = 999;
    [logoutView addSubview:logoutLabel];
    [logoutView addSubview:logoutButtonYes];
    [logoutView addSubview:logoutButtonNo];
}

-(void)isLogined
{

}

-(void)makeToken
{

}

-(void)setBackgroundView
{
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    backgroundView.frame = baseView.frame;
    backgroundView.tag = 999;
    [baseView addSubview:backgroundView];
}

-(void)loginYes:(UIButton*)button
{
    NSLog(@"login yes");
    [self removeThisView];
}

-(void)loginNo:(UIButton*)button
{
    NSLog(@"login no");
    [self removeThisView];
}

-(void)logoutYes:(UIButton*)button
{
    NSLog(@"logout yes");
    [self removeThisView];
}

-(void)logoutNo:(UIButton*)button
{
    NSLog(@"logout no");
    [self removeThisView];
}

-(void)removeThisView
{
    for (UIView *view in [baseView subviews]) {
        if (view.tag == 999) {
            [view removeFromSuperview];
        }
    }
}

@end
