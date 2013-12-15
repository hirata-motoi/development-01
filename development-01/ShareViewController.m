//
//  ShareViewController.m
//  development-01
//
//  Created by kenjiszk on 2013/11/30.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import "ShareViewController.h"
#import "DA.h"
#import "Common.h"
#import "ScrollView.h"
#import "AppDelegate.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

@synthesize textField;
@synthesize textView;
@synthesize tabHeight;
@synthesize textHeight;
@synthesize scrollView;

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
    
    UIImage *backImage = [UIImage imageNamed:@"line_like_image.png"];
    UIImageView *backImageView = [[UIImageView alloc] initWithImage:backImage];
    backImageView.frame = self.view.frame;
    [self.view addSubview:backImageView];

    [self showSareImageList];
    [self setNavigationBar];
    
    //キーボード表示・非表示の通知を開始
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //キーボード表示・非表示の通知を終了
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showSareImageList
{
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
    self.singleTap.delegate = self;
    self.singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:self.singleTap];
    
    AppDelegate *app =  [[UIApplication sharedApplication] delegate];
    Common *cm = [[Common alloc] init];

    // Params TODO
    int naviHeight = 44;

    NSString *ver = [[UIDevice currentDevice] systemVersion];
    tabHeight = 49;
    int ver_int = [ver intValue];
    if (ver_int < 7) {
        tabHeight = 0;
    }

    textHeight = 40;
    int imageSize = 220;
    int myImageLeft = 50;
    int contentSize = 0;
    int commentSize = 100;

    // Create scrollView
    scrollView = [[ScrollView alloc] init];
    CGRect srect = self.view.frame;
    srect.origin.y = app.naviBarHeight;
    srect.size.height -= (naviHeight + tabHeight + textHeight);
    scrollView.frame = srect;
    
    UIImage *iineImage = [[UIImage imageNamed:@"iine.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:1];
    UIImage *commentImage = [[UIImage imageNamed:@"comments.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:1];
    
    NSArray *shareImageList = [cm getImagesByTag:[NSNumber numberWithInt:1000]];
    UIImageView *shareImageView;
    int count = 0;
    int x = 0;
    int y = 0;
    for (NSDictionary *unit in shareImageList) {
        NSString *shareImagePath = [unit objectForKey:@"image_path"];
        UIImage *shareImage = [UIImage imageWithContentsOfFile:shareImagePath];
        shareImageView = [[UIImageView alloc] initWithImage:shareImage];
        shareImageView.tag = 1000; // 1000:share
        shareImageView.userInteractionEnabled = YES;
        x = myImageLeft;
        y = (commentSize + imageSize + 10) * count;
        shareImageView.frame = CGRectMake(x, y, imageSize, imageSize);
        [scrollView insertSubview:shareImageView atIndex:0];
        
        UIImageView *iineImageView = [[UIImageView alloc] initWithImage:iineImage];
        x = 180;
        y = (commentSize + imageSize + 10) * count + imageSize;
        iineImageView.frame = CGRectMake(x, y, 100, 30);
        [scrollView insertSubview:iineImageView atIndex:0];
        
        UIImageView *commentImageView = [[UIImageView alloc] initWithImage:commentImage];
        x = myImageLeft;
        y = (commentSize + imageSize + 10) * count + imageSize + 40;
        commentImageView.frame = CGRectMake(x, y, imageSize, 50);
        [scrollView insertSubview:commentImageView atIndex:0];
    
        count++;
        contentSize = y + 50;
    }
    
    textView = [[UIView alloc] init];
    textView.frame = CGRectMake(0, self.view.frame.size.height - tabHeight - textHeight, self.view.frame.size.width, textHeight);
    textView.backgroundColor = [UIColor grayColor];
    textField = [[UITextView alloc] init];
    textField.frame = CGRectMake(5, 5, self.view.frame.size.width - 50, 30);
    [textView addSubview:textField];

    scrollView.contentSize = CGSizeMake(320, contentSize);

    CGPoint offset;
    offset.x = 0.0f;
    offset.y = scrollView.contentSize.height - scrollView.frame.size.height;
    [scrollView setContentOffset:offset animated:YES];

    [self.view addSubview:scrollView];
    [self.view addSubview:textView];
}

- (void)setNavigationBar {
    AppDelegate *app =  [[UIApplication sharedApplication] delegate];
    UINavigationBar * navigationBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width, app.naviBarHeight)];

    // ナビゲーションアイテムを生成
    UINavigationItem* title = [[UINavigationItem alloc] initWithTitle:@"Share"];
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

-(void)onSingleTap:(UITapGestureRecognizer *)recognizer {
    [textField resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    //キーボードの高さをとる
    CGRect keyboardRect = [[aNotification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [[self.view superview] convertRect:keyboardRect fromView:nil];
    NSNumber *duration = [aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    //アニメーションでtextFieldを動かす
    [UIView animateWithDuration:[duration doubleValue]
        animations:^{
            CGRect rect = self.textView.frame;
            rect.origin.y = keyboardRect.origin.y - self.textView.frame.size.height;
            self.textView.frame = rect;
            
            CGPoint offset;
            offset.x = 0.0f;
            offset.y = scrollView.contentSize.height - scrollView.frame.size.height + keyboardRect.size.height - 49;//TODO:49
            [scrollView setContentOffset:offset animated:YES];
        }
    ];
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    NSNumber *duration = [aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];

    //アニメーションでtextFieldを動かす
    [UIView animateWithDuration:[duration doubleValue]
        animations:^{
            CGRect rect = self.textView.frame;
            rect.origin.y = self.view.frame.size.height - tabHeight - textHeight;
            self.textView.frame = rect;
            
            CGPoint offset;
            offset.x = 0.0f;
            offset.y = scrollView.contentSize.height - scrollView.frame.size.height;
            [scrollView setContentOffset:offset animated:YES];
        }
    ];
}

@end
