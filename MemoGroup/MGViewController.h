//
//  MGViewController.h
//  MemoGroup
//
//  Created by 鈴木 光 on 2013/01/22.
//  Copyright (c) 2013年 鈴木 光. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak) IBOutlet UITableView *tableView;

/**
 ローカライズコマンド
 genstrings *.m
 */
@end
