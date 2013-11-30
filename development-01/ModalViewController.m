//
//  ModalViewController.m
//  development-01
//
//  Created by Motoi Hirata on 2013/11/28.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import "ModalViewController.h"
#import "Common.h"
#import "HorizontalScrollView.h"
#import "SettingView.h"
#import "DA.h"
#import "FMDatabase.h"
#import "TagScrollView.h"
@interface ModalViewController ()


@end

@implementation ModalViewController
@synthesize addedImages;

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
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
    
    self.addedImages = [[NSMutableDictionary alloc]init];
	// Do any additional setup after loading the view.
    UIBarButtonItem *bbDone = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeView)];
    
    self.navigationItem.rightBarButtonItem = bbDone;
    
    //scrollviewのデリゲート設定
    HorizontalScrollView *scrollView = [[HorizontalScrollView alloc]init];
    scrollView.delegate = self;
    //scrollviewの各種設定
    scrollView.scrollEnabled = YES;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.7 alpha:1.0];
    scrollView.userInteractionEnabled = YES;
    
    //1ページのフレームサイズ
    scrollView.frame = self.view.bounds;
    CGRect aFrame = scrollView.frame;
    //スクロールするコンテンツの縦横サイズ
    scrollView.contentSize = CGSizeMake(aFrame.size.width * imageIds.count, aFrame.size.height);
    CGPoint pnt = CGPointMake(aFrame.size.width * [imageIndex intValue], 0);
    [scrollView setContentOffset:pnt animated:YES];
    
    scrollViewObject = scrollView;

    // タップされた画像とその前後だけ出す
    NSMutableArray *index_list = [[NSMutableArray alloc]init];
    [index_list addObject:imageIndex];
    if ( [imageIndex intValue] > 0 ) {
        int beforeIndex = [imageIndex intValue] - 1;
        NSNumber *beforeIndexNumber = [NSNumber numberWithInt:beforeIndex];
        [index_list addObject:beforeIndexNumber];
    }
    if ( [imageIndex intValue] < imageIds.count ) {
        int afterIndex = [imageIndex intValue] + 1;
        NSNumber *afterIndexNumber = [NSNumber numberWithInt:afterIndex];
        [index_list addObject:afterIndexNumber];
    }
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
    NSLog(@"scrollviewdidscroll called");
         
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
    [addedImages setValue:@"value" forKey:@"key"];
    NSLog(@"addedimages initialize : %@", addedImages);
    NSLog(@"addImagesToScrollView index_list : %@", index_list);
    for (NSNumber *index in index_list) {
        NSLog(@"content of addedImages : %@", [addedImages objectForKey:[index stringValue]]);
        if ( [addedImages objectForKey:[index stringValue]] != nil) {
            //すでに追加済の画像
            NSLog(@"continue!!!!");
            continue;
        }
        
        Common *cm = [[Common alloc]init];
        
        NSNumber *image_id = [imageIds objectAtIndex:[index intValue]];
        NSString *image_path = [cm getImagePathThumbnail:image_id];
        UIImage *image = [UIImage imageWithContentsOfFile:image_path];
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setFrame:[[UIScreen mainScreen]applicationFrame]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView setImage:image];
        imageView.tag = [image_id intValue];
        CGRect imageFrame = imageView.frame;
        CGRect aFrame = scrollViewObject.frame;
        NSLog(@"index int : %d", [index intValue]);
        imageFrame.origin.x = aFrame.size.width * [index intValue];
        [imageView setFrame:imageFrame];
        [scrollViewObject addSubview:imageView];
        
        NSLog(@"start to add images     index string:%@", [index stringValue]);
        //[addedImages setObject:imageView forKey:[index stringValue]];
        [addedImages setValue:imageView forKeyPath:[index stringValue]];
        NSLog(@"finish to add images");
    }
    NSLog(@"addedImages : %@", addedImages);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"tag touched!!!!");
    //タップされたタグのid
    UITouch *touch = [touches anyObject];
    NSInteger tag_id = touch.view.tag;
    NSLog(@"tag_id : %ld", (long)tag_id);
    NSNumber * tag_id_number = [NSNumber numberWithInteger:tag_id];
    NSLog(@"tag_id_number : %@", tag_id_number);

    DA * da = [DA da];
    [da open];
    NSMutableDictionary *tags_dictionary = [[NSMutableDictionary alloc]init];
    NSString *stmt = @"SELECT id, tag_name FROM tags";
    [da open];
    FMResultSet *results = [da executeQuery:stmt];
    while ([results next]) {
        NSNumber * tag_id   = [NSNumber numberWithInt:[results intForColumn:@"id"]];
        NSString * tag_name = [results stringForColumn:@"tag_name"];
        NSDictionary *unit = @{
            @"id":tag_id, @"tag_name": tag_name,
        };
        [tags_dictionary setObject:unit forKey:[tag_id stringValue]];
    }
    [da close];

    NSLog(@"addedTagLabels : %@", addedTagLabels);
    if ([addedTagLabels objectForKey:[tag_id_number stringValue]]) {
        NSLog(@" already tagged");
        //DB更新
        //object消す
        //座標を整える
        //再度表示
    } else {
        //tagを作る
        NSString *tag_name = [ [tags_dictionary objectForKey:[tag_id_number stringValue]] objectForKey:@"tag_name" ];
        
        //幅 : 25
        //高さ : 15
        //余白 : 5
        int extra = 5;
        int labelHeight = 15;
        int labelWidth  = 25;
        int labelOriginX = self.view.bounds.size.width - labelWidth - extra;

        NSLog(@"create tag start");
        UILabel *label = [[UILabel alloc]init];
        label.text = tag_name;
        label.adjustsFontSizeToFitWidth = YES;
        label.textColor = [UIColor whiteColor];
        label.userInteractionEnabled = YES;
        label.textAlignment = UITextAlignmentCenter;
        label.tag = tag_id;
        NSLog(@"label created");
        
        NSArray * allkeys = [addedTagLabels allKeys];
        int initialOriginY = extra + (labelHeight + extra) * allkeys.count;
        UIView * labelBackground = [[UIView alloc]initWithFrame:CGRectMake(labelOriginX, initialOriginY, labelWidth, labelHeight)];
        
        label.backgroundColor = [UIColor clearColor];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = label.frame;
        [gradient setColors:[NSArray arrayWithObjects:(id)([UIColor blackColor].CGColor), (id)([UIColor grayColor].CGColor),nil]];
        gradient.endPoint=CGPointMake(1.0, 0.0);
        [labelBackground.layer addSublayer:gradient];
        [labelBackground addSubview:label];
        label.text = tag_name;
        NSLog(@"label created imageId:%@", imageId);
        NSLog(@"addedImages %@", addedImages);
        
        id image_object = [addedImages objectForKey:[imageId stringValue]];
        [image_object addSubview:label];
        [addedTagLabels setObject:label forKey:[tag_id_number stringValue]];
        NSLog(@"image_object %@", image_object);
        
        NSArray *keys = [tags_dictionary allKeys];
        NSLog(@"keys : %@", keys);
        for (int i = 0; i<keys.count; i++) {
            
            NSString * key = [keys objectAtIndex:i];
            NSString *tag_name = [[tags_dictionary objectForKey:key] objectForKey:key];
            UILabel * obj = [[UILabel alloc]init];
            obj.text = tag_name;
            obj.tag = [key intValue];
            obj.backgroundColor  = [UIColor blackColor];
            
            int labelOriginY = extra + (labelHeight + extra) * i;
            obj.frame = CGRectMake(labelOriginX, labelOriginY, labelWidth, labelHeight);
            NSLog(@"label frame  : %d", obj.frame);
            
            [image_object addSubview:obj];
            NSLog(@"image_object added tags : %@", image_object);
        }
        //DB更新
        [da open];
        NSString *stmt_tag_save = @"INSERT INTO tag_map (tag_id, image_id, created_at) VALUES(?,?,?)";
        NSNumber *tag_id_number = [NSNumber numberWithInt:tag_id];

        NSDate* date = [NSDate date];
        [da executeUpdate:stmt_tag_save, tag_id_number, imageId, date];
        [da close];
    }

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touched!!!!");
    
    UITouch *touch = [touches anyObject];
    int image_id = touch.view.tag;
    id tt = touch.view;
    NSLog(@"touchesEnded tt : %@", tt);

    
    if (settingViewObject != nil ) {
        settingViewObject.hidden = !settingViewObject.hidden;
        attachedTagsViewObject.hidden = !attachedTagsViewObject.hidden;
        
        if (settingViewObject.hidden) {
            NSLog(@"hidden");
        } else {
            NSLog(@"revealed");
        }
    } else {
        CGRect rect = self.view.bounds;
        rect.origin.x = 0;
        rect.origin.y = rect.size.height - 50;
        rect.size.height = 50;
        
        SettingView *settingView = [[SettingView alloc]initWithFrame:rect];
        settingView.backgroundColor = [UIColor blueColor];
        
        TagScrollView *tagScrollView = [[TagScrollView alloc]init];
        tagScrollView.delegate = self;
        //scrollviewの各種設定
        tagScrollView.scrollEnabled = YES;
        tagScrollView.pagingEnabled = YES;
        tagScrollView.showsHorizontalScrollIndicator = NO;
        tagScrollView.showsVerticalScrollIndicator = NO;
        tagScrollView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.7 alpha:1.0];
        tagScrollView.userInteractionEnabled = YES;
        
        //tagの取得
        NSMutableArray * tags = [[NSMutableArray alloc]init];
        NSMutableDictionary *tags_dictionary = [[NSMutableDictionary alloc]init];
        NSString *stmt = @"SELECT id, tag_name FROM tags";
        DA *da = [DA da];
        [da open];
        FMResultSet *results = [da executeQuery:stmt];
        while ([results next]) {
            NSNumber * tag_id   = [NSNumber numberWithInt:[results intForColumn:@"id"]];
            NSString * tag_name = [results stringForColumn:@"tag_name"];
            NSDictionary *unit = @{
                @"id":tag_id,
                @"tag_name": tag_name,
            };
            [tags addObject:unit];
            [tags_dictionary setObject:tag_name forKey:[tag_id stringValue]];
        }
        [da close];
        
        //1ページのフレームサイズ
        int scrollViewWidth = ((50 + 10) * tags.count + 10) < self.view.bounds.size.width ? self.view.bounds.size.width : ((50 + 10) * tags.count + 10);
        int scrollViewHeight = 40;
        int scrollViewOriginX = 0;
        int scrollViewOriginY = 5;
        
        CGRect screenRect = self.view.bounds;
        tagScrollView.frame = CGRectMake(0, 15, screenRect.size.width, 30);
        
        //スクロールするコンテンツの縦横サイズ
        tagScrollView.contentSize = CGSizeMake(scrollViewWidth, scrollViewHeight);
        
        //ラベルを作る
        for (int i = 0; i<tags.count; i++) {
            NSDictionary * unit = [tags objectAtIndex:i];
            NSNumber * tag_id   = [unit objectForKey:@"id"];
            NSString * tag_name = [unit objectForKey:@"tag_name"];
            NSLog(@"tag_name : %@", tag_name);
//            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake((10 + (50 + 10)* i), 0, 50, 40)];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 40)];
            label.text = tag_name;
            label.adjustsFontSizeToFitWidth = YES;
            label.textColor = [UIColor whiteColor];
            label.userInteractionEnabled = YES;
            label.textAlignment = UITextAlignmentCenter;
            //label.tag = [tag_id integerValue];
            
            UIView * labelBackground = [[UIView alloc]initWithFrame:CGRectMake((10 + (50 + 10)* i), 0, 50, 40)];
            label.backgroundColor = [UIColor clearColor];
            CAGradientLayer *gradient = [CAGradientLayer layer];
            [gradient setColors:[NSArray arrayWithObjects:(id)([UIColor blackColor].CGColor), (id)([UIColor grayColor].CGColor),nil]];
            gradient.frame = CGRectMake(0, 0, 50, 40);
            gradient.endPoint=CGPointMake(1.0, 0.0);
            [labelBackground.layer addSublayer:gradient];
            [labelBackground addSubview:label];
            labelBackground.tag = [tag_id integerValue];
            label.text = tag_name;
            
            UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTapped:)];
            labelBackground.userInteractionEnabled = YES;
            [labelBackground addGestureRecognizer:recognizer];
            label.userInteractionEnabled = YES;
            [label addGestureRecognizer:recognizer];

            [tagScrollView addSubview:labelBackground];
        }
        [settingView addSubview:tagScrollView];
        [self.view addSubview:settingView];
        settingViewObject = settingView;
        
        //attachedTagsViewを作る
        NSNumber *image_index = [NSNumber numberWithInteger:[imageIds indexOfObject:[NSNumber numberWithInt:image_id]]];
        NSString *stmt_tag_map = @"SELECT tag_id FROM tag_map WHERE image_id = ?";
        [da open];
        FMResultSet *results_tag_map = [da executeQuery:stmt_tag_map, image_id];
        int i = 0;
        while ([results_tag_map next]) {
            NSNumber *tag_id = [NSNumber numberWithInteger:[results intForColumn:@"tag_id"]];
            NSString *tag_name = [tags_dictionary objectForKey:[tag_id stringValue]];
            
            //幅 : 25
            //高さ : 15
            //余白 : 5
            int extra = 5;
            int labelHeight = 15;
            int labelWidth  = 25;
            int labelOriginX = self.view.bounds.size.width - labelWidth - extra;
            int labelOriginY = extra + (labelHeight + extra) * i;
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(labelOriginX, labelOriginY, labelWidth, labelHeight)];
            label.text = tag_name;
            label.adjustsFontSizeToFitWidth = YES;
            label.textColor = [UIColor whiteColor];
            label.userInteractionEnabled = YES;
            label.textAlignment = UITextAlignmentCenter;
            label.tag = tag_id;
            
            UIView * labelBackground = [[UIView alloc]initWithFrame:label.bounds];
            label.backgroundColor = [UIColor clearColor];
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = label.frame;
            [gradient setColors:[NSArray arrayWithObjects:(id)([UIColor blackColor].CGColor), (id)([UIColor grayColor].CGColor),nil]];
            gradient.endPoint=CGPointMake(1.0, 0.0);
            [labelBackground.layer addSublayer:gradient];
            [labelBackground addSubview:label];
            label.text = tag_name;
            
            id image_object = [addedImages objectForKey:[image_index stringValue]];
            [image_object addSubview:label];
            [addedTagLabels setObject:label forKey:[tag_id stringValue]];
            
            i++;
        }
        
    }
}

