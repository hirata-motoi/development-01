//
//  FirstViewController.m
//  development-01
//
//  Created by Motoi Hirata on 2013/11/18.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import "FirstViewController.h"
#import "DA.h"
#import "FMDatabase.h"
#import "Common.h"
#import "ScrollView.h"
#import "ImageListViewController.h"
#import "AppDelegate.h"

@interface FirstViewController ()
- (void) showImageListModal:(UITapGestureRecognizer*)gesture;

@end

@implementation FirstViewController

@synthesize progressView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
 
    Common *cm = [[Common alloc] init];
    [cm databaseInitializer];
    [cm filesystemInitializer];
    [cm kickImageSync];
    //通知受信
    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(respondTest:)
                   name:@"barProgress"
                 object:nil];
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
    [super viewWillAppear:animated];
    [self setNavigationBar];
    [self showTagImageList];
    //bar表示
    progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    CGSize pSize = progressView.frame.size;
    CGSize vSize = self.view.frame.size;
    progressView.frame = CGRectMake(10, 10, vSize.width - 20, pSize.height);
    progressView.trackTintColor = [UIColor blackColor];
    progressView.progressTintColor = [UIColor redColor];
    progressView.progress = 0.0f;
    progressView.hidden = YES;
    [self.view addSubview:progressView];
}


