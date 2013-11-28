//
//  ModalViewController.m
//  development-01
//
//  Created by Motoi Hirata on 2013/11/28.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import "ModalViewController.h"
#import "Common.h"

@interface ModalViewController ()


@end

@implementation ModalViewController

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
    
    //scrollviewのデリゲート設定
    UIScrollView *scrollView = [[UIScrollView alloc]init];
    scrollView.delegate = self;
    //scrollviewの各種設定
    scrollView.scrollEnabled = YES;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.7 alpha:1.0];
    
    //1ページのフレームサイズ
    scrollView.frame = self.view.bounds;
    CGRect aFrame = scrollView.frame;
    //スクロールするコンテンツの縦横サイズ
    scrollView.contentSize = CGSizeMake(aFrame.size.width * imageIds.count, aFrame.size.height);
    CGPoint pnt = CGPointMake(aFrame.size.width * [imageIndex intValue], 0);
    [scrollView setContentOffset:pnt animated:YES];
    
    scrollViewObject = scrollView;
    
    //とりあえず全部の写真をとってきて表示する
//    for (int i = 0; i<imageIds.count; i++) {
//        Common *cm = [[Common alloc]init];
//        NSNumber *image_id = [imageIds objectAtIndex:i];
//        NSString *image_path = [cm getImagePathThumbnail:image_id];
//        UIImage *image = [UIImage imageWithContentsOfFile:image_path];
//        UIImageView *imageView = [[UIImageView alloc] init];
//        [imageView setFrame:[[UIScreen mainScreen]applicationFrame]];
//        imageView.contentMode = UIViewContentModeScaleAspectFit;
//        [imageView setImage:image];
//        CGRect imageFrame = imageView.frame;
//        imageFrame.origin.x = aFrame.size.width * i;
//        [imageView setFrame:imageFrame];
//        
//        [scrollView addSubview:imageView];
//    }
    // タップされた画像とその前後だけ出す
    NSMutableArray *index_list = [[NSMutableArray alloc]init];
    [index_list addObject:imageIndex];
    NSLog(@"first : %@", index_list);
    if ( [imageIndex intValue] > 0 ) {
        int beforeIndex = [imageIndex intValue] - 1;
        NSNumber *beforeIndexNumber = [NSNumber numberWithInt:beforeIndex];
        [index_list addObject:beforeIndexNumber];
    }
    NSLog(@"second : %@", index_list);
    if ( [imageIndex intValue] < imageIds.count ) {
        int afterIndex = [imageIndex intValue] + 1;
        NSNumber *afterIndexNumber = [NSNumber numberWithInt:afterIndex];
        [index_list addObject:afterIndexNumber];
    }
    NSLog(@"third : %@", index_list);
    [self addImagesToScrollViewWithIndexes:index_list];
    

    //タップした時の処理を定義
    
    //settingviewをゲット
    //settingViewをaddSubviewする
    //settingViewをインスタンス変数にadd
    //タップ時の処理をここで定義
    
    
    //image_idからattachedTagsをゲット
    //attachedTagsをaddSubviewする
    //attachedTagsをインスタンス変数にadd
    //タップ時の処理をここで定義
    [self.view addSubview:scrollView];
}

- (void)closeView{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setImageInfo:(NSNumber*)image_id withIndex:(NSNumber*)index withImageIds:(NSArray*)image_ids {
    imageId = image_id;
    imageIndex = index;
    imageIds = image_ids;
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
         
    if (scrollViewObject != nil) {
        //現在のページ番号を調べる
        CGFloat pageWidth = scrollViewObject.frame.size.width;
        int pageNo = floor((scrollViewObject.contentOffset.x - pageWidth/2)/pageWidth);
    
        //前後の写真を読み込む
        int beforeNo = pageNo - 1;
        int afterNo  = pageNo + 1;
        //NSArray * index_list = [[NSArray alloc]initWithObjects:beforeNo, afterNo, nil];
        NSMutableArray *index_list = [[NSMutableArray alloc] init];
        if (beforeNo >= 0) {
            NSNumber *beforeNoNumber = [NSNumber numberWithInt:beforeNo];
            [index_list addObject:beforeNoNumber];
        }
        if (afterNo <= imageIds.count) {
            NSNumber *afterNoNumber = [NSNumber numberWithInt:afterNo];
            [index_list addObject:afterNoNumber];
        }

        [self addImagesToScrollViewWithIndexes:index_list];
    }
}

- (void)addImagesToScrollViewWithIndexes:(NSMutableArray*)index_list {
    NSLog(@"addImagesToScrollView index_list : %@", index_list);
    for (id index in index_list) {
        if ( [addedImages objectForKey:[index stringValue]] ) {
            //すでに追加済の画像
            continue;
        }
        
        Common *cm = [[Common alloc]init];
        
        NSNumber *image_id = [imageIds objectAtIndex:[index integerValue]];
        NSString *image_path = [cm getImagePathThumbnail:image_id];
        UIImage *image = [UIImage imageWithContentsOfFile:image_path];
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setFrame:[[UIScreen mainScreen]applicationFrame]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView setImage:image];
        CGRect imageFrame = imageView.frame;
        CGRect aFrame = scrollViewObject.frame;
        imageFrame.origin.x = aFrame.size.width * [index intValue];
        [imageView setFrame:imageFrame];
        [scrollViewObject addSubview:imageView];
        
        [addedImages setObject:@"1" forKey:[index stringValue]];
    }
}


@end
