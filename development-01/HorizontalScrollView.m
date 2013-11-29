//
//  HorizontalScrollView.m
//  development-01
//
//  Created by Motoi Hirata on 2013/11/29.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import "HorizontalScrollView.h"

@implementation HorizontalScrollView

@synthesize touchedObjectType;

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

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    touchedObjectType = @"horizontal";
    NSLog(@"HorizontalScrollView touchesEnded");
	if (!self.dragging) {
        NSLog(@"not dragging  tag:%@", self);
        NSLog(@"%@", self.nextResponder);
        NSLog(@"%@", self.nextResponder.nextResponder);
		[self.nextResponder.nextResponder touchesEnded: touches withEvent:event];
	}
	[super touchesEnded: touches withEvent: event];
}

@end
