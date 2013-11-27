//
//  FirstViewController.m
//  development-01
//
//  Created by Motoi Hirata on 2013/11/18.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import "FirstViewController.h"
#import "Common.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    Common *cm = [[Common alloc] init];
    [cm databaseInitializer];
    [cm filesystemInitializer];
//    [cm kickImageSync];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)testKickButtonTap:(id)sender {

    Common *cm = [[Common alloc] init];
    [cm kickImageSync];
}
@end
