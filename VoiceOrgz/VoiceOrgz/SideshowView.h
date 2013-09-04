//
//  SideshowView.h
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 3/25/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalObj.h"
#import "DLPlayer.h"

@class VoiceInfo;
@interface SideshowView : UIViewController<UIScrollViewDelegate, UIActionSheetDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate>{
    int lastPage;
    CGSize size;
    BOOL isFullScreen;
    int fullScreenIdx;
    int initIdx;
    
    float offset;
    float xoffset;
    
    int lastImgCnt;
    BOOL isInit;
}
- (IBAction)deleteImage:(id)sender;

@property (retain, nonatomic) UITapGestureRecognizer *singTapOnPreview;
@property (retain, nonatomic) UITapGestureRecognizer *doubleTapOnPreView;
@property (retain, nonatomic) UITapGestureRecognizer *singTapOnListView;
@property (retain, nonatomic) UITapGestureRecognizer *singTapOnFullScreenView;

//@property (assign, nonatomic) UIButton *voiceBtn;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollViewPre;
@property (retain, nonatomic) VoiceInfo *voice;
@property (retain, nonatomic)NSMutableArray *imageViews;
@property (retain, nonatomic)NSMutableArray *imageViewsPre;
@property (retain, nonatomic) IBOutlet UIButton *trashBtn;
- (IBAction)takePic:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *startBtn;
@property (retain, nonatomic) IBOutlet UIButton *pauseBtn;

@property (retain, nonatomic) IBOutlet UILabel *label;
@property (retain, nonatomic) NSTimer *timer;
@property (retain, nonatomic) IBOutlet UIImageView *thumbBackground;
@property (retain, nonatomic) UIImagePickerController* ipc;
@property (retain, nonatomic) UIViewController *layoutView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil voice:(VoiceInfo*)voice idx:(int)idx;

@end
