//
//  CameraView.h
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 3/13/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DirInfo;
@interface CameraView : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    int imageCount;
    BOOL pause;
}
@property (retain, nonatomic) IBOutlet UIView *pictureView;
@property (assign, nonatomic) UIImagePickerController *ipc;
@property (retain, nonatomic) NSMutableArray *imgArray;
@property (retain, nonatomic) IBOutlet UIView *recordControlView;
@property (retain, nonatomic) IBOutlet UIView *recordView;
@property (retain, nonatomic) IBOutlet UIImageView *markView;
@property (retain, nonatomic) IBOutlet UILabel *textLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;

@property (retain, nonatomic) DirInfo *dirInfo;
@property (retain, nonatomic) NSTimer *timer;
@property (retain, nonatomic) IBOutlet UIImageView *pictureImageView;
@property (retain, nonatomic) IBOutlet UILabel *alertView;
@property (retain, nonatomic) IBOutlet UIButton *cameraBtn;

- (IBAction)snap:(id)sender;
- (IBAction)returnCtl:(id)sender;
- (IBAction)startRecord:(id)sender;
- (IBAction)stopRecord:(id)sender;
- (IBAction)pauseRecord:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil ipc:(UIImagePickerController*)ipc dirInfo:(DirInfo*)dirInfo;
@end
