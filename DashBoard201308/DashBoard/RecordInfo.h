//
//  RecordInfo.h
//  DashBoard
//
//  Created by Yong Yang on 13-8-7.
//  Copyright (c) 2013年 DiLunTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface RecordInfo : NSObject <NSCoding>
{
    //tags realized lalter
    //......
//    NSMutableDictionary *tags;    
}

@property (strong, nonatomic) NSString *folderName;
@property (strong, nonatomic) NSString *recordName;

//...init method
- (id)initWithRecordName:(NSString *)recordName andFolderName: (NSString *)folderName;

@end







