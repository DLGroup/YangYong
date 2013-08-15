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
    //...maybe tags later
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

@end



