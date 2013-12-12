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

@synthesize scrollPosition;
@synthesize scrolledPage;
@synthesize scrollView;
@synthesize tagId;

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
    [self setImagesByTagId:tagId];
    [self setNavigationBar]; 
}


- (void)viewWillAppear:(BOOL)animated {
     [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    return;
    scrollPosition = sender.contentOffset.y;
    if (scrollPosition > (74 * 10 * scrolledPage - self.view.bounds.size.height)) {
        //[self addImagesByScroll];
        [NSThread detachNewThreadSelector:@selector(afterViewDidAppear:) toTarget:self withObject:nil];
    }
}
    
- (void)closeView{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)setTagId:(NSNumber *) tag_id {
    tagId = tag_id;
}

-(void)setImagesByTagId:(NSNumber*)tag_id {
    //scrollviewのデリゲート設定
    scrollView = [[ScrollView alloc]init];
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor whiteColor];
    
    scrollPosition = 0;
    scrolledPage = 0;
    
    scrollView.frame = self.view.bounds;
//    [scrollView setViewControllerObject:(SecondViewController*)self];
    
    // DBからimage listを取得
    imageInfo = [self getImageInfoFromDB:tag_id];
    
    // imageViewを作ってscrollViewにはりつけ
    int count = 0;
//    // Should be global params
//    int HORIZONTAL_ROWS = 4;
//    for ( NSDictionary *unit in imageInfo) {
//        if (count > (HORIZONTAL_ROWS*10 - 1)) {
//            count++;
//            continue;
//        }
//        NSString *image_path = [unit objectForKey:@"image_path"];
//        UIImage *image = [UIImage imageWithContentsOfFile:image_path];
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//        imageView.tag = [[unit objectForKey:@"image_id"] intValue];
//        imageView.userInteractionEnabled = YES;
//        
//        int x,y;
//        x = ((count % HORIZONTAL_ROWS) * 78) + 4;
//        y = ((count / HORIZONTAL_ROWS) * 78) + 4 + 44;
//        
//        imageView.frame = CGRectMake(x, y, 74, 74);
//        
//        [scrollView insertSubview:imageView atIndex:[self.view.subviews count]];
//        count++;
//    }
    scrolledPage++;
    // viewにscrollViewをaddする
    count = [imageInfo count];
    NSInteger heightCount = floor(count / 4) + 1;
    scrollView.contentSize = CGSizeMake(320, (78 * heightCount + 44));
    [self.view addSubview:scrollView];
    [NSThread detachNewThreadSelector:@selector(afterViewDidAppear:) toTarget:self withObject:nil];
}

-(void)addImagesByScroll{
    int HORIZONTAL_ROWS = 4;
    int count = 0;
    for ( NSDictionary *unit in imageInfo) {
        if (count <= (HORIZONTAL_ROWS*10*scrolledPage - 1) || count > (HORIZONTAL_ROWS*10*(scrolledPage+1) - 1)) {
            count++;
            continue;
        }
        NSString *image_path = [unit objectForKey:@"image_path"];
        UIImage *image = [UIImage imageWithContentsOfFile:image_path];
        CGImageRef imageRef = [image CGImage];
        UIGraphicsBeginImageContext(CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)));
        [image drawAtPoint:CGPointMake(0,0)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.tag = [[unit objectForKey:@"image_id"] intValue];
        imageView.userInteractionEnabled = YES;
        
        int x,y;
        x = ((count % HORIZONTAL_ROWS) * 78) + 4;
        y = ((count / HORIZONTAL_ROWS) * 78) + 4 + 44;
        
        imageView.frame = CGRectMake(x, y, 74, 74);
        
        [scrollView insertSubview:imageView atIndex:[self.view.subviews count]];
        count++;
    }
    scrolledPage++;
    // viewにscrollViewをaddする
