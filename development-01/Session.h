//
//  Session.h
//  development-01
//
//  Created by kenjiszk on 2013/12/08.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Session : NSObject

@property UIView *baseView;

-(void)showLoginView:(UIView*)view;
-(void)showLogoutView:(UIView*)view;

@end
