//
//  MemoGroupStore.m
//  MemoGroup
//
//  Created by 鈴木 光 on 2013/01/22.
//  Copyright (c) 2013年 鈴木 光. All rights reserved.
//

#import "MemoGroupStore.h"
#import "MemoGroup.h"
#import "Memo.h"

static MemoGroupStore *defaultStore = nil;

@implementation MemoGroupStore

- (id)init
{
    if (defaultStore) {
        return defaultStore;
    }
    self = [super init];
    
    // MemoGroup.xcdatamodeld 読み込み
    model = [NSManagedObjectModel mergedModelFromBundles:nil];
    //    NSLog(@"model = %@", model);
    
    NSPersistentStoreCoordinator *psc =
    [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    // SQLiteファイルの場所
    NSString *path = pathInDocumentDirectory(@"store.data");
    NSURL *storeURL = [NSURL fileURLWithPath:path];
    
    NSError *error = nil;
    if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                           configuration:nil
                                     URL:storeURL
                                 options:nil
                                   error:&error]) {
        [NSException raise:@"Open failed"
                    format:@"Reason: %@", [error localizedDescription]];
    }
    
    // 管理オブジェクトコンテキストを生成する
    context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:psc];
    
    // 管理オブジェクトコンテキストはアンドゥをすることもできるが、必要ない
    [context setUndoManager:nil];
    
    return self;
}

+ (MemoGroupStore *)defaultStore
{
    if (!defaultStore) {
        defaultStore = [[super allocWithZone:NULL] init];
    }
    return defaultStore;
}
+ (id)allocWithZone:(NSZone *)zone
{
    return [self defaultStore];
}

#pragma mark CoreData Utility - Methods
// データをレポジトリに保存する
- (BOOL)saveChanges
{
    NSError *error = nil;
    BOOL successful = [context save:&error];
    if (!successful) {
        NSLog(@"Error saving: %@", [error localizedDescription]);
    }
    
    return successful;
}
- (void)fetchMemoGroupsIfNecessary
{
    
    if (!allMemos) {
        allMemos = [self fetchArrayByEntityName:@"Memo" sortKey:@"orderingValue"];
    }
    
    if (!allMemoGroups) {
        allMemoGroups = [self fetchArrayByEntityName:@"MemoGroup" sortKey:@"orderingValue"];
    }
    
}
- (NSMutableArray *)fetchArrayByEntityName:(NSString *)entityName
                                   sortKey:(NSString *)key
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *e =
    [[model entitiesByName] objectForKey:entityName];
    [request setEntity:e];
    
    NSSortDescriptor *sd =
    [NSSortDescriptor sortDescriptorWithKey:key
                                  ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sd]];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (!result) {
        [NSException raise:@"Fetch failed"
                    format:@"Reson: %@", [error localizedDescription]];
    }
    
    return [[NSMutableArray alloc] initWithArray:result];
}

#pragma mark MemoGroups
- (NSArray *)allMemoGroups
{
    // allMemoGroupsが必ず生成されるようにする
    [self fetchMemoGroupsIfNecessary];
    
    return allMemoGroups;
}
- (NSArray *)orderingMemoGroups
{
    NSSortDescriptor *sdOV = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue"
                                                           ascending:YES];
    NSArray *groups = [allMemoGroups sortedArrayUsingDescriptors:[NSArray arrayWithObject:sdOV]];
    return groups;
}

