//
//  VoiceMainView.h
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 3/12/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class VoiceInfo;
@interface VoiceMainView : UIViewController<UIActionSheetDelegate, MFMailComposeViewControllerDelegate>{
    int lastImgCnt;
}

@property (copy, nonatomic) NSString *dirName;
@property (retain, nonatomic) VoiceInfo *voice;
@property (retain, nonatomic) IBOutlet UIImageView *mainImageView;
@property (retain, nonatomic) IBOutlet UILabel *imageCountLabel;
@property (retain, nonatomic) IBOutlet UILabel *leftLabel;
@property (retain, nonatomic) IBOutlet UILabel *rightLabel;
@property (retain, nonatomic) IBOutlet UILabel *audioScriptLabel;
@property (retain, nonatomic) IBOutlet UIScrollView *tagScrollView;


@property (retain, nonatomic) IBOutlet UIView *mainTopView;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UISlider *slider;
@property (retain, nonatomic) NSTimer *timer;
@property (retain, nonatomic) IBOutlet UILabel *dirLabel;

@property (retain, nonatomic) UIActionSheet *editSheet;
@property (retain, nonatomic) UIActionSheet *deleteSheet;
@property (retain, nonatomic) UIActionSheet *shareSheet;
@property (retain, nonatomic) IBOutlet UILabel *clipName;

- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)setProgress:(id)sender;

- (IBAction)share:(id)sender;
- (IBAction)del:(id)sender;
- (IBAction)move:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *startBtn;
@property (retain, nonatomic) IBOutlet UIButton *pauseBtn;

@property (retain, nonatomic) UIImagePickerController* ipc;
@property (retain, nonatomic) UIViewController *layoutView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil voice:(VoiceInfo*)voice dirName:(NSString*)dirName;
@end
