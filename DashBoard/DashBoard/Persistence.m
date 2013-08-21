//
//  Persistence.m
//  DashBoard
//
//  Created by Yong Yang on 13-8-6.
//  Copyright (c) 2013年 DiLunTech. All rights reserved.
//


//maybe will have problem method
//- (void)addRecord:(RecordInfo *)record toFolder:(NSString *)folderName

#import "Persistence.h"
#import "RecordInfo.h"

#define FOLDERSNAME @"folders.plist"
#define TAGS @"tags.plist"

@implementation Persistence

#pragma mark - Singleton method

- (id)init
{
    NSAssert(NO, @"Cannot create instance of a singleton class this way!");
    return nil;
}

- (id)initPersistence
{
    if (self = [super init]) {
        //create a plist file
        NSString *filePath = [[self dataFilePath] stringByAppendingPathComponent:FOLDERSNAME];
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        if (![defaultManager fileExistsAtPath:filePath]) {
            [defaultManager createFileAtPath:filePath contents:nil attributes:nil];
            folders = [[NSMutableDictionary alloc] init];
            recorders = [[NSMutableDictionary alloc] init];
            //...
            folderNames = [[NSMutableArray alloc] init];
            folderNumber = 0;
        }
        else
        {
            folders = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        }
        //tags
        NSString *tagPath = [[self dataFilePath] stringByAppendingPathComponent:TAGS];
        if (![defaultManager fileExistsAtPath:tagPath]) {
            [defaultManager createFileAtPath:tagPath contents:nil attributes:nil];
            tags = [[NSMutableDictionary alloc] init];
        }
        else
            tags = [[NSMutableDictionary alloc] initWithContentsOfFile:tagPath];
    }
    return self;
}

+ (Persistence *)sharedPersistence
{
    static Persistence *persistence = nil;
    //the singleton mode need to know why
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        persistence = [[self alloc] initPersistence];
    });
    return persistence;
}

#pragma mark - Folder operate

- (NSMutableDictionary *)getFoldersName
{
    return folders;
}

- (void)addFolder:(NSString *)folderName
{
    [folders setObject:[[NSMutableDictionary alloc] init] forKey:folderName];
    [self updateFile];
       
}

- (BOOL)removeFolder:(NSString *)folderName
{
    NSFileManager *defaultManager;
    defaultManager = [NSFileManager defaultManager];
    recorders = [folders objectForKey:folderName];
    for (NSString *recordName in [recorders allKeys]) {
        NSString *filePath = [[self dataFilePath] stringByAppendingPathComponent:recordName];
        if ([defaultManager fileExistsAtPath:filePath])
        {
            [defaultManager removeItemAtPath:filePath error:nil];
        }        
        else
        {
            NSLog(@"the record infomation is not existed!");
            return NO;//delete not successfully！
        }
    }
    //remove the folder used by folderName
    [folders removeObjectForKey:folderName];
    [self updateFile];
    return YES;
}

- (BOOL) changeFolderName:(NSString *)folderName toNewNmae:(NSString *)newName
{
    [folders setObject:[[NSMutableDictionary alloc] init] forKey:newName];
    for (NSString *recordName in [[self getRecordsByFolderName:folderName] allKeys]) {
        [self addRecord:[self getRecordByFolderName:folderName andRecordName:recordName] toFolder:newName];
    }
    [folders removeObjectForKey:folderName];
    return YES;
}

#pragma mark - Record operate

- (void)addRecord:(RecordInfo *)record toFolder:(NSString *)folderName
{
    recorders = [folders objectForKey:folderName];
    // ---------------------------------------
    // archiver the data realized the NSCoding delegate
    NSMutableData *recordData = [[NSMutableData alloc] init];
    NSKeyedArchiver *ar = [[NSKeyedArchiver alloc] initForWritingWithMutableData:recordData];
    [ar encodeObject:record forKey:@"kRecord"];
    [ar finishEncoding];
    // ----------------------------------------
    [recordData writeToFile:[[self dataFilePath] stringByAppendingPathComponent:[record recordName]] atomically:YES];
    [recorders setObject:recordData forKey:[record recordName]];
    [self updateFile];
}

- (BOOL)removeRecord:(NSString *)recordName from:(NSString *)folderName
{
    NSFileManager *defaultManager;
    defaultManager = [NSFileManager defaultManager];
    //remove the file in the user's document 
    NSString *filePath = [[self dataFilePath] stringByAppendingPathComponent:recordName];
    if ([defaultManager fileExistsAtPath:filePath])
    {
        [defaultManager removeItemAtPath:filePath error:nil];
        filePath = nil;
    }
    else
    {
        NSLog(@"the record infomation is not existed!");
        return NO;//删除不成功！
    }
    //delete the record used by recordName
    [[folders objectForKey:folderName] removeObjectForKey:recordName];
    [self updateFile];
    return YES;
}

