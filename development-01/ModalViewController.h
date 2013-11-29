//
//  ModalViewController.h
//  development-01
//
//  Created by Motoi Hirata on 2013/11/28.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingView.h"
#import "AttachedTagsView.h"
@interface ModalViewController : UIViewController
<
    UIScrollViewDelegate,
    UIGestureRecognizerDelegate
>
{
    NSNumber *imageId;
    NSNumber *imageIndex;
    NSArray  *imageIds;
    UIScrollView *scrollViewObject;
    NSMutableDictionary *addedImages;
    SettingView *settingViewObject;
    AttachedTagsView *attachedTagsViewObject;
    NSMutableDictionary *addedTagLabels;
}
-(void)setImageInfo:(NSNumber*)image_id withIndex:(NSNumber*)index withImageIds:(NSArray*)image_ids;
-(void)touchesEndedForTag:(NSSet *)touches withEvent:(UIEvent *)event;
@end
