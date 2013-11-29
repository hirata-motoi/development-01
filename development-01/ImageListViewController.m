//
//  ImageListViewController.m
//  development-01
//
//  Created by Motoi Hirata on 2013/11/29.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import "ImageListViewController.h"
#import "ScrollView.h"
#import "Common.h"
#import "DA.h"
#import "FMDatabase.h"
#import "ModalViewController.h"

@interface ImageListViewController ()

@end

@implementation ImageListViewController

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
	// Do any additional setup after loading the view.
    UIBarButtonItem *bbDone = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeView)];
    
    self.navigationItem.rightBarButtonItem = bbDone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeView{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)setImagesByTag:(NSMutableDictionary*)condition {
    // scrollViewの作成
    ScrollView *scrollView = [[ScrollView alloc] init];
    
    scrollView.frame = self.view.bounds;
    
    
    [scrollView setViewControllerObject:(SecondViewController*)self];
    
    // DBからimage listを取得
    imageInfo = [self getImageInfoFromDB];
    
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    int image_id = touch.view.tag;
    
    if (!image_id) {
        return;
    }
    
    NSNumber *image_id_number = [NSNumber numberWithInt:image_id];
    [self showZoomImage:image_id_number];
}

- (void)showZoomImage:(NSNumber*)image_id {
    CGRect rect_org = self.view.bounds;
    
    NSMutableArray * image_ids = [[NSMutableArray alloc] init];
    
    int index = 0;
    for ( int i = 0; i<imageInfo.count; i++) {
        NSDictionary *unit = [imageInfo objectAtIndex:i];
        NSNumber *image_id_tmp = [unit objectForKey:@"image_id"];
        [image_ids addObject:image_id_tmp];
        
        if ([image_id_tmp isEqualToNumber:image_id]) {
            index = i;
        }
    }
    NSLog(@"index @showZoomImage : %d", index);
    NSNumber * index_number = [NSNumber numberWithInt:index];
    NSLog(@"index_number : %@", index_number);
    ModalViewController *modalViewController = [[ModalViewController alloc] init];
    [modalViewController setImageInfo:image_id withIndex:index_number withImageIds:image_ids];
    
    
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:modalViewController];
    navigationController.navigationBar.translucent = YES;
    navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    [self presentModalViewController:navigationController animated:YES];
}


@end
