//
//  Memo.h
//  MemoGroup
//
//  Created by 鈴木 光 on 2013/01/26.
//  Copyright (c) 2013年 鈴木 光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Memo : NSManagedObject

@property (nonatomic, retain) NSString * memoString;
@property (nonatomic, retain) NSNumber * orderingValue;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSManagedObject *group;


#pragma mark title Util - Methods
+ (NSString *)generateTitle:(NSString *)memo;


@end
