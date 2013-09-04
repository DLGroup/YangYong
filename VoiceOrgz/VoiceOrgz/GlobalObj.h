//
//  GlobalObj.h
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 4/9/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NSString* sha1(NSString* input);

@class DLRecorder;
@class DLPlayer;
@class GlobalObj;

GlobalObj *_globalObj;
@interface GlobalObj : NSObject
@property (strong, nonatomic)DLRecorder *recorder;
@property (strong, nonatomic)DLPlayer *player;
@property (strong, nonatomic)NSMutableDictionary *imageCache;
+ (GlobalObj*)globalObj;
+ (UIImage*)getImageFromFile:(NSString*)fileName;
+ (void)refreshCache;
+ (UIImage*)reSizeImage:(UIImage *)image toSize:(CGSize)reSize;
@end