- (void)showTagImageList {
    AppDelegate *app =  [[UIApplication sharedApplication] delegate];
    // Create scrollView
    ScrollView *scrollView = [[ScrollView alloc] init];
    CGRect srect = self.view.frame;
    srect.origin.y = app.naviBarHeight;
    scrollView.frame = srect;
    

    // get all taged id sorted by saved_id
    // tagId = [tag_id, created_at]
    NSMutableDictionary *tagIds = [self getAllTagedIds];
    
    NSSortDescriptor *descDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    NSArray *sortedCreatedAt = [[tagIds allValues] sortedArrayUsingDescriptors:@[descDescriptor]];

    // get newest image details for each tag
    // TODO : created_atが被ってると表示おかしくなる けどmicro secで記録されてるから多分大丈夫
    NSMutableArray *eachTagImageInfo = [[NSMutableArray alloc] init];
    NSMutableArray *favoriteTagImageInfo = [[NSMutableArray alloc] init];
    for (NSNumber *createdAt in sortedCreatedAt) {
        NSNumber *tagId = [[NSNumber alloc] init];
        for (NSNumber *key in [tagIds allKeys]) {
            if(createdAt == [tagIds objectForKey:key]) {
                tagId = key;
            }
        }
        NSDictionary *imageInfo = [self getEachTagImageInfo:tagId];
        if ([tagId intValue] == 1) {
            [favoriteTagImageInfo addObject:imageInfo];
            continue;
        }
        [eachTagImageInfo addObject:imageInfo];
    }
    [favoriteTagImageInfo addObjectsFromArray:eachTagImageInfo];
    eachTagImageInfo = favoriteTagImageInfo;
    
    // imageViewを作ってscrollViewにはりつけ
    int count = 0;
    Common *cm = [[Common alloc] init];
    int x,y;
    DA *da = [DA da];
    
    // ALL
    NSArray *allImages = [cm getImagesByTag:[NSNumber numberWithInt:-1]];
    UIImageView *allImageView;
    int slice;
    if ([allImages count] < 3) {
        slice = [allImages count]-1;
    } else {
        slice = 2;
    }
    for (int i = slice; i >= 0; i--) {
        NSString *allImagePath = [[allImages objectAtIndex:i] objectForKey:@"image_path"];
        UIImage *allImage = [UIImage imageWithContentsOfFile:allImagePath];
        allImageView = [[UIImageView alloc] initWithImage:allImage];
        allImageView.tag = -1; // -1:all  -2:untagged
        allImageView.userInteractionEnabled = YES;
        x = ((count % 3) * 105) + i*5 + 5;
        y = ((count / 3) * 115) + i*5 + 5;
        allImageView.frame = CGRectMake(x, y, 90, 90);
        [scrollView insertSubview:allImageView atIndex:2-i];
    }
    //モジュール化したいですね
    UIView *allBudge = [[UIView alloc] init];
    allBudge.frame = CGRectMake(x, y, 40, 15);
    UILabel *allBudgeLabel = [[UILabel alloc] init];
    allBudgeLabel.text = [NSString stringWithFormat:@"%d", [allImages count]];
    allBudgeLabel.textColor = [UIColor whiteColor];
    allBudgeLabel.frame = CGRectMake(0, 0, 40, 15);
    allBudgeLabel.backgroundColor = app.naviBarColor;
    allBudgeLabel.textAlignment = NSTextAlignmentCenter;
    [allBudge addSubview:allBudgeLabel];
    [scrollView insertSubview:allBudge atIndex:3];
    
    UILabel *allTagLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y + 90, 90, 20)];
    allTagLabel.textColor = [UIColor blueColor];
    allTagLabel.font = [UIFont fontWithName:@"AppleGothic" size:12];
    allTagLabel.textAlignment = NSTextAlignmentCenter;
    allTagLabel.text = @"all";
    allTagLabel.tag = -1; // -1:all  -2:untagged
    allTagLabel.userInteractionEnabled = YES;
    [allTagLabel setUserInteractionEnabled:YES];
    // tap時のgesture
    UITapGestureRecognizer *singleTapAll = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImageListModal:)];
    singleTapAll.delegate = self;
    singleTapAll.numberOfTapsRequired = 1;
    singleTapAll.numberOfTouchesRequired = 1;
    UITapGestureRecognizer *singleTapAll2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImageListModal:)];
    singleTapAll2.delegate = self;
    singleTapAll2.numberOfTapsRequired = 1;
    singleTapAll2.numberOfTouchesRequired = 1;
    [allTagLabel addGestureRecognizer:singleTapAll];
    [allImageView addGestureRecognizer:singleTapAll2];
    [scrollView insertSubview:allTagLabel atIndex:[self.view.subviews count]];
    count++;
    
    // 未分類 汚い 直す
    NSArray *unTagImages = [cm getImagesByTag:[NSNumber numberWithInt:-2]];
    UIImageView *unTagImageView;
    if ([unTagImages count] < 3) {
        slice = [unTagImages count]-1;
    } else {
        slice = 2;
    }
    for (int i = slice; i >= 0; i--) {
        NSString *unTagImagePath = [[unTagImages objectAtIndex:i] objectForKey:@"image_path"];
        UIImage *unTagImage = [UIImage imageWithContentsOfFile:unTagImagePath];
        unTagImageView = [[UIImageView alloc] initWithImage:unTagImage];
        unTagImageView.tag = -2;// -1:all  -2:untagged
        unTagImageView.userInteractionEnabled = YES;
        x = ((count % 3) * 105) + i*5 + 5;
        y = ((count / 3) * 115) + i*5 + 5;
        unTagImageView.frame = CGRectMake(x, y, 90, 90);
        [scrollView insertSubview:unTagImageView atIndex:2-i];
    }
    UIView *unTagBudge = [[UIView alloc] init];
    unTagBudge.frame = CGRectMake(x, y, 40, 15);
    UILabel *unTagBudgeLabel = [[UILabel alloc] init];
    unTagBudgeLabel.text = [NSString stringWithFormat:@"%d", [unTagImages count]];
    unTagBudgeLabel.textColor = [UIColor whiteColor];
    unTagBudgeLabel.frame = CGRectMake(0, 0, 40, 15);
    unTagBudgeLabel.backgroundColor = app.naviBarColor;
    unTagBudgeLabel.textAlignment = NSTextAlignmentCenter;
    [unTagBudge addSubview:unTagBudgeLabel];
    [scrollView insertSubview:unTagBudge atIndex:3];
        
    UILabel *unTagLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y + 90, 90, 20)];
    unTagLabel.textColor = [UIColor blueColor];
    unTagLabel.font = [UIFont fontWithName:@"AppleGothic" size:12];
    unTagLabel.textAlignment = NSTextAlignmentCenter;
    unTagLabel.text = @"untagged";
    unTagLabel.tag = -2;// -1:all  -2:untagged
    unTagLabel.userInteractionEnabled = YES;
    // tap時のgesture
    UITapGestureRecognizer *singleTapUntag = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImageListModal:)];
    singleTapUntag.delegate = self;
    singleTapUntag.numberOfTapsRequired = 1;
    singleTapUntag.numberOfTouchesRequired = 1;
    UITapGestureRecognizer *singleTapUntag2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImageListModal:)];
    singleTapUntag2.delegate = self;
    singleTapUntag2.numberOfTapsRequired = 1;
    singleTapUntag2.numberOfTouchesRequired = 1;
    [unTagLabel addGestureRecognizer:singleTapUntag];
    [unTagImageView addGestureRecognizer:singleTapUntag2];
    [scrollView insertSubview:unTagLabel atIndex:[self.view.subviews count]];
    
    count++;
    
    // その他tag
    for ( NSDictionary *unit in eachTagImageInfo) {
        // actionタグはskipする
        if ([[unit objectForKey:@"tag_id"]intValue]>= 1000) {
            continue;
        }
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImageListModal:)];
        singleTap.delegate = self;
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImageListModal:)];
        singleTap2.delegate = self;
        singleTap2.numberOfTapsRequired = 1;
        singleTap2.numberOfTouchesRequired = 1;
        
        NSNumber *tag_id = [unit objectForKey:@"tag_id"];
        NSArray *tagImages = [cm getImagesByTag:tag_id];
        UIImageView *imageView;
        if ([tagImages count] < 3) {
            slice = [tagImages count]-1;
        } else {
            slice = 2;
        }
        for (int i = slice; i >= 0; i--) {
            NSString *image_path = [[tagImages objectAtIndex:i] objectForKey:@"image_path"];
            UIImage *image = [UIImage imageWithContentsOfFile:image_path];
            imageView = [[UIImageView alloc] initWithImage:image];
            imageView.tag = [[unit objectForKey:@"image_id"] intValue];
            imageView.userInteractionEnabled = YES;
            x = ((count % 3) * 105) + 5*i + 5;
            y = ((count / 3) * 115) + 5*i + 5;
            imageView.frame = CGRectMake(x, y, 90, 90);
            imageView.tag = [tag_id intValue];
        
            [scrollView insertSubview:imageView atIndex:2-i];
        }
        UIView *tagBudge = [[UIView alloc] init];
        tagBudge.frame = CGRectMake(x, y, 40, 15);
        UILabel *tagBudgeLabel = [[UILabel alloc] init];
        tagBudgeLabel.text = [NSString stringWithFormat:@"%d", [tagImages count]];
        tagBudgeLabel.textColor = [UIColor whiteColor];
        tagBudgeLabel.frame = CGRectMake(0, 0, 40, 15);
        tagBudgeLabel.backgroundColor = app.naviBarColor;
        tagBudgeLabel.textAlignment = NSTextAlignmentCenter;
        [tagBudge addSubview:tagBudgeLabel];
        [scrollView insertSubview:tagBudge atIndex:3];
        
        [imageView addGestureRecognizer:singleTap2];
        
        UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y + 90, 90, 20)];
        tagLabel.textColor = [UIColor blueColor];
        tagLabel.font = [UIFont fontWithName:@"AppleGothic" size:12];
        tagLabel.textAlignment = NSTextAlignmentCenter;
        tagLabel.tag = [tag_id intValue];
        tagLabel.userInteractionEnabled =YES;
        
        //TODO: it should be in module, tag name from tag_id;
        tagLabel.text = [self getTagNameById:tag_id];
        [scrollView insertSubview:tagLabel atIndex:[self.view.subviews count]];
        [tagLabel addGestureRecognizer:singleTap];

        count++;
    }
    // add scrollView
    NSInteger heightCount = floor(count / 3) + 1;
    scrollView.contentSize = CGSizeMake(320, (120 * heightCount));
    [self.view addSubview:scrollView];
}

