//
//  MemoGroupStore.h
//  MemoGroup
//
//  Created by 鈴木 光 on 2013/01/22.
//  Copyright (c) 2013年 鈴木 光. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MemoGroup;
@class Memo;

@interface MemoGroupStore : NSObject
{
    NSMutableArray *allMemoGroups;
    
    NSMutableArray *allMemos;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

+ (MemoGroupStore *)defaultStore;
- (BOOL)saveChanges;

#pragma mark MemoGroups
- (NSArray *)allMemoGroups;
- (NSArray *)orderingMemoGroups;
- (MemoGroup *)createMemoGroup;
- (void)removeMemoGroup:(MemoGroup *)g;
- (void)moveMemoGroupAtIndex:(int)from toIndex:(int)to;

#pragma mark Memos
- (NSArray *)allMemos;
- (NSArray *)allMemosInGroup:(MemoGroup *)g;
- (NSArray *)orderingMemosInGroup:(MemoGroup *)g;
- (Memo *)createMemoWithGroup:(MemoGroup *)g;
- (void)removeMemo:(Memo *)m;
- (void)moveMemoAtIndex:(int)from toIndex:(int)to;



@end
