//
//  VoiceInfo.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 2/27/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import "VoiceInfo.h"

@implementation VoiceInfo

@synthesize createDate=_createDate;
@synthesize duration=_duration;
@synthesize size=_size;
@synthesize path=_path;
@synthesize name=_name;
@synthesize imgIdx=_imgIdx;
@synthesize imgArray=_imgArray;
@synthesize tag=_tag;
@synthesize dir=_dir;

- (NSString*)description{
    return [NSString stringWithFormat:@"%@,%d", _path, _imgArray.count];
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    self=[super init];
    if(self){
        _createDate=[aDecoder decodeObjectForKey:@"createDate"];
        _duration=[aDecoder decodeFloatForKey:@"duration"];
        _size=[aDecoder decodeFloatForKey:@"size"];
        _path=[aDecoder decodeObjectForKey:@"path"];
        _name=[aDecoder decodeObjectForKey:@"name"];
        _dir=[aDecoder decodeObjectForKey:@"dir"];
        
        _imgIdx=[aDecoder decodeIntForKey:@"imgIdx"];
        _imgArray=[aDecoder decodeObjectForKey:@"imgArray"];
        _tag=[aDecoder decodeObjectForKey:@"tag"];

    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_createDate forKey:@"createDate"];
    [aCoder encodeFloat:_duration forKey:@"duration"];
    [aCoder encodeFloat:_size forKey:@"size"];
    [aCoder encodeObject:_path forKey:@"path"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_dir forKey:@"dir"];
    [aCoder encodeInt:_imgIdx forKey:@"imgIdx"];
    [aCoder encodeObject:_imgArray forKey:@"imgArray"];
    [aCoder encodeObject:_tag forKey:@"tag"];

}


- (id)initWithVoiceName:(NSString *)name path:(NSString *)path createDate:(NSDate *)date duration:(double)duration size:(UInt64)size dir:(NSString *)dir{
    
    self=[super init];
    if(self){
        _name = name;
        _path = path;
        _createDate = date;
        _duration = duration;
        _size = size;
        _dir=dir;
        
        _imgIdx=-1;
        _imgArray=[[NSMutableArray alloc] initWithCapacity:9];
        
        _tag=[[NSMutableArray alloc] init];
        return self;
    }
    else
        return nil;
}
@end



