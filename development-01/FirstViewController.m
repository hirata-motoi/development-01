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

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    Common *cm = [[Common alloc] init];
    [cm databaseInitializer];
    [cm filesystemInitializer];
//    [cm kickImageSync];
    [self showTagImageList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");
    [super viewWillAppear:animated];
    [self showTagImageList];
}

- (void)showTagImageList {
    // Create scrollView
    ScrollView *scrollView = [[ScrollView alloc] init];
    scrollView.frame = self.view.bounds;

    // get all kind of taged id
    NSMutableArray *tagIds = [self getAllTagedIds];

    // get newest image of each tag
    NSMutableArray *eachTagImageInfo = [[NSMutableArray alloc] init];
    for (NSNumber *tagId in tagIds) {
        NSDictionary *imageInfo = [self getEachTagImageInfo:tagId];
        [eachTagImageInfo addObject:imageInfo];
    }
    
    // imageViewを作ってscrollViewにはりつけ
    int count = 0;
    for ( NSDictionary *unit in eachTagImageInfo) {
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
    // add scrollView
    NSInteger heightCount = floor(count / 3) + 1;
    scrollView.contentSize = CGSizeMake(320, (120 * heightCount));
    [self.view addSubview:scrollView];
}

- (NSMutableArray*)getAllTagName{
    NSMutableArray *tagNames = [[NSMutableArray alloc] init];
    NSString *stmt = @"select tag_name from tags;";
    
    DA *da = [DA da];
    [da open];
    FMResultSet *results = [da executeQuery:stmt];
    while ([results next]) {
        NSString *tag = [NSString stringWithString:[results stringForColumn:@"tag_name"]];
        [tagNames addObject:tag];
        NSLog(@"string:%@", tag);
    }
    [da close];
    return tagNames;
}

- (NSMutableArray*)getAllTagedIds{
    NSMutableArray *tagId = [[NSMutableArray alloc] init];
    NSString *stmt = @"select tag_id from tag_map group by tag_id;";
    
    DA *da = [DA da];
    [da open];
    FMResultSet *results = [da executeQuery:stmt];
    while ([results next]) {
        NSNumber *id = [NSNumber numberWithInt:[results intForColumn:@"tag_id"]];
        [tagId addObject:id];
    }
    [da close];
    return tagId;
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
    NSLog(@"string:%@", image_path);
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
@end
