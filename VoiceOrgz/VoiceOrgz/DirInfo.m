//
//  DirInfo.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 2/27/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import "DirInfo.h"

@implementation DirInfo

@synthesize subDirs=_subDirs;
@synthesize voices=_voices;
@synthesize parent=_parent;
@synthesize dirsMap=_dirsMap;


- (id)initWithCoder:(NSCoder *)aDecoder{
    self=[super init];
    if(self){
        _subDirs=[aDecoder decodeObjectForKey:@"subDirs"];
        _voices=[aDecoder decodeObjectForKey:@"voices"];
        _parent=[aDecoder decodeObjectForKey:@"parent"];
        _dirsMap=[aDecoder decodeObjectForKey:@"dirsMap"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_subDirs forKey:@"subDirs"];
    [aCoder encodeObject:_voices forKey:@"voices"];
    [aCoder encodeObject:_parent forKey:@"parent"];
    
    [aCoder encodeObject:_dirsMap forKey:@"dirsMap"];
}


- (id)initWithParent:(NSString *)parent{
    self=[super init];
    if(self){
        
        _subDirs=[[NSMutableArray alloc] init];
        
        _dirsMap=[[NSMutableDictionary alloc] init];
        _parent=parent;
        _voices=[[NSMutableArray alloc] init];

    }
    
    return self;
}
@end
