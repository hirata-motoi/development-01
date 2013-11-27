//
//  ImageViewController.m
//  development-01
//
//  Created by Motoi Hirata on 2013/11/27.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (ImageViewController*)initWithImageId:(NSNumber*)image_id withRect:(CGRect)rect {
    
    //self = [[super alloc]init];
    
    //if (self) {
        // imageを取得
    //    Common *cm = [[Common alloc]init];
    //    NSString *image_path = [cm getImagePathThumbnail:image_id];
    //    UIImage *image = [UIImage imageWithContentsOfFile:image_path];
    //    UIImageView *imageView = [[UIImageView alloc] init];
    //    [imageView setFrame:[[UIScreen mainScreen]applicationFrame]];
    //    imageView.contentMode = UIViewContentModeScaleAspectFit;
    //    [imageView setImage:image];
        
    //    [self addSubview:imageView];
    //}
    //return self;
    
//}

//- (void)closeImageView:(id)sender {
//    [self removeFromSuperview];
//}



@end
