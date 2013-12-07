//
//  CommentEditViewController.m
//  development-01
//
//  Created by Motoi Hirata on 2013/12/07.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import "CommentEditViewController.h"
#import "DA.h"
@interface CommentEditViewController ()

@end


@implementation CommentEditViewController
@synthesize preservedComment;
@synthesize textViewObject;
@synthesize imageId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    // 保存ボタンを作成
    UIBarButtonItem * saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveComment)];
    // cancelボタンを作成
    UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelComment)];
    self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.leftBarButtonItem  = cancelButton;

    
    CGRect rect = self.view.bounds;
    UIScrollView * commentEditScrollView = [[UIScrollView alloc]initWithFrame:rect];
    commentEditScrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];

    CGRect textRect = rect;
    textRect.size.width  = rect.size.width / 1.5;
    textRect.size.height = rect.size.width / 2;
    textRect.origin.y = (rect.size.height - textRect.size.height) / 2;
    UITextView * textView = [[UITextView alloc]initWithFrame:textRect];
    textView.text = preservedComment;
    textView.editable = YES;
    textView.textAlignment = UITextAlignmentLeft;
    [textView becomeFirstResponder];

    //ポインタを保存
    textViewObject = textView;


    [commentEditScrollView addSubview:textView];
    NSLog(@"attache commentEditScrollView %@", commentEditScrollView);
   
    [self.view addSubview:commentEditScrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setComment:(NSString*)comment {
    preservedComment = comment;
}

- (void)setImageId:(NSNumber*)image_id {
    imageId = image_id;
}

- (void)cancelComment{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)saveComment{
    //save
    NSLog(@"textView : %@", textViewObject.text);
    NSLog(@"imageId : %@", imageId);
    DA * da = [DA da];
    NSString * stmt = @"UPDATE image_common SET comment = ? WHERE id = ?";
    [da open];
    [da executeUpdate:stmt, textViewObject.text, imageId];
    [da close];
    
    //close
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
