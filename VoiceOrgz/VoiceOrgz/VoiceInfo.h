//
//  VoiceInfo.h
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 2/27/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoiceInfo : NSObject<NSCoding>

@property (strong, nonatomic) NSDate *createDate;
@property (assign, nonatomic) double duration;
@property (assign, nonatomic) UInt64 size;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSString *name;

@property (assign, nonatomic) int imgIdx;
@property (strong, nonatomic) NSMutableArray *imgArray;

@property (strong, nonatomic)NSMutableArray *tag;

@property (strong, nonatomic) NSString *dir;
- (id)initWithVoiceName:(NSString*)name path:(NSString*)path createDate:(NSDate*)date duration:(double)duration size:(UInt64)size dir:(NSString*)dir;;

@end
