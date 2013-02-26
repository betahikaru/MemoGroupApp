//
//  Memo.m
//  MemoGroup
//
//  Created by 鈴木 光 on 2013/01/26.
//  Copyright (c) 2013年 鈴木 光. All rights reserved.
//

#import "Memo.h"


@implementation Memo

@dynamic memoString;
@dynamic orderingValue;
@dynamic title;
@dynamic updateDate;
@dynamic group;


#pragma mark title Util - Methods
+ (NSString *)generateTitle:(NSString *)memo
{
    NSArray *memoLines = nil;
    
    // memoが空でない場合は、改行で分割し、最初の中身がある行をタイトルとして返す
    // スペース・改行しか無い場合はnilを返す
    if (memo && memo.length > 0) {
        memoLines = [memo componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        if (memoLines && memoLines.count > 0) {
            NSString *title = nil;
            for (NSString *line in memoLines) {
                NSString *trimLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (trimLine.length == 0) {
                    continue;
                } else {
                    title = trimLine;
                    break;
                }
                
            }
            return title;
        }
    }
    
    // nilを返す
    return nil;
}

#pragma mark NSManagedObject - Methods
- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    // 追加するときに設定を変更したい場合
    // 時刻
    [self setUpdateDate:[NSDate date]];
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
    // オブジェクトが生成された後で設定を変更したい場合
}

@end
