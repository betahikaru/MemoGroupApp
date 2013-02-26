//
//  MemoViewController.h
//  MemoGroup
//
//  Created by 鈴木 光 on 2013/01/23.
//  Copyright (c) 2013年 鈴木 光. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Memo;

@interface MemoViewController : UIViewController
<UITextViewDelegate>
{
    NSIndexPath *groupIndexPath;
    NSIndexPath *memoIndexPath;
    
    // メモがストアに存在するか否かのフラグ。新規追加の場合は、保存するまでストアにメモが存在しない。
    BOOL existMemoInStore;
    
    UIBarButtonItem *saveButton;
    UIBarButtonItem *feedbackButton;
}

// iOS6のバグで、日本語変換候補がでると"<Error>:CGContextSaveGState: invalid context 0x0"などが出力される。
// 問題ないので無視する、
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;


#pragma mark Initilize - Methods
- (id)initWithGroupIndex:(NSIndexPath *)groupIndex
               memoIndex:(NSIndexPath *)memoIndex
               isNewMemo:(BOOL)isNew;


#pragma mark Notification - Methods

#pragma mark Outlet - Methods

- (IBAction)tapDeleteButton:(id)sender;

@end
