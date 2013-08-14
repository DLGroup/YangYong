//
//  RecordInfo.m
//  DashBoard
//
//  Created by Yong Yang on 13-8-7.
//  Copyright (c) 2013年 DiLunTech. All rights reserved.
//

#import "RecordInfo.h"

@implementation RecordInfo

@synthesize folderName = _folderName;
@synthesize recordName = _recordName;

#pragma mark - Initial method

- (id)initWithRecordName:(NSString *)recordName andFolderName:(NSString *)folderName
{
    self = [super init];
    if (self) {
        _folderName = folderName;
        _recordName = recordName;
    }
    return self;
}

#pragma mark - NSCoding delegate

- (id)initWithCoder:(NSCoder *)aDecoder
{

    self = [super init];
    if (self) {
        _folderName = [aDecoder decodeObjectForKey:@"_folderName"];
        _recordName = [aDecoder decodeObjectForKey:@"_recordName"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_folderName forKey:@"_folderName"];
    [aCoder encodeObject:_recordName forKey:@"_recordName"];
}

@end
