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

@interface FirstViewController ()
- (void) showImageListModal:(UITapGestureRecognizer*)gesture;

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    Common *cm = [[Common alloc] init];
    [cm databaseInitializer];
    [cm filesystemInitializer];
    [cm kickImageSync];
//    [self showTagImageList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showTagImageList];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    for (UIView *view in [self.view subviews]) {
        [view removeFromSuperview];
    }
}

// sort function
int sortArray(id item1, id item2, void *context) {    
  int number1 = [item1 intValue];
  int number2 = [item2 intValue];
  return number2 - number1;
}

- (void)showTagImageList {
    // Create scrollView
    ScrollView *scrollView = [[ScrollView alloc] init];
    scrollView.frame = self.view.bounds;

    // get all taged id sorted by saved_id
    // tagId = [tag_id, created_at]
    NSMutableDictionary *tagIds = [self getAllTagedIds];
    
    NSArray *testArray = [tagIds allValues];
    for(NSNumber *test in testArray) {
    }
    testArray = [tagIds allKeys];
    for(NSNumber *test in testArray) {
    }
    
    NSSortDescriptor *descDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    NSArray *sortedCreatedAt = [[tagIds allValues] sortedArrayUsingDescriptors:@[descDescriptor]];

    // get newest image details for each tag
    // TODO : created_atが被ってると表示おかしくなる
    NSMutableArray *eachTagImageInfo = [[NSMutableArray alloc] init];
    for (NSNumber *createdAt in sortedCreatedAt) {
        NSNumber *tagId = [[NSNumber alloc] init];
        for (NSNumber *key in [tagIds allKeys]) {
            if(createdAt == [tagIds objectForKey:key]) {
                tagId = key;
            }
        }
        NSDictionary *imageInfo = [self getEachTagImageInfo:tagId];
        [eachTagImageInfo addObject:imageInfo];
    }
    
    // imageViewを作ってscrollViewにはりつけ
    int count = 0;
    
    // ALL 汚い 直す
    NSString *allstmt = @"select id from image_common order by updated_at desc limit 1;";
    DA *da = [DA da];
    [da open];
    FMResultSet *allresults = [da executeQuery:allstmt];
    NSNumber *allImageId = [[NSNumber alloc] init];
    while ([allresults next]) {
        allImageId = [NSNumber numberWithInt:[allresults intForColumn:@"id"]];
    }
    [da close];
    Common *cm = [[Common alloc] init];
    NSString *allImagePath = [cm getImagePathThumbnail:allImageId];
    UIImage *allImage = [UIImage imageWithContentsOfFile:allImagePath];
    UIImageView *allImageView = [[UIImageView alloc] initWithImage:allImage];
    allImageView.tag = [allImageId intValue];
    allImageView.userInteractionEnabled = YES;
    int x,y;
    x = ((count % 3) * 100) + 10;
    y = ((count / 3) * 110) + 10;
        
    allImageView.frame = CGRectMake(x, y, 90, 90);
        
    [scrollView insertSubview:allImageView atIndex:[self.view.subviews count]];
    
    UILabel *allTagLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y + 90, 90, 20)];
    allTagLabel.textColor = [UIColor blueColor];
    allTagLabel.font = [UIFont fontWithName:@"AppleGothic" size:12];
    allTagLabel.textAlignment = NSTextAlignmentCenter;
    allTagLabel.text = @"all";
    allTagLabel.userInteractionEnabled = YES;
    [allTagLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImageListModal:)];
    singleTap.delegate = self;
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [allTagLabel addGestureRecognizer:singleTap];
    [allImageView addGestureRecognizer:singleTap];
    [scrollView insertSubview:allTagLabel atIndex:[self.view.subviews count]];
    
    
    count++;
    // 未分類 汚い 直す
    NSString *allstmt2 = @"select id from image_common;";
    NSString *tagstmt = @"select image_id from tag_map group by image_id;";
    [da open];
    FMResultSet *allresults2 = [da executeQuery:allstmt2];
    NSMutableArray *allarray = [[NSMutableArray alloc] init];
    while ([allresults2 next]) {
        [allarray addObject:[NSNumber numberWithInt:[allresults2 intForColumn:@"id"]]];
    }
    FMResultSet *tagresults = [da executeQuery:tagstmt];
    NSMutableArray *tagarray = [[NSMutableArray alloc] init];
    while ([tagresults next]) {
        [tagarray addObject:[NSNumber numberWithInt:[tagresults intForColumn:@"image_id"]]];
    }
    [da close];
    
    NSMutableSet *allSet = [NSMutableSet setWithArray:allarray];
    NSMutableSet *tagSet = [NSMutableSet setWithArray:tagarray];
    [allSet minusSet:tagSet];
    NSArray *unTagArray = [allSet allObjects];
    
    // in (?) でエラーが出たのでこの形で
    NSString *unTagStmt1 = @"select id from image_common where id in (";
    NSString *unTagStmt2 = @") order by updated_at desc limit 1;";
    NSString *joined = [unTagArray componentsJoinedByString:@","];
    NSString *unTagStmt = [[unTagStmt1 stringByAppendingString:joined]stringByAppendingString:unTagStmt2];
    
    [da open];
    FMResultSet *unSetResults = [da executeQuery:unTagStmt];
    NSNumber *unTagImageId = [[NSNumber alloc] init];
    while ([unSetResults next]) {
        unTagImageId = [NSNumber numberWithInt:[unSetResults intForColumn:@"id"]];
    }
    [da close];
    
    NSString *unTagImagePath = [cm getImagePathThumbnail:unTagImageId];
    UIImage *unTagImage = [UIImage imageWithContentsOfFile:unTagImagePath];
    UIImageView *unTagImageView = [[UIImageView alloc] initWithImage:unTagImage];
    unTagImageView.tag = [unTagImageId intValue];
    unTagImageView.userInteractionEnabled = YES;
    x = ((count % 3) * 100) + 10;
    y = ((count / 3) * 110) + 10;
        
    unTagImageView.frame = CGRectMake(x, y, 90, 90);
        
    [scrollView insertSubview:unTagImageView atIndex:[self.view.subviews count]];
    
    UILabel *unTagLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y + 90, 90, 20)];
    unTagLabel.textColor = [UIColor blueColor];
    unTagLabel.font = [UIFont fontWithName:@"AppleGothic" size:12];
    unTagLabel.textAlignment = NSTextAlignmentCenter;
    unTagLabel.text = @"untagged";
    [scrollView insertSubview:unTagLabel atIndex:[self.view.subviews count]];
    
    
    count++;
    // その他tag
    for ( NSDictionary *unit in eachTagImageInfo) {
        NSString *image_path = [unit objectForKey:@"image_path"];
        UIImage *image = [UIImage imageWithContentsOfFile:image_path];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.tag = [[unit objectForKey:@"image_id"] intValue];
        imageView.userInteractionEnabled = YES;
        NSNumber *tag_id = [unit objectForKey:@"tag_id"];
        
        int x,y;
        x = ((count % 3) * 100) + 10;
        y = ((count / 3) * 110) + 10;
        
        imageView.frame = CGRectMake(x, y, 90, 90);
        
        [scrollView insertSubview:imageView atIndex:[self.view.subviews count]];
        
        UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y + 90, 90, 20)];
        tagLabel.textColor = [UIColor blueColor];
        tagLabel.font = [UIFont fontWithName:@"AppleGothic" size:12];
        tagLabel.textAlignment = NSTextAlignmentCenter;
        //TODO: it should be in module, tag name from tag_id;
        tagLabel.text = [self getTagNameById:tag_id];
        [scrollView insertSubview:tagLabel atIndex:[self.view.subviews count]];
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

- (IBAction)testKickButtonTap:(id)sender {

    Common *cm = [[Common alloc] init];
    [cm kickImageSync];
}

- (void)showImageListModal:(UITapGestureRecognizer*)gesture {
    NSLog(@"sender : %@", gesture.view);
    NSString * text = @"testtext";
    ImageListViewController *viewController = [[ImageListViewController alloc]init];
    [viewController setImagesByTag:text];
    
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:viewController];
    navigationController.navigationBar.translucent = YES;
    navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    [self presentModalViewController:navigationController animated:YES];
}


@end
