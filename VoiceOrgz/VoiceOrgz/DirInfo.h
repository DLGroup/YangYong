//
//  DirInfo.h
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 2/27/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DirInfo : NSObject<NSCoding>
@property (strong, nonatomic) NSMutableDictionary *dirsMap;
@property (strong, nonatomic) NSMutableArray *subDirs;
@property (strong, nonatomic) NSMutableArray *voices;
@property (strong, nonatomic) NSString *parent;

- (id)initWithParent:(NSString*)parent;
@end
