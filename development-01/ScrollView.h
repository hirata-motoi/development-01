//
//  ScrollView.h
//  development-01
//
//  Created by Motoi Hirata on 2013/11/25.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecondViewController.h"

@interface ScrollView : UIScrollView
{
    SecondViewController *viewControllerObject;
}
-(void)setViewControllerObject:(SecondViewController*)vc;
@end
