//
//  VoiceListViewController.h
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 2/26/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import <UIKit/UIKit.h>


@class VoiceInfo;
@class DirInfo;
@class CameraView;
@interface VoiceListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) DirInfo *dirInfo;
@property (assign, nonatomic) BOOL isRecording;
@property (assign, nonatomic) int selectedIdx;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *pictureShowImageView;
@property (weak, nonatomic) IBOutlet UIImageView *pictureShowBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *pictureShowImageViewMask;
@property (weak, nonatomic) IBOutlet UIView *pictureHolderView;

@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIView *recordingView;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UIView *recordControlView;

@property (weak, nonatomic) IBOutlet UIImageView *recordMarkView;
@property (strong, nonatomic)CameraView *layoutView;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *playTimer;
@property (weak, nonatomic) IBOutlet UIImageView *darkBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *recordBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *cameraBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *pauseBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *stopBackgroundView;
- (IBAction)pause:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil dirInfo:(DirInfo*)dirInfo recording:(BOOL)recording withVoice:(VoiceInfo*)voice;


- (IBAction)startRecord:(id)sender;
- (IBAction)stopRecord:(id)sender;
- (IBAction)startCamera:(id)sender;
- (void)selectFirstSection:(VoiceInfo*)voice;
- (void)stopRecordFromCamera:(VoiceInfo*)info;
- (void)cancelRecordFromCamera;
@end
