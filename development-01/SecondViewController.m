//
//  SecondViewController.m
//  development-01
//
//  Created by Motoi Hirata on 2013/11/18.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import "SecondViewController.h"
#import "DA.h"
#import "FMDatabase.h"
#import "Common.h"
#import "ScrollView.h"
#import "ImageController.h"
#import "ModalViewController.h"
@interface SecondViewController ()

@end

@implementation SecondViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self showSyncedImageList];
    NSLog(@"SecondViewController : %@", self);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showSyncedImageList {
    // scrollViewの作成
    ScrollView *scrollView = [[ScrollView alloc] init];
    scrollView.frame = self.view.bounds;
    

    [scrollView setViewControllerObject:(SecondViewController*)self];

    // DBからimage listを取得
    NSMutableArray *imageInfo = [self getImageInfoFromDB];
    
    // imageViewを作ってscrollViewにはりつけ
    int count = 0;
    for ( NSDictionary *unit in imageInfo) {
        NSString *image_path = [unit objectForKey:@"image_path"];
        UIImage *image = [UIImage imageWithContentsOfFile:image_path];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.tag = [[unit objectForKey:@"image_id"] intValue];
        imageView.userInteractionEnabled = YES;
        
        
        int x,y;
        x = ((count % 3) * 100) + 10;
        y = ((count / 3) * 100) + 10;
        
        imageView.frame = CGRectMake(x, y, 90, 90);
        
        
        [scrollView insertSubview:imageView atIndex:[self.view.subviews count]];
        count++;
    }
    // viewにscrollViewをaddする
    NSInteger heightCount = floor(count / 3) + 1;
    scrollView.contentSize = CGSizeMake(320, (120 * heightCount));
    [self.view addSubview:scrollView];
}

- (NSMutableArray*)getImageInfoFromDB {
    Common *cm = [[Common alloc] init];
    NSMutableArray *imageInfo = [[NSMutableArray alloc] init];
    
    NSString *stmt = @"SELECT id, saved_at FROM image_common order by saved_at desc";
    
    DA *da = [DA da];
    [da open];
    FMResultSet *results = [da executeQuery:stmt];
    while ([results next]) {
        NSNumber *image_id   = [NSNumber numberWithInt:[results intForColumn:@"id"]];
        NSDate *saved_at     = [results dateForColumn:@"saved_at"];
        NSString *image_path = [cm getImagePathThumbnail:(NSNumber*)image_id];
        
        NSArray *key   = [NSArray arrayWithObjects:@"image_id", @"saved_at", @"image_path", nil];
        NSArray *value = [NSArray arrayWithObjects:image_id, saved_at, image_path, nil];
        NSDictionary *unit   = [NSDictionary dictionaryWithObjects:value forKeys:key];
        
        [imageInfo addObject:unit];
    }
    [da close];
    return imageInfo;
}

- (void)showZoomImageWrapper:(NSNumber *)image_id {
    [self showZoomImage:image_id];
}

- (void)showZoomImage:(NSNumber*)image_id {
    CGRect rect_org = self.view.bounds;
    
    ModalViewController *modalViewController = [[ModalViewController alloc] init];
    Common *cm = [[Common alloc]init];
    ImageController *view = [[ImageController alloc] initWithImageId:(NSNumber*)image_id withRect:(CGRect)self.view.bounds];
    [modalViewController.view addSubview:view];

    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:modalViewController];

    [self presentModalViewController:navigationController animated:YES];
}

- (void)closeModal {

}

@end
