//
//  ImageListViewController.h
//  development-01
//
//  Created by Motoi Hirata on 2013/11/29.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScrollView.h"

@interface ImageListViewController : UIViewController
{
    NSMutableArray * imageInfo;
}

-(void)setImagesByTagId:(NSNumber*)tag_id;
-(void)setTagId:(NSNumber*)tag_id;
@property(readwrite,nonatomic) float scrollPosition;
@property(readwrite,nonatomic) int scrolledPage;
@property ScrollView *scrollView;
@property NSNumber *tagId;
@property BOOL processing;
@end
