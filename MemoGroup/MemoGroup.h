//
//  MemoGroup.h
//  MemoGroup
//
//  Created by 鈴木 光 on 2013/01/26.
//  Copyright (c) 2013年 鈴木 光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Memo;

@interface MemoGroup : NSManagedObject

@property (nonatomic, retain) NSString * groupName;
@property (nonatomic, retain) NSNumber * orderingValue;
@property (nonatomic, retain) NSSet *memos;
@end

@interface MemoGroup (CoreDataGeneratedAccessors)

- (void)addMemosObject:(Memo *)value;
- (void)removeMemosObject:(Memo *)value;
- (void)addMemos:(NSSet *)values;
- (void)removeMemos:(NSSet *)values;

@end
