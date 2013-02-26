//
//  MemoViewController.m
//  MemoGroup
//
//  Created by 鈴木 光 on 2013/01/23.
//  Copyright (c) 2013年 鈴木 光. All rights reserved.
//

// TODO:
// 1. ここ[http://iphone-app-developer.seesaa.net/article/313155011.html]の方法で、
//    frame.sizeではなくInsetの調整によってキーボードの表示・非表示に対応する。
// 2. スクロールと同時に動く背景画像を表示する。やり方は不明。

#import "MemoViewController.h"

#import "MGAppDelegate.h"
#import "MemoGroupStore.h"
#import "MemoGroup.h"
#import "Memo.h"

@interface MemoViewController ()
{
    CGFloat keyboardHeight;
}
@end

@implementation MemoViewController

@synthesize textView;
@synthesize scrollView;

#pragma mark Initilize - Methods
- (id)initWithGroupIndex:(NSIndexPath *)groupIndex
               memoIndex:(NSIndexPath *)memoIndex
               isNewMemo:(BOOL)isNew
{
    self = [super init];
    if (self) {
        groupIndexPath = groupIndex;
        memoIndexPath = memoIndex;
        saveButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                      target:self
                                                      action:@selector(saveChange)];
        feedbackButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                                      target:self
                                                      action:@selector(feedback)];
        
        NSLog(@"memo vc init.");
        
        // スクロールビューの（内部）サイズはテキストビューのサイズと同じ
        scrollView.contentSize = textView.frame.size;
        
        // 新しいメモの場合は、ストア保存済みフラグをNOにする
        if (isNew) {
            existMemoInStore = NO;
        } else {
            existMemoInStore = YES;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //キーボード表示・非表示の通知の開始
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    // ストアに存在するメモを表示する場合
    if (existMemoInStore) {
        // ビューがロードされたら、メモ文字列を設定する
        textView.text = [[self memo] memoString];
        
        // タイトルを設定する
        self.title = [[self memo] title];
        
        // フィードバックボタンを追加する
        self.navigationItem.rightBarButtonItem = feedbackButton;
    }
    // ストアに存在しないメモを表示する場合
    else {
        // タイトルを設定する
        NSString *titleString = NSLocalizedString(@"New Memo", @"Memo title at New Mode");
        self.title = titleString;
        
        // 追加ボタンタップ後は、即編集開始させる
        [textView becomeFirstResponder];
        
        // 保存ボタンを追加する
        self.navigationItem.rightBarButtonItem = saveButton;
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    //キーボード表示・非表示の通知を終了
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Notification - Methods
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    // キーボードのサイズ取得
    CGRect keyboardFrame =
    [[aNotification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 2013.02.09
    // スクロールビューの新しいサイズを指定する
    CGRect newFrame = self.view.frame;
    newFrame.size.height = newFrame.size.height - keyboardFrame.size.height;
    NSLog(@"scrollview frame small, newFrame.size.height = %f.", newFrame.size.height);
    
    [UIView beginAnimations:nil context:nil];
    [scrollView setFrame:newFrame];
    [UIView commitAnimations];
}
- (void)keyboardDidHide:(NSNotification*)aNotification
{
    // 2013.02.09
    // スクロールビューのサイズを、親ビューと同じ大きさにする
    CGRect newFrame = self.view.frame;
    [scrollView setFrame:newFrame];
}
- (void)scrollViewContentOffsetChange
{
    
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    CGFloat screenHeight = screenRect.size.height;
    
    int n = 60; // 補正用
    // 現在のカーソル位置の取得
    UITextRange *currentRange = textView.selectedTextRange;
    // カーソル位置をポイント変換
    UITextPosition *currentPosition = [textView positionFromPosition:currentRange.start offset:0];
    // カーソルポイントを座標変換
    CGRect caretRect = [textView caretRectForPosition:currentPosition];
    // TextViewが表示できるラインの高さ
    int textDisplayLine = screenHeight - keyboardHeight + n;
    // View全体からみた現在のカーソル位置
    int nowCursorPosition = caretRect.origin.y + caretRect.size.height + textView.frame.origin.y;
    
    // カーソル位置が表示ラインより大きいかどうか
    if (textDisplayLine <= nowCursorPosition) {
        // 画面スクロールの表示位置を変更する(表示ラインからはみ出した高さを位置として記録)
        CGPoint scrollPoint = CGPointMake(0.0,nowCursorPosition - textDisplayLine);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

#pragma mark UIButton - Methods
// 保存ボタンが押されたとき
- (void)saveChange
{
    // テキストビューをファーストレスポンダから外す
    [textView resignFirstResponder];
    
    // メモの内容からタイトルを作成する
    NSString *gTitle = [Memo generateTitle:textView.text];
    
    // タイトルの状態で分岐する
    if (gTitle == nil || gTitle.length == 0) {
        // メモを削除してストアを更新する（ストアに無いなら何もしない）
        [self deleteMemo];
        
        // 前の画面に戻る
        MGAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate.navController popViewControllerAnimated:YES];
        
    } else {
        // 入力された内容でストアを更新する（ストアに無いなら作成、ストア保存フラグも更新）
        [self updateMemoString:textView.text title:gTitle];
        
        // タイトルを設定する
        self.title = gTitle;
        
        // 保存ボタンを隠す
        // フィードバックボタンを追加する
        self.navigationItem.rightBarButtonItem = feedbackButton;
    }
    
}

// フィードバックのボタンを押したとき
- (void)feedback
{
    [TestFlight openFeedbackView];
}

#pragma mark Store Controll - Methods
// 本画面が属するグループを取得
- (MemoGroup *)group
{
    MemoGroup *g =
    [[[MemoGroupStore defaultStore] allMemoGroups] objectAtIndex:[groupIndexPath row]];
    return g;
}
// グループ内のメモ一覧を取得
- (NSArray *)getMemosInGroup
{
    MemoGroup *g = [self group];
    NSArray *memosInGroup = [[MemoGroupStore defaultStore] orderingMemosInGroup:g];
    return memosInGroup;
}
// 本画面が属するメモを取得
- (Memo *)memo
{
    Memo *m = nil;
    if (existMemoInStore) {
        m = [[self getMemosInGroup] objectAtIndex:memoIndexPath.row];
    }
    return m;
}
// メモの内容を更新：ストアを更新、保存
- (void)updateMemoString:(NSString *)s title:(NSString *)t;
{
    Memo *m;
    if (existMemoInStore) {
        m = [self memo];
    } else {
        m = [[MemoGroupStore defaultStore] createMemoWithGroup:[self group]];
        existMemoInStore = YES;
    }
    if (m) {
        [m setMemoString:s];
        [m setTitle:t];
        [[MemoGroupStore defaultStore] saveChanges];
    }
}

// 本画面が属するメモを削除：ストアを更新、保存
- (void)deleteMemo
{
    if (existMemoInStore) {
        [[MemoGroupStore defaultStore] removeMemo:[self memo]];
        [[MemoGroupStore defaultStore] saveChanges];
    }
}


#pragma mark UITextViewDelegate - Methods
// テキストが編集中になったら、完了ボタンを追加する
- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView
{
    // 完了ボタン表示
    [self.navigationItem setRightBarButtonItem:saveButton];
    
    return YES;
}
// テキストの内容が変更されたら、＊＊＊
- (void)textViewDidChange:(UITextView *)aTextView{
    /*
     CGRect textViewSize = aTextView.frame;
     double textViewDifference = (aTextView.contentSize.height - textViewSize.size.height); // サイズ差分
     
     // テキストのFrameSizeを変更する
     textViewSize.size.height = aTextView.contentSize.height;
     aTextView.frame = textViewSize;
     
     // 画面スクロールのContextSizeを変更する
     scrollView.contentSize = CGSizeMake(0, scrollView.contentSize.height + textViewDifference);
     
     // 画面スクロール表示位置変更
     [self scrollViewContentOffsetChange];
     */
}

//- (void)textViewDidChangeSelection:(UITextView *)aTextView{
//}


#pragma mark Outlet - Methods
- (IBAction)tapDeleteButton:(id)sender {
    // メモを削除してストアを更新する（ストアに無いなら何もしない）
    [self deleteMemo];
    
    // 前の画面に戻る
    MGAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navController popViewControllerAnimated:YES];
}


@end
