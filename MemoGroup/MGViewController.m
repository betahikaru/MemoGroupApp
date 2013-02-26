//
//  MGViewController.m
//  MemoGroup
//
//  Created by 鈴木 光 on 2013/01/22.
//  Copyright (c) 2013年 鈴木 光. All rights reserved.
//

#import "MGViewController.h"
#import "MGAppDelegate.h"
#import "MemoGroupStore.h"
#import "MemoGroup.h"
#import "MenuGroupViewController.h"

@interface MGViewController ()

@end

@implementation MGViewController

- (id)init
{
    self = [super init];
    if (self) {
        // ナビゲーションバーのタイトル設定
        self.navigationItem.title = NSLocalizedString(@"Group Memo", @"Name of application");
        
        // ナビゲーションバー右に＋ボタンを追加
        UIBarButtonItem *addButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                      target:self
                                                      action:@selector(addMenuGroup)];
        self.navigationItem.rightBarButtonItem = addButton;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView reloadData];
    
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
- (void)addMenuGroup
{
    // 新しいメモグループの位置を特定
    NSInteger count = [[self getGroups] count];
    NSIndexPath *newIndex = [NSIndexPath indexPathForRow:count inSection:0];
    
    // メモグループを追加し、ストアを更新する
    NSString *nameNewGroup = NSLocalizedString(@"New Group", @"Group name when tapped add button.");
    [self createNewMemoGroupWithName:nameNewGroup];
    
    
    // メモグループの画面を作成し、プッシュする
    MGAppDelegate *delegate = (MGAppDelegate *)[[UIApplication sharedApplication] delegate];
    MenuGroupViewController *mgvController =
    [[MenuGroupViewController alloc] initWithIndexOfGroup:newIndex];
    [delegate.navController pushViewController:mgvController animated:YES];
    
}

#pragma mark Store Controll - Methods
// グループ一覧を取得
- (NSArray *)getGroups
{
    NSArray *groups = [[MemoGroupStore defaultStore] allMemoGroups];
    return groups;
}
- (NSArray *)getOrderingGroups
{
    NSArray *groups = [[MemoGroupStore defaultStore] orderingMemoGroups];
    return groups;
}
// 指定行のグループを取得
- (MemoGroup *)groupAtIndex:(NSIndexPath *)index
{
    MemoGroup *g = [[self getOrderingGroups] objectAtIndex:index.row];
    return g;
}
// 指定行のグループのメモ一覧を取得
- (NSArray *)memosInGroup:(MemoGroup *)g
{
    NSArray *memosInGroup = [g valueForKey:@"memos"];
    return memosInGroup;
}

// 新規にグループを追加：ストアを更新、保存
- (MemoGroup *)createNewMemoGroupWithName:(NSString *)name
{
    MemoGroup *g = [[MemoGroupStore defaultStore] createMemoGroup];
    [g setGroupName:name];
    return g;
}

// 指定行のグループを削除：ストアを更新、保存
- (void)deleteGroupAtIndex:(NSIndexPath *)index
{
    [[MemoGroupStore defaultStore] removeMemoGroup:[self groupAtIndex:index]];
    [[MemoGroupStore defaultStore] saveChanges];
}

#pragma mark UITableViewDataSource - Methods
// 行数
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [[self getGroups] count];
    return count;
}

// 指定のセル
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:@"UITableViewCell"];
    }
    
    MemoGroup *group = [self groupAtIndex:indexPath];
    NSInteger count = [[self memosInGroup:group] count];
    cell.textLabel.text = group.groupName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"(%d)", count, nil];
    
    UIFont *textFont = [UIFont fontWithName:@"HiraMaruProN-W6" size:16];
    cell.textLabel.font = textFont;
    
    return cell;
}

//
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // メモグループを削除してストアを更新する
        [self deleteGroupAtIndex:indexPath];
        
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = [[self getGroups] count];
    
    if (indexPath.row < count && !self.isEditing) {
        MenuGroupViewController *mgvController =
        [[MenuGroupViewController alloc] initWithIndexOfGroup:indexPath];
        MGAppDelegate *delegate = (MGAppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.navController pushViewController:mgvController animated:YES];
    }
}



@end
