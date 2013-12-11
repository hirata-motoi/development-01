//
//  Session.m
//  development-01
//
//  Created by kenjiszk on 2013/12/08.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import "Session.h"
#import "DA.h"

@implementation Session

@synthesize baseView;
@synthesize name;
@synthesize password;

-(void)showLoginView:(UIView*)view
{
    NSNumber *isLogined = [self isLogined];
    NSLog(@"logined : %@", isLogined);
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
    self.singleTap.delegate = self;
    self.singleTap.numberOfTapsRequired = 1;
    [view addGestureRecognizer:self.singleTap];
    
    NSLog(@"show login view");
    baseView = view;
    [self setBackgroundView];
    UIView *loginView = [[UIView alloc] init];
    int offset_x = 20;
    int offset_y = 100;
    loginView.frame = CGRectMake(offset_x, offset_y, baseView.frame.size.width-2*offset_x, baseView.frame.size.height-2*offset_y);
    loginView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    loginView.tag = 999;
    [baseView addSubview:loginView];
    
    int offset_button = loginView.frame.size.height / 5;
    
    if([isLogined integerValue] != 1) {
        // username
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.text = @"ユーザー名";
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.frame = CGRectMake(10, offset_button*1, loginView.frame.size.width/2 - 10, 30);
        name = [[UITextField alloc] init];
        name.delegate = self;
        name.frame = CGRectMake(loginView.frame.size.width/2, offset_button*1, loginView.frame.size.width/2 - 10, 30);
        name.borderStyle = UITextBorderStyleRoundedRect;

        //password
        UILabel *passwordLabel = [[UILabel alloc] init];
        passwordLabel.text = @"パスワード";
        passwordLabel.textAlignment = NSTextAlignmentCenter;
        passwordLabel.frame = CGRectMake(10, offset_button*2, loginView.frame.size.width/2 - 10, 30);
        password = [[UITextField alloc] init];
        password.delegate = self;
        password.frame = CGRectMake(loginView.frame.size.width/2, offset_button*2, loginView.frame.size.width/2 - 10, 30);
        password.borderStyle = UITextBorderStyleRoundedRect;
    
        //login button
        UIButton *loginButtonYes = [[UIButton alloc] init];
        [loginButtonYes.titleLabel setFont:[UIFont systemFontOfSize:24]];
        loginButtonYes.frame = CGRectMake(0, offset_button*3, loginView.frame.size.width, 30);
        [loginButtonYes setTitleColor:[UIColor colorWithRed:0.95 green:0.8 blue:0.5 alpha:1.0] forState:UIControlStateNormal];
        [loginButtonYes setTitle:@"ログインする" forState:UIControlStateNormal];
        [loginButtonYes addTarget:self action:@selector(loginYes:) forControlEvents:UIControlEventTouchUpInside];
    
        //cancel button
        UIButton *loginButtonNo = [[UIButton alloc] init];
        [loginButtonNo.titleLabel setFont:[UIFont systemFontOfSize:24]];
        loginButtonNo.frame = CGRectMake(0, offset_button*4, loginView.frame.size.width, 30);
        [loginButtonNo setTitleColor:[UIColor colorWithRed:0.95 green:0.8 blue:0.5 alpha:1.0] forState:UIControlStateNormal];
        [loginButtonNo setTitle:@"キャンセル" forState:UIControlStateNormal];
        [loginButtonNo addTarget:self action:@selector(loginNo:) forControlEvents:UIControlEventTouchUpInside];

        [loginView addSubview:name];
        [loginView addSubview:password];
        [loginView addSubview:loginButtonYes];
        [loginView addSubview:loginButtonNo];
        [loginView addSubview:nameLabel];
        [loginView addSubview:passwordLabel];
    } else {
        UILabel *loginedLabel = [[UILabel alloc] init];
        loginedLabel.text = @"ログイン済みです";
        loginedLabel.textAlignment = NSTextAlignmentCenter;
        loginedLabel.frame = CGRectMake(10, offset_button*2, loginView.frame.size.width - 10, 30);

        UIButton *loginedButton = [[UIButton alloc] init];
        [loginedButton.titleLabel setFont:[UIFont systemFontOfSize:24]];
        loginedButton.frame = CGRectMake(0, offset_button*4, loginView.frame.size.width, 30);
        [loginedButton setTitleColor:[UIColor colorWithRed:0.95 green:0.8 blue:0.5 alpha:1.0] forState:UIControlStateNormal];
        [loginedButton setTitle:@"OK" forState:UIControlStateNormal];
        [loginedButton addTarget:self action:@selector(loginNo:) forControlEvents:UIControlEventTouchUpInside];

        [loginView addSubview:loginedButton];
        [loginView addSubview:loginedLabel];
    }
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
    logoutLabel.frame = CGRectMake(0, offset_button, logoutView.frame.size.width, 30);

    UIButton *logoutButtonYes = [[UIButton alloc] init];
    [logoutButtonYes.titleLabel setFont:[UIFont systemFontOfSize:24]];
    logoutButtonYes.frame = CGRectMake(0, offset_button*2, logoutView.frame.size.width, 30);
    [logoutButtonYes setTitleColor:[UIColor colorWithRed:0.95 green:0.8 blue:0.5 alpha:1.0] forState:UIControlStateNormal];
    [logoutButtonYes setTitle:@"はい" forState:UIControlStateNormal];
    [logoutButtonYes addTarget:self action:@selector(logoutYes:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *logoutButtonNo = [[UIButton alloc] init];
    [logoutButtonNo.titleLabel setFont:[UIFont systemFontOfSize:24]];
    logoutButtonNo.frame = CGRectMake(0, offset_button*3, logoutView.frame.size.width, 30);
    [logoutButtonNo setTitleColor:[UIColor colorWithRed:0.95 green:0.8 blue:0.5 alpha:1.0] forState:UIControlStateNormal];
    [logoutButtonNo setTitle:@"いいえ" forState:UIControlStateNormal];
    [logoutButtonNo addTarget:self action:@selector(logoutNo:) forControlEvents:UIControlEventTouchUpInside];

    logoutView.tag = 999;
    [logoutView addSubview:logoutLabel];
    [logoutView addSubview:logoutButtonYes];
    [logoutView addSubview:logoutButtonNo];
}

-(NSNumber*)isLogined
{
    NSString *stmt = @"select islogin from user_data;";
    DA *da = [DA da];
    [da open];
    FMResultSet *results = [da executeQuery:stmt];
    NSNumber *islogin = 0;
    while ([results next]) {
        islogin = [NSNumber numberWithInt:[results intForColumn:@"islogin"]];
    }
    [da close];
    
    return islogin;
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
    NSLog(@"update user data");
    
    //delete first
    NSString *stmt1 = @"delete from user_data;";
    NSString *stmt2 = @"insert into user_data(name, password, islogin) values(?, ?, ?)";
    DA *da = [DA da];
    [da open];
    [da executeUpdate:stmt1];
    
    //update user data
    [da executeUpdate:stmt2, name.text, password.text, [NSNumber numberWithInt:1]];
    [da close];
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
    //delete first
    NSString *stmt1 = @"delete from user_data;";
    DA *da = [DA da];
    [da open];
    [da executeUpdate:stmt1];
    [da close];
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

-(void)onSingleTap:(UITapGestureRecognizer *)recognizer {
    [name resignFirstResponder];
    [password resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)targetTextField {
    [name resignFirstResponder];
    [password resignFirstResponder];
    return YES;
}

@end
