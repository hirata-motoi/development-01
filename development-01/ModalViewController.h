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
#import "Session.h"
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
    SettingView *settingViewObject;
    UITextView *commentViewObject;
    AttachedTagsView *attachedTagsViewObject;

}
@property (nonatomic,retain)NSMutableDictionary *addedImagesWithIndex;
@property (nonatomic,retain)NSMutableDictionary *imageIdIndexMap;
@property (nonatomic,retain)NSMutableDictionary *attachedTagIdsArrayByImageId;
@property (nonatomic,retain)NSMutableDictionary *attachedTagLabelsForImageId;
@property BOOL showSettingView;
@property (nonatomic,retain)NSMutableArray *existTagsArray;
@property (nonatomic,retain)NSMutableDictionary *existTagsDictionary;
@property (readwrite,nonatomic)int currentPageNo;
@property (nonatomic,retain)NSDictionary *backgroundImages;
@property Session *session;
-(void)setImageInfo:(NSNumber*)image_id withIndex:(NSNumber*)index withImageIds:(NSArray*)image_ids;
@end
