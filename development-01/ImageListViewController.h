//
//  ImageListViewController.h
//  development-01
//
//  Created by Motoi Hirata on 2013/11/29.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageListViewController : UIViewController
{
    NSMutableArray * imageInfo;
}

-(void)setImagesByTagId:(NSNumber*)tag_id;
@end