- (NSMutableArray*)getTagNameById:(NSNumber*)tagId{
    NSString *stmt = @"select tag_name from tags where id = ?;";
    
    DA *da = [DA da];
    [da open];
    FMResultSet *results = [da executeQuery:stmt, tagId];
    NSString *tagName = [[NSString alloc] init];
    while ([results next]) {
        tagName = [NSString stringWithString:[results stringForColumn:@"tag_name"]];
    }
    [da close];
    return tagName;
}

- (NSMutableArray*)getAllTagedIds{
    NSMutableArray *tagId = [[NSMutableArray alloc] init];
    // Get all taged ids
    NSString *stmt = @"select tag_id from tag_map group by tag_id;";
    
    DA *da = [DA da];
    [da open];
    FMResultSet *results = [da executeQuery:stmt];
    NSMutableDictionary *tagInfo = [[NSMutableDictionary alloc] init];
    
    // roop for each taged id
    while ([results next]) {
        NSNumber *tag_id = [NSNumber numberWithInt:[results intForColumn:@"tag_id"]];
        NSString *stmt2 = @"select created_at from tag_map where tag_id = ? order by created_at desc limit 1;";
        FMResultSet *results2 = [da executeQuery:stmt2, tag_id];
        NSNumber *created_at = [[NSNumber alloc] init];
        NSNumber *image_id = [[NSNumber alloc] init];
        while ([results2 next]) {
            created_at = [NSNumber numberWithInt:[results2 intForColumn:@"created_at"]];
        }
        [tagInfo setObject:created_at forKey:tag_id];
    }
    [da close];
    return tagInfo;
}

