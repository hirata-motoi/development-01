//
//  ShareViewController.h
//  development-01
//
//  Created by kenjiszk on 2013/11/30.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScrollView.h"

@interface ShareViewController : UIViewController

@property(nonatomic, strong) UITapGestureRecognizer *singleTap;
@property ScrollView *scrollView;
@property UITextView *textField;
@property UIView *textView;
@property int tabHeight;
@property int textHeight;

@end