- (void)labelTapped:(UITapGestureRecognizer*)recognizer {
    NSLog(@"tapped label");
    
    NSLog(@"tag touched!!!!");
    //タップされたタグのid
    NSLog(@"view : %@", recognizer.view);
    NSInteger tag_id = recognizer.view.tag;
    NSLog(@"tag_id : %ld", (long)tag_id);
    NSNumber * tag_id_number = [NSNumber numberWithInteger:tag_id];
    NSLog(@"tag_id_number : %@", tag_id_number);
    
    DA * da = [DA da];
    [da open];
    NSMutableDictionary *tags_dictionary = [[NSMutableDictionary alloc]init];
    NSString *stmt = @"SELECT id, tag_name FROM tags";
    [da open];
    FMResultSet *results = [da executeQuery:stmt];
    while ([results next]) {
        NSNumber * tag_id   = [NSNumber numberWithInt:[results intForColumn:@"id"]];
        NSString * tag_name = [results stringForColumn:@"tag_name"];
        NSDictionary *unit = @{
                               @"id":tag_id, @"tag_name": tag_name,
                               };
        [tags_dictionary setObject:unit forKey:[tag_id stringValue]];
    }
    [da close];
    
    NSLog(@"addedTagLabels : %@", addedTagLabels);
    if ([addedTagLabels objectForKey:[tag_id_number stringValue]]) {
        NSLog(@" already tagged");
        //DB更新
        //object消す
        //座標を整える
        //再度表示
    } else {
        //tagを作る
        NSString *tag_name = [ [tags_dictionary objectForKey:[tag_id_number stringValue]] objectForKey:@"tag_name" ];
        
        //幅 : 25
        //高さ : 15
        //余白 : 5
        int extra = 5;
        int labelHeight = 15;
        int labelWidth  = 25;
        int labelOriginX = self.view.bounds.size.width - labelWidth - extra;
        
        NSLog(@"create tag start");
        UILabel *label = [[UILabel alloc]init];
        label.text = tag_name;
        label.adjustsFontSizeToFitWidth = YES;
        label.textColor = [UIColor whiteColor];
        label.userInteractionEnabled = YES;
        label.textAlignment = UITextAlignmentCenter;
        label.tag = tag_id;
        NSLog(@"label created");
        
        NSArray * allkeys = [addedTagLabels allKeys];
        int initialOriginY = extra + (labelHeight + extra) * allkeys.count;
        UIView * labelBackground = [[UIView alloc]initWithFrame:CGRectMake(labelOriginX, initialOriginY, labelWidth, labelHeight)];
        
        label.backgroundColor = [UIColor clearColor];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = label.frame;
        [gradient setColors:[NSArray arrayWithObjects:(id)([UIColor blackColor].CGColor), (id)([UIColor grayColor].CGColor),nil]];
        gradient.endPoint=CGPointMake(1.0, 0.0);
        [labelBackground.layer addSublayer:gradient];
        [labelBackground addSubview:label];
        label.text = tag_name;
        NSLog(@"label created imageId:%@", imageId);
        NSLog(@"addedImages %@", addedImages);
        
        id image_object = [addedImages objectForKey:[imageId stringValue]];
        [image_object addSubview:label];
        [addedTagLabels setObject:label forKey:[tag_id_number stringValue]];
        NSLog(@"image_object %@", image_object);
        
        NSArray *keys = [tags_dictionary allKeys];
        NSLog(@"keys : %@", keys);
        for (int i = 0; i<keys.count; i++) {
            
            NSString * key = [keys objectAtIndex:i];
            NSString *tag_name = [[tags_dictionary objectForKey:key] objectForKey:key];
            UILabel * obj = [[UILabel alloc]init];
            obj.text = tag_name;
            obj.tag = [key intValue];
            obj.backgroundColor  = [UIColor blackColor];
            
            int labelOriginY = extra + (labelHeight + extra) * i;
            obj.frame = CGRectMake(labelOriginX, labelOriginY, labelWidth, labelHeight);
            NSLog(@"label frame  : %d", obj.frame);
            
            [image_object addSubview:obj];
            NSLog(@"image_object added tags : %@", image_object);
        }
        //DB更新
        [da open];
        NSString *stmt_tag_save = @"INSERT INTO tag_map (tag_id, image_id, created_at) VALUES(?,?,?)";
        NSNumber *tag_id_number = [NSNumber numberWithInt:tag_id];
        
        NSDate* date = [NSDate date];
        [da executeUpdate:stmt_tag_save, tag_id_number, imageId, date];
        [da close];
    }

}

@end
