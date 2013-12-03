//
//  FirstViewController.h
//  development-01
//
//  Created by Motoi Hirata on 2013/11/18.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageSync.h"

@interface FirstViewController : UIViewController{
}
@property (strong, nonatomic) IBOutlet UIButton *testKickButton;
@property (strong, nonatomic) UIProgressView *progressView;
- (IBAction)testKickButtonTap:(id)sender;
@end
