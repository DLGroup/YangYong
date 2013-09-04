//
//  RecordInfo.h
//  DashBoard
//
//  Created by Yong Yang on 13-8-7.
//  Copyright (c) 2013年 DiLunTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface RecordInfo : NSObject <NSCoding>

@property (strong, nonatomic) NSString *folderName;
@property (strong, nonatomic) NSString *recordName;
@property (strong, nonatomic) NSMutableArray *tagNames;

- (id)initWithRecordName:(NSString *)recordName andFolderName: (NSString *)folderName;

- (void)addTag:(NSString *)tagName;

- (void)removeTag:(NSString *)tagName;

- (void)changeTagName:(NSString *)oldName toNewName:(NSString *)newName;

@end







