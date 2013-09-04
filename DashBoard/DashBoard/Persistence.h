//
//  Persistence.h
//  DashBoard
//
//  Created by Yong Yang on 13-8-6.
//  Copyright (c) 2013年 DiLunTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecordInfo.h"


NSUInteger folderNumber;
NSMutableArray *folderNames;

@interface Persistence : NSObject
{
    NSMutableDictionary *folders;
    NSMutableDictionary *recorders;
    NSMutableDictionary *tags;
}

+ (Persistence *)sharedPersistence;

- (NSMutableDictionary *)getRecordsByFolderName: (NSString *)folderName;

- (RecordInfo *)getRecordByFolderName:(NSString *)folderName andRecordName: (NSString *)recordName;

- (NSMutableDictionary *)getFoldersName;

- (void)addFolder:(NSString *)folderName;

- (BOOL)removeFolder:(NSString *)folderName;

- (BOOL) changeFolderName:(NSString *)folderName toNewNmae:(NSString *)newName;

- (void)addRecord:(RecordInfo *)record toFolder:(NSString *)folderName;

- (BOOL)removeRecord:(NSString *)recordName from:(NSString *)folderName;

- (void)moveRecord:(NSString *)recordName fromOldFolder:(NSString *)oldFolderName toNewFolder:(NSString *)newFolderName;

- (void)removeTag:(NSString *)tagName;

- (void)changeTagName:(NSString *)oldName toNewName:(NSString *)newName;

- (void)addTag:(NSString *)tagName;

- (void)addRecord:(RecordInfo *)recordInfo toTag:(NSString *)tagName;

- (void)removeRecord:(RecordInfo *)recordInfo fromTag:(NSString *)tagName;

- (void)updateTag;

- (NSMutableDictionary *)tags;

@end