//    NSInteger heightCount = floor(count / 3);
//    scrollView.contentSize = CGSizeMake(320, (100 * heightCount + 20));
//    [self.view addSubview:scrollView];
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
        stmt = @"SELECT i.id, saved_at AS date FROM image_common i LEFT JOIN tag_map t ON i.id = t.image_id WHERE t.tag_id is NULL order by i.saved_at desc";
        results = [da executeQuery:stmt];
    }
    else {
        stmt = @"SELECT image_id AS id, created_at AS date FROM tag_map WHERE tag_id = ? order by created_at desc";
        results = [da executeQuery:stmt, tag_id];
    }

    while ([results next]) {
//        NSLog(@"result found");
        NSNumber *image_id   = [NSNumber numberWithInt:[results intForColumn:@"id"]];
        NSDate *saved_at     = [results dateForColumn:@"date"];
        NSString *image_path = [cm getImagePathThumbnail:(NSNumber*)image_id];
        
        NSArray *key   = [NSArray arrayWithObjects:@"image_id", @"saved_at", @"image_path", nil];
        NSArray *value = [NSArray arrayWithObjects:image_id, saved_at, image_path, nil];
        NSDictionary *unit   = [NSDictionary dictionaryWithObjects:value forKeys:key];
        
        [images addObject:unit];
    }
    [da close];
    
//    NSLog(@"getImageInfoFromDB : %@", images);
    return images;
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
    NSNumber * index_number = [NSNumber numberWithInt:index];
    ModalViewController *modalViewController = [[ModalViewController alloc] init];
    [modalViewController setImageInfo:image_id withIndex:index_number withImageIds:image_ids];
    
    
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:modalViewController];
    navigationController.navigationBar.translucent = YES;
    navigationController.navigationBar.tintColor = [UIColor blackColor];
    navigationController.navigationBar.hidden = YES;
    
    [self presentModalViewController:navigationController animated:YES];
}

- (void)setNavigationBar {
    UINavigationBar * navigationBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width, 44)];


    // ナビゲーションアイテムを生成
    UINavigationItem* title = [[UINavigationItem alloc] initWithTitle:@""];
    
    // backボタンを生成
    UIBarButtonItem * button = [[UIBarButtonItem alloc]initWithTitle:@"HOME" style:UIBarButtonItemStyleBordered target:self action:@selector(closeView)];
    // ナビゲーションアイテムの右側に戻るボタンを設置
    title.leftBarButtonItem = button;
    
    [navigationBar pushNavigationItem:title animated:YES];

    navigationBar.tintColor = [UIColor orangeColor];
    //navigationBar.alpha = 0.4f;
    navigationBar.translucent = YES;

    [self.view addSubview:navigationBar];
}

- (void) afterViewDidAppear:(id)arg { 
//    for(NSUInteger i = 0; i < [self subViewCount]; ++i) {
//        UIView *subView = [self subViewAt:i];
//        if(imageView) {
//            [self performSelectorOnMainThread:@selector(addView:) withObject:subView waitUntilDone:NO];
//        }
//    }
    int HORIZONTAL_ROWS = 4;
    int count = 0;
    for ( NSDictionary *unit in imageInfo) {
//        if (count <= (HORIZONTAL_ROWS*10*scrolledPage - 1) || count > (HORIZONTAL_ROWS*10*(scrolledPage+1) - 1)) {
//            count++;
//            continue;
//        }
        NSString *image_path = [unit objectForKey:@"image_path"];
        UIImage *image = [UIImage imageWithContentsOfFile:image_path];

        CGImageRef imageRef = [image CGImage];
        UIGraphicsBeginImageContext(CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)));
        [image drawAtPoint:CGPointMake(0,0)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        int x,y;
        x = ((count % HORIZONTAL_ROWS) * 78) + 4;
        y = ((count / HORIZONTAL_ROWS) * 78) + 4 + 44;
        

        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.tag = [[unit objectForKey:@"image_id"] intValue];
        imageView.userInteractionEnabled = YES;
        imageView.frame = CGRectMake(x, y, 74, 74);

        
        [scrollView insertSubview:imageView atIndex:[self.view.subviews count]];
        [self performSelectorOnMainThread:@selector(addView:) withObject:imageView waitUntilDone:NO];
        count++;
    }
    scrolledPage++;
}

- (void)addView:(id)subView {
    [scrollView addSubview:subView];
}

@end
