//
//  GlobalObj.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 4/9/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import "GlobalObj.h"
#import "DLRecorder.h"
#import <CommonCrypto/CommonDigest.h>

NSString* sha1(NSString* input){
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}
@implementation GlobalObj

@synthesize recorder=_recorder;
@synthesize player=_player;
- (id)init{
    self=[super init];
    if(self){
        _recorder = [[DLRecorder alloc] init];
        if(!_recorder)
            return nil;
    }

    return self;
}

+ (GlobalObj*)globalObj{
    if(!_globalObj)
        _globalObj=[[GlobalObj alloc] init];
    
    return _globalObj;
}


+ (UIImage*)getImageFromFile:(NSString *)fileName{
    if(!_globalObj.imageCache)
        _globalObj.imageCache=[[NSMutableDictionary alloc] init];
    
    NSString *file=nil;
    UIImage *image=nil;
    file = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    
    image=[_globalObj.imageCache objectForKey:file];
    if(!image){
        image=[[UIImage alloc] initWithContentsOfFile:file];
        [_globalObj.imageCache setObject:image forKey:file];
    }
    return image;
}

+ (void)refreshCache{
    [_globalObj.imageCache removeAllObjects];
}

+ (UIImage*)reSizeImage:(UIImage *)image toSize:(CGSize)reSize

{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
    
}

@end








