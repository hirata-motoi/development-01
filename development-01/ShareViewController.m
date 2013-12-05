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

@interface ShareViewController ()

@end

@implementation ShareViewController

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
    [self showSareImageList];
}

- (void)showSareImageList
{
    [self getShareTagImages];
    ScrollView *scrollView = [[ScrollView alloc] init];
    scrollView.frame = self.view.bounds;
    CGRect frameSize = [[UIScreen mainScreen] applicationFrame];
    self.tableView = [[UITableView alloc] initWithFrame:scrollView.frame style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.7 alpha:0.7];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [scrollView addSubview:self.tableView];
    [self.view addSubview:scrollView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.shareImageViewArray count];
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"basis-cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//    }
    cell.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    NSLog(@"index %d", indexPath.row);
//    NSLog(@"%@", self.shareImageViewArray);
//    NSLog(@"shared %@", [self.shareImageViewArray objectAtIndex:indexPath.row]);

    if (indexPath.row % 2 == 1) {
        UIImage *iconImage=[UIImage imageNamed:@"icon.png"];
        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:iconImage];
        iconImageView.frame = CGRectMake(10, 10, 30, 30);
        [cell addSubview:iconImageView];
    }
    
    [cell addSubview:[self.shareImageViewArray objectAtIndex:indexPath.row]];
    return cell;
}

- (void) getShareTagImages
{
    self.shareImageViewArray = [[NSMutableArray alloc] init];
    NSString *stmt = @"select image_id from tag_map where tag_id = 1000 order by created_at;";
    DA *da = [DA da];
    [da open];
    FMResultSet *results = [da executeQuery:stmt];
    Common *cm = [[Common alloc] init];
    while ([results next]) {
        NSString *imagePath = [cm getImagePathThumbnail:[NSNumber numberWithInt:[results intForColumn:@"image_id"]]];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(200, 0, 110, 110);
        [self.shareImageViewArray addObject:imageView];
//        NSLog(@"index %d", [self.shareImageViewArray count]);
        UILabel *commentLabel = [[UILabel alloc] init];
        commentLabel.text = @"いいね！";
        commentLabel.backgroundColor = [UIColor whiteColor];
        commentLabel.frame = CGRectMake(50, 10, 100, 50);
        [self.shareImageViewArray addObject:commentLabel];
    }
    [da close];
}

@end
