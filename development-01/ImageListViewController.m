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

-(void)setImagesByTagId:(NSNumber*)tag_id {
    // scrollViewの作成
    ScrollView *scrollView = [[ScrollView alloc] init];
    
    scrollView.frame = self.view.bounds;
    [scrollView setViewControllerObject:(SecondViewController*)self];
    
    // DBからimage listを取得
    imageInfo = [self getImageInfoFromDB:tag_id];
    
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

- (NSMutableArray*)getImageInfoFromDB:(NSNumber*)tag_id {
    
    // tag_id指定 or tag_idがついてないもの or all
    // tag_id指定 : tag_id = ?
    // tag_idがついてないもの : 全imageとtag_mapの中身を比較してimage_idを取得
    // all : where句無し
    NSLog(@"getImageInfoFromDB tag_id : %@", tag_id);
    
    
    Common *cm = [[Common alloc] init];
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    DA *da = [DA da];
    [da open];
    
    FMResultSet *results;
    NSString *stmt = @"";
    if ([tag_id intValue] == -1) { //all
        stmt = @"SELECT id, saved_at AS date FROM image_common order by saved_at desc";
        results = [da executeQuery:stmt];
    }
    else if ([tag_id intValue] == -2) { //untag
        stmt = @"SELECT i.id, saved_at AS date FROM image_common i LEFT JOIN tag_map t ON i.id = t.tag_id WHERE t.tag_id is NULL";
        results = [da executeQuery:stmt];
    }
    else {
        stmt = @"SELECT image_id AS id, created_at AS date FROM tag_map WHERE tag_id = ?";
        results = [da executeQuery:stmt, tag_id];
    }

    while ([results next]) {
        NSLog(@"result found");
        NSNumber *image_id   = [NSNumber numberWithInt:[results intForColumn:@"id"]];
        NSDate *saved_at     = [results dateForColumn:@"date"];
        NSString *image_path = [cm getImagePathThumbnail:(NSNumber*)image_id];
        
        NSArray *key   = [NSArray arrayWithObjects:@"image_id", @"saved_at", @"image_path", nil];
        NSArray *value = [NSArray arrayWithObjects:image_id, saved_at, image_path, nil];
        NSDictionary *unit   = [NSDictionary dictionaryWithObjects:value forKeys:key];
        
        [images addObject:unit];
    }
    [da close];
    
    NSLog(@"getImageInfoFromDB : %@", images);
    return images
    ;
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
