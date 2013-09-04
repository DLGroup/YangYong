//
//  FoldersViewController.h
//  DashBoard
//
//  Created by Teddy on 8/4/13.
//  Copyright (c) 2013 DiLunTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "Persistence.h"
#import "RecordInfo.h"

NSUInteger sectionCounts;
NSMutableArray *allRecordsConfigInfo;

@interface FoldersViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate>
{
    NSString *folderName;
    NSUInteger selectedSection; //show slider cell or not
    BOOL inserting;               //insert cell animationly
    NSMutableString *recordName;//the name of every sound file
    Persistence *persistence;
    RecordInfo *recordInfo;
    
    UILabel *timerLabel;
    int min, sec, msec;
    NSTimer *timer;
    // recorder and player and session
    AVAudioSession *session;
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

//control the property enabled
@property (weak, nonatomic) IBOutlet UIButton *recBtn;

//animation property
@property (strong, nonatomic) IBOutlet UIView *recAnimView;
@property (strong, nonatomic) IBOutlet UIView *stopAndPauseAnimView;
@property (strong, nonatomic) IBOutlet UIView *recMaskAnimView;

- (IBAction)stop:(id)sender;
- (IBAction)record:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil folderName:(NSString *)name;

@end