- (NSDictionary*)getEachTagImageInfo:(NSNumber*)tagId {
    Common *cm = [[Common alloc] init];
    NSString *stmt = @"select image_id from tag_map where tag_id = ? order by created_at desc limit 1;";
    
    DA *da = [DA da];
    [da open];
    FMResultSet *results = [da executeQuery:stmt, tagId];
    NSNumber *image_id = [[NSNumber alloc] init];
    while ([results next]) {
        image_id = [NSNumber numberWithInt:[results intForColumn:@"image_id"]];
    }
    NSString *image_path = [cm getImagePathThumbnail:image_id];
    NSArray *key   = [NSArray arrayWithObjects:@"image_id", @"image_path", @"tag_id", nil];
    NSArray *value = [NSArray arrayWithObjects:image_id, image_path, tagId, nil];
    NSDictionary *imageInfo = [NSDictionary dictionaryWithObjects:value forKeys:key];
    [da close];
    return imageInfo;
}

- (void)showImageListModal:(UITapGestureRecognizer*)gesture {
    NSLog(@"sender : %@", gesture.view);
    
    int tag_id = gesture.view.tag;
    
    ImageListViewController *viewController = [[ImageListViewController alloc]init];
    viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    NSNumber *tag_id_number = [NSNumber numberWithInt:tag_id];
    [viewController setTagId:tag_id_number];
    
    [self presentModalViewController:viewController animated:YES];
}

- (void)respondTest:(NSNotification *)aNotification
{
    NSString *barProgress = [[aNotification userInfo] objectForKey:@"progress"];
    float progress = barProgress.floatValue;
    [self performSelectorOnMainThread:@selector(setLoaderProgress:) withObject:[NSNumber numberWithFloat:progress] waitUntilDone:NO];
}

- (void)setLoaderProgress:(NSNumber *)number
{
    progressView.hidden = NO;
    if(number.floatValue == 1.0f) {
        progressView.hidden = YES;
    }
    [progressView setProgress:number.floatValue animated:YES];
}

- (void)setNavigationBar {
    AppDelegate *app =  [[UIApplication sharedApplication] delegate];
    UINavigationBar * navigationBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width, app.naviBarHeight)];

    // ナビゲーションアイテムを生成
    UINavigationItem* title = [[UINavigationItem alloc] initWithTitle:@"Babyry"];
    [navigationBar pushNavigationItem:title animated:YES];

    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};

    NSString *ver = [[UIDevice currentDevice] systemVersion];
    int ver_int = [ver intValue];

    if (ver_int < 7) {
        [navigationBar setTintColor:app.naviBarColor];
    } else {
        navigationBar.barTintColor = app.naviBarColor;
    }



    UIImage *naviImage = [[UIImage imageNamed:@"appicon.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:1];
    UIImageView *naviImageView = [[UIImageView alloc] initWithImage:naviImage];
    naviImageView.frame = CGRectMake(80, 5, app.naviBarHeight*0.8, app.naviBarHeight*0.8);
    [navigationBar insertSubview:naviImageView atIndex:10];

    [self.view addSubview:navigationBar];
}

@end
