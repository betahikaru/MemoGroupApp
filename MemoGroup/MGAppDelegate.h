//
//  MGAppDelegate.h
//  MemoGroup
//
//  Created by 鈴木 光 on 2013/01/22.
//  Copyright (c) 2013年 鈴木 光. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MGViewController;

@interface MGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MGViewController *viewController;

@property (strong, nonatomic) UINavigationController *navController;

@end
