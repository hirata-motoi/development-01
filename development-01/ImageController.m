//
//  ImageController.m
//  development-01
//
//  Created by Motoi Hirata on 2013/11/27.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import "ImageController.h"
#import "Common.h"

@implementation ImageController

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (ImageController*)initWithImageId:(NSNumber*)image_id withRect:(CGRect)rect {
    
    self = [super initWithFrame:rect];
    if (self) {
        // imageを取得
        Common *cm = [[Common alloc]init];
        NSString *image_path = [cm getImagePathThumbnail:image_id];
        UIImage *image = [UIImage imageWithContentsOfFile:image_path];
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setFrame:[[UIScreen mainScreen]applicationFrame]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView setImage:image];
        
        [self addSubview:imageView];
    }
    return self;
}

- (void)closeImageView:(id)sender {
    [self removeFromSuperview];
}

@end
