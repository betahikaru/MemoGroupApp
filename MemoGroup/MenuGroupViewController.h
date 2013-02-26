//
//  MenuGroupViewController.h
//  MemoGroup
//
//  Created by 鈴木 光 on 2013/01/22.
//  Copyright (c) 2013年 鈴木 光. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MemoGroup;

@interface MenuGroupViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate,
 UITextFieldDelegate>
{
    NSIndexPath *groupIndexPath;
    
    IBOutlet UITableViewCell *groupNameCell;
}

@property(nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UITextField *groupNameField;

#pragma mark Initialize - Methods
- (id)initWithIndexOfGroup:(NSIndexPath *)index;

#pragma mark Outlet - Methods

@end
