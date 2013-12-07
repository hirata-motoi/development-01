//
//  CommentEditViewController.h
//  development-01
//
//  Created by Motoi Hirata on 2013/12/07.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentEditViewController : UIViewController

@property (nonatomic,retain)NSString * preservedComment;
@property (nonatomic,retain)UITextView *textViewObject;
@property (nonatomic,retain)NSNumber *imageId;
-(void)setComment:(NSString*)comment;
-(void)setImageId:(NSNumber*)image_id;

@end
