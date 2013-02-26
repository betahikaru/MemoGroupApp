//
//  MenuGroupViewController.m
//  MemoGroup
//
//  Created by 鈴木 光 on 2013/01/22.
//  Copyright (c) 2013年 鈴木 光. All rights reserved.
//

#import "MenuGroupViewController.h"
#import "MGAppDelegate.h"
#import "MemoViewController.h"

#import "MemoGroupStore.h"
#import "MemoGroup.h"
#import "Memo.h"

@interface MenuGroupViewController ()

@end

@implementation MenuGroupViewController

@synthesize tableView;
@synthesize groupNameField;

#pragma mark Initialize - Methods
- (id)initWithIndexOfGroup:(NSIndexPath *)index
{
    self = [super initWithNibName:@"MenuGroupViewController"
                           bundle:nil];
    if (self) {
        groupIndexPath = index;
        
        // ナビゲーションバー右に＋ボタンを追加
        UIBarButtonItem *addButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                      target:self
                                                      action:@selector(addMenu)];
        self.navigationItem.rightBarButtonItem = addButton;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 選択したグループのグループ名を設定する
    NSString *groupName = [[self group] groupName];
    self.groupNameField.text = groupName;
    self.title = groupName;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // テーブルの選択状態を解除
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    
    // ビューが表示されるたびにテーブルの内容を更新
    [self.tableView reloadData];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark UIButton - Methods
// +ボタンをタップした時の処理
- (void)addMenu
{
    NSArray *orderingMemos = [[MemoGroupStore defaultStore] orderingMemosInGroup:[self group]];
    NSInteger count = [orderingMemos count];
    NSIndexPath *newIndex = [NSIndexPath indexPathForRow:count inSection:1];

    // 画面遷移する時点では、メモをストアに追加しない
    
    // メモ編集用の画面を作成してプッシュする
    MemoViewController *mvController =
    [[MemoViewController alloc] initWithGroupIndex:groupIndexPath
                                         memoIndex:newIndex
                                         isNewMemo:YES];
    MGAppDelegate *delegate = (MGAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.navController pushViewController:mvController animated:YES];

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
// 指定行のメモを取得
- (Memo *)memoAtIndex:(NSIndexPath *)index
{
    Memo *m = [[self getMemosInGroup] objectAtIndex:index.row];
    return m;
}

// グループ名を更新：ストアとタイトルを更新し、保存
- (void)updateGroupName:(NSString *)name
{
    self.title = name;
    [[self group] setGroupName:name];
    [[MemoGroupStore defaultStore] saveChanges];
}
// 指定行のメモを削除：ストアを更新、保存
- (void)deleteMemoAtIndex:(NSIndexPath *)index
{
    [[MemoGroupStore defaultStore] removeMemo:[self memoAtIndex:index]];
    [[MemoGroupStore defaultStore] saveChanges];
}


#pragma mark UITextFieldDelegate - Methods
// グループ名が確定された
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // グループ名を更新して保存
    [self updateGroupName:textField.text];
    
    // ファーストレスポンダから解除する
    [textField resignFirstResponder];
    
    return YES;
}


#pragma mark UITableViewDataSource - Methods
// セクション数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

// 指定のセクション
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"";
    } else {
        return NSLocalizedString(@"List of memo", @"List of memo.");
    }
}

// 行数
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (section == 0) {
        count = 1;
    } else {
        count = [[self getMemosInGroup] count];
    }
    return count;
}

// 指定のセル
- (UITableViewCell *)tableView:(UITableView *)aTableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = groupNameCell;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setEditingAccessoryType:UITableViewCellAccessoryNone];
    } else {
        cell = [aTableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:@"UITableViewCell"];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }

        // 日時のフォーマット
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];

        // メモの情報をそれぞれのラベルに設定する
        Memo *m = [self memoAtIndex:indexPath];
        cell.textLabel.text = m.title;
        cell.detailTextLabel.text = [formatter stringFromDate:m.updateDate];
    }
    return cell;
}

//
- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return;
    }
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // メモを削除してストアを更新する
        [self deleteMemoAtIndex:indexPath];
        
        // テーブルの行をアニメーション付きで削除する
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:YES];
    }
}


//
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath
{
}

#pragma mark UITableViewDelegate - Methods
// 行をタップされた
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        // 選択状態を解除する
        [aTableView deselectRowAtIndexPath:indexPath animated:NO];
        
    } else {
        // 選択したメモを表示する画面を作成、プッシュする
        MGAppDelegate *delegate = (MGAppDelegate *)[[UIApplication sharedApplication] delegate];
        MemoViewController *mvController =
        [[MemoViewController alloc] initWithGroupIndex:groupIndexPath
                                             memoIndex:indexPath
                                             isNewMemo:NO];
        [delegate.navController pushViewController:mvController animated:YES];

    }
}

@end
