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
@synthesize tagNames = _tagNames;

#pragma mark - Initial method

- (id)initWithRecordName:(NSString *)recordName andFolderName:(NSString *)folderName
{
    self = [super init];
    if (self) {
        _folderName = folderName;
        _recordName = recordName;
        _tagNames = [[NSMutableArray alloc] init];
        
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
        _tagNames = [aDecoder decodeObjectForKey:@"_tagNames"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_folderName forKey:@"_folderName"];
    [aCoder encodeObject:_recordName forKey:@"_recordName"];
    [aCoder encodeObject:_tagNames forKey:@"_tagNames"];
}

- (void)removeTag:(NSString *)tagName
{
    [_tagNames removeObject:tagName];
}

- (void)changeTagName:(NSString *)oldName toNewName:(NSString *)newName
{
    [_tagNames removeObject:oldName];
    [_tagNames addObject:newName];
}

- (void)addTag:(NSString *)tagName
{
    [_tagNames addObject:tagName];
}


@end