- (void)moveRecord:(NSString *)recordName fromOldFolder:(NSString *)oldFolderName toNewFolder:(NSString *)newFolderName;
{
     RecordInfo *record = [self getRecordByFolderName:oldFolderName andRecordName:recordName];
    [self addRecord:record toFolder:newFolderName];
    recorders = [folders objectForKey:oldFolderName];
    [recorders removeObjectForKey:recordName];
}

- (RecordInfo *)getRecordByFolderName:(NSString *)folderName andRecordName: (NSString *)recordName
{
    // --------------------------------------
    // unarchiver the data to recordInfo
    NSMutableData *record = [[NSMutableData alloc] initWithContentsOfFile:[[self dataFilePath] stringByAppendingPathComponent:recordName]];
    RecordInfo *recordInfo=[[RecordInfo alloc] init];
    NSKeyedUnarchiver *uar = [[NSKeyedUnarchiver alloc] initForReadingWithData:record];
    recordInfo = [uar decodeObjectForKey:@"kRecord"];
    [uar finishDecoding];
    // --------------------------------------
    return recordInfo;
}

- (NSMutableDictionary *)getRecordsByFolderName: (NSString *)folderName
{
    return [folders objectForKey:folderName];
}

#pragma mark - Inner method

- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

- (void)updateFile
{
    //update the plist file
    if(![folders writeToFile:[[self dataFilePath] stringByAppendingPathComponent:FOLDERSNAME] atomically:YES])
         NSLog(@"some problem happened while write data to folders.plist");
}

- (void)updateTag
{
    if (![tags writeToFile:[[self dataFilePath] stringByAppendingPathComponent:TAGS] atomically:YES]) {
        NSLog(@"some problem happended while write data to tags.plist");
    }
}

- (void)removeTag:(NSString *)tagName
{
    //remove the tag used by tag name
    [tags removeObjectForKey:tagName];
    //remove the tag information from the RecordInfo
    //...
    NSMutableArray *recordNames = [tags objectForKey:tagName];
    for (NSUInteger index=0; index<[recordNames count]; index++) {
        //the tags' object storage RecordInfo
        NSMutableData *recordData = [recordNames objectAtIndex:index];
//maybe some problem here
        RecordInfo *recordInfo=[[RecordInfo alloc] init];
        NSKeyedUnarchiver *uar = [[NSKeyedUnarchiver alloc] initForReadingWithData:recordData];
        recordInfo = [uar decodeObjectForKey:@"kRecord"];
        [uar finishDecoding];
        NSLog(@"folder name:%@, and record name:%@", [recordInfo folderName], [recordInfo recordName]);
        [recordInfo removeTag:tagName];
//        [self removeRecord:[theRecord recordName] from:[theRecord folderName]];
        [self addRecord:recordInfo toFolder:[recordInfo folderName]];
    }
    //---
    [self updateTag];
}

- (void)changeTagName:(NSString *)oldName toNewName:(NSString *)newName
{
    [tags setObject:[[NSMutableArray alloc] init] forKey:newName];
    for (NSUInteger index=0; index<[[tags objectForKey:oldName] count]; index++) {
        NSMutableData *recordData = [[tags objectForKey:oldName] objectAtIndex:index];
        RecordInfo *recordInfo=[[RecordInfo alloc] init];
        NSKeyedUnarchiver *uar = [[NSKeyedUnarchiver alloc] initForReadingWithData:recordData];
        recordInfo = [uar decodeObjectForKey:@"kRecord"];
        NSLog(@"folder name:%@, and record name:%@", [recordInfo folderName], [recordInfo recordName]);

        [uar finishDecoding];
        [recordInfo changeTagName:oldName toNewName:newName];
        [self addRecord:recordInfo toFolder:[recordInfo folderName]];
        //write to file afresh
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *ar = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [ar encodeObject:recordInfo forKey:@"kRecord"];
        [ar finishEncoding];
        // ----------------------------------------
        [data writeToFile:[[self dataFilePath] stringByAppendingPathComponent:[recordInfo recordName]] atomically:YES];
        [[tags objectForKey:newName] addObject:data];
        
    }
    [tags removeObjectForKey:oldName];
    [self updateTag];
}

- (void)addTag:(NSString *)tagName
{
    [tags setObject:[[NSMutableArray alloc] init] forKey:tagName];
    [self updateTag];
}

- (NSMutableDictionary *)tags
{
    return tags;
}

- (void)addRecord:(RecordInfo *)recordInfo toTag:(NSString *)tagName
{
    NSMutableData *recordData = [[NSMutableData alloc] initWithContentsOfFile:[[self dataFilePath] stringByAppendingPathComponent:[recordInfo recordName]]];
    [[tags objectForKey:tagName] addObject:recordData];
    [self updateTag];
}

- (void)removeRecord:(RecordInfo *)recordInfo fromTag:(NSString *)tagName
{
    NSMutableData *recordData = [[NSMutableData alloc] initWithContentsOfFile:[[self dataFilePath] stringByAppendingPathComponent:[recordInfo recordName]]];
    [[tags objectForKey:tagName] removeObject:recordData];
    [self updateTag];
}


@end