- (MemoGroup *)createMemoGroup
{
    // 配列を初期化
    [self fetchMemoGroupsIfNecessary];
    
    // orderの設定
    double order;
    if ([allMemoGroups count] == 0) {
        order = 1.0;
    } else {
        order = [[[allMemoGroups lastObject] orderingValue] doubleValue] + 1.0;
    }
    NSLog(@"Adding group after %d items, order = %.2f", [allMemoGroups count], order);
    
    // MemoGroupの追加
    MemoGroup *g = [NSEntityDescription insertNewObjectForEntityForName:@"MemoGroup"
                                                 inManagedObjectContext:context];
    [g setOrderingValue:[NSNumber numberWithDouble:order]];
    [allMemoGroups addObject:g];
    return g;
    
}
- (void)removeMemoGroup:(MemoGroup *)g
{
    // 関連した別のストアのデータがあれば、ここで削除する
    NSArray *memosInGroup = [self orderingMemosInGroup:g];
    for (Memo *m in memosInGroup) {
        [self removeMemo:m];
    }
    // context からメモグループを削除する
    [context deleteObject:g];
    
    // 配列からメモグループを削除する
    [allMemoGroups removeObjectIdenticalTo:g];
}
- (void)moveMemoGroupAtIndex:(int)from toIndex:(int)to
{
    if (from == to) {
        return;
    }
    
    // 配列の新しい場所に挿入し直す
    MemoGroup *g = [[allMemoGroups objectAtIndex:from] copy];
    [allMemoGroups removeObjectAtIndex:from];
    [allMemoGroups insertObject:g atIndex:to];
    
    // orderValueを計算する
    // 他のオブジェクトが配列順の前にある？
    double lowerBound = 0.0;
    if (to > 0) {
        lowerBound = [[[allMemoGroups objectAtIndex:to - 1] orderingValue] doubleValue];
    } else {
        // 移動先が先頭
        lowerBound = [[[allMemoGroups objectAtIndex:1] orderingValue] doubleValue] - 2.0;
    }
    // 他のオブジェクトが配列順の後ろにある？
    double uperBound = 0.0;
    if (to < [allMemoGroups count] - 1) {
        uperBound = [[[allMemoGroups objectAtIndex:to + 1] orderingValue] doubleValue];
    } else {
        // 移動先が末尾
        uperBound = [[[allMemoGroups objectAtIndex:to - 1] orderingValue] doubleValue] + 2.0;
    }
    // 順序の値は上限と加減の中間点とする
    NSNumber *n = [NSNumber numberWithDouble:(lowerBound + uperBound)/2.0];
    NSLog(@"movint to order %@", n);
    [g setOrderingValue:n];
    
}

#pragma mark Memos
- (NSArray *)allMemos
{
    // allMemosが必ず生成されるようにする
    [self fetchMemoGroupsIfNecessary];
    
    return allMemos;
}
- (NSArray *)allMemosInGroup:(MemoGroup *)g
{
    NSSet *memoSet = [g valueForKey:@"memos"];
    NSArray *memos = [memoSet allObjects];
    return memos;
}
- (NSArray *)orderingMemosInGroup:(MemoGroup *)g
{
    NSSet *memoSet = [g valueForKey:@"memos"];
    NSSortDescriptor *sdOV = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue"
                                                           ascending:YES];
    NSArray *memos = [memoSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:sdOV]];
    return memos;
}

- (Memo *)createMemoWithGroup:(MemoGroup *)g
{
    // 配列を初期化
    [self fetchMemoGroupsIfNecessary];
    
    // orderの設定
    double order;
    if ([allMemos count] == 0) {
        order = 1.0;
    } else {
        order = [[[allMemos lastObject] orderingValue] doubleValue] + 1.0;
    }
    NSLog(@"Adding memo after %d items, order = %.2f", [allMemos count], order);
    
    // memoの追加
    Memo *m = [NSEntityDescription insertNewObjectForEntityForName:@"Memo"
                                            inManagedObjectContext:context];
    [m setOrderingValue:[NSNumber numberWithDouble:order]];
    [m setGroup:g];
    [allMemos addObject:m];
    
    return m;
}
- (void)removeMemo:(Memo *)m
{
    // 関連した別のストアのデータがあれば、ここで削除する
    
    // context からメモを削除する
    [context deleteObject:m];
    
    // 配列からメモを削除する
    [allMemos removeObjectIdenticalTo:m];
    
}
- (void)moveMemoAtIndex:(int)from toIndex:(int)to
{
    if (from == to) {
        return;
    }
    
    // 配列の新しい場所に挿入し直す
    Memo *m = [[allMemos objectAtIndex:from] copy];
    [allMemos removeObjectAtIndex:from];
    [allMemos insertObject:m atIndex:to];
    
    // orderValueを計算する
    // 他のオブジェクトが配列順の前にある？
    double lowerBound = 0.0;
    if (to > 0) {
        lowerBound = [[[allMemos objectAtIndex:to - 1] orderingValue] doubleValue];
    } else {
        // 移動先が先頭
        lowerBound = [[[allMemos objectAtIndex:1] orderingValue] doubleValue] - 2.0;
    }
    // 他のオブジェクトが配列順の後ろにある？
    double uperBound = 0.0;
    if (to < [allMemos count] - 1) {
        uperBound = [[[allMemos objectAtIndex:to + 1] orderingValue] doubleValue];
    } else {
        // 移動先が末尾
        uperBound = [[[allMemos objectAtIndex:to - 1] orderingValue] doubleValue] + 2.0;
    }
    // 順序の値は上限と加減の中間点とする
    NSNumber *n = [NSNumber numberWithDouble:(lowerBound + uperBound)/2.0];
    NSLog(@"movint to order %@", n);
    [m setOrderingValue:n];
    
}


@end
