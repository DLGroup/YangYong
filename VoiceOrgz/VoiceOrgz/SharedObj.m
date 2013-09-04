//
//  SharedObj.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 2/27/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import "SharedObj.h"
#import "DirInfo.h"
#import "VoiceInfo.h"

@implementation SharedObj

@synthesize dirInfo=_dirInfo;
@synthesize voice=_voice;
@synthesize tag=_tag;
+ (void)save{
    SharedObj *obj=[SharedObj sharedObj];
    NSMutableData *data=[[NSMutableData alloc] init];
    NSKeyedArchiver *ar=[[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [ar encodeObject:obj forKey:@"sharedObj"];
    [ar finishEncoding];
    
    [data writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Data/sharedObj"] atomically:YES];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self=[super init];
    if(self){
        _dirInfo=[aDecoder decodeObjectForKey:@"dirInfo"];
        _voice=[aDecoder decodeObjectForKey:@"voice"];
        _tag=[aDecoder decodeObjectForKey:@"tag"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_dirInfo forKey:@"dirInfo"];
    [aCoder encodeObject:_voice forKey:@"voice"];
    [aCoder encodeObject:_tag forKey:@"tag"];

}

- (id)initWithDefault{
    self=[super init];
    if(self){
        
        _dirInfo=[[DirInfo alloc] initWithParent:nil];
        
        [_dirInfo.subDirs addObject:@"Recordings"];
        [_dirInfo.dirsMap setObject:[[DirInfo alloc] initWithParent:@"Recordings"] forKey:@"Recordings"];
        
        [_dirInfo.subDirs addObject:@"Home"];
        [_dirInfo.dirsMap setObject:[[DirInfo alloc] initWithParent:@"Home"] forKey:@"Home"];
        
        _voice=[[NSMutableArray alloc] init];
        
        _tag=[[NSMutableDictionary alloc] init];
        
        [_tag setObject:[[NSMutableArray alloc] init]forKey:@"ChongQing"];
        [_tag setObject:[[NSMutableArray alloc] init]forKey:@"BeiJin"];
        [_tag setObject:[[NSMutableArray alloc] init]forKey:@"Hot"];

        //create dirs
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm createDirectoryAtPath:[NSString stringWithFormat:@"%@/Documents/Images", NSHomeDirectory()] withIntermediateDirectories:YES attributes:nil error:nil];
        [fm createDirectoryAtPath:[NSString stringWithFormat:@"%@/Documents/Audios", NSHomeDirectory()] withIntermediateDirectories:YES attributes:nil error:nil];
        [fm createDirectoryAtPath:[NSString stringWithFormat:@"%@/Documents/Data", NSHomeDirectory()] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return self;
}

+ (SharedObj*)sharedObj{
    if(!_sharedObj){
        _sharedObj = [[SharedObj alloc] initWithDefault];
    }
    
    return _sharedObj;
}
@end
