//
//  ScrollView.m
//  development-01
//
//  Created by Motoi Hirata on 2013/11/25.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import "ScrollView.h"
#import "Common.h"
#import "SecondViewController.h"
#import "FirstViewController.h"


@implementation ScrollView

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


- (void)setViewControllerObject:(SecondViewController*)vc {
    viewControllerObject = vc;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    int image_id = touch.view.tag;
    
    if (!image_id) {
        return;
    }
    
    NSNumber *image_id_number = [NSNumber numberWithInt:image_id];
    //[viewControllerObject showZoomImageWrapper:image_id_number];
    [self.nextResponder.nextResponder touchesBegan:touches withEvent:event];
}
@end
