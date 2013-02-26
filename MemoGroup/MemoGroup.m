//
//  MemoGroup.m
//  MemoGroup
//
//  Created by 鈴木 光 on 2013/01/26.
//  Copyright (c) 2013年 鈴木 光. All rights reserved.
//

#import "MemoGroup.h"
#import "Memo.h"


@implementation MemoGroup

@dynamic groupName;
@dynamic orderingValue;
@dynamic memos;

#pragma mark NSManagedObject - Methods
- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    // 追加するときに設定を変更したい場合
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
    // オブジェクトが生成された後で設定を変更したい場合
}

@end
