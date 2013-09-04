//
//  SharedObj.h
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 2/27/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import <Foundation/Foundation.h>


#define VOICE_BASE_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Voices"] 
#define VOICE_DEFAULT_NAME @"Audio clip"

@class SharedObj;
@class DirInfo;
SharedObj *_sharedObj;

@interface SharedObj : NSObject<NSCoding>

@property (strong, nonatomic) DirInfo *dirInfo;
@property (strong, nonatomic) NSMutableArray *voice;
@property (strong, nonatomic) NSMutableDictionary *tag;
+ (SharedObj*)sharedObj;
- (id)initWithDefault;

+ (void)save;
@end
