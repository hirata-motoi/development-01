//
//  SecondViewController.h
//  development-01
//
//  Created by Motoi Hirata on 2013/11/18.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController
-(UIViewController*)getSecondView;
-(UIViewController*)getSelf;
-(void)showZoomImageWrapper:(NSNumber*)image_id;
//-(void)showZoomImage:(NSNumber*)image_id;
@end
