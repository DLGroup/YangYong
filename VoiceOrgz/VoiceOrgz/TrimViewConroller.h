//
//  TrimViewConroller.h
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 4/15/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VoiceInfo;

@interface TrimViewConroller : UIViewController<UIActionSheetDelegate>{
    CGPoint ptBegin;
    float start;
    float end;
    CGRect leftRect;
    CGRect rightRect;
}

@property (weak, nonatomic) IBOutlet UIScrollView *tagScrollView;
@property (copy, nonatomic) NSString *dirName;
@property (weak, nonatomic) IBOutlet UILabel *dirLabel;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *trimBtn;
@property (weak, nonatomic) VoiceInfo *voice;
@property (strong, nonatomic)UIImage *waveImage;
@property (strong, nonatomic)NSArray *samples;
@property (weak, nonatomic) IBOutlet UIImageView *waveView;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UILabel *audioScriptLabel;
@property (weak, nonatomic) IBOutlet UILabel *imageCountLabel;
@property (strong, nonatomic)NSOperationQueue *queue;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIView *trimView;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UIView *leftView;

- (IBAction)play:(id)sender;
- (IBAction)trim:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil voice:(VoiceInfo*)voice dirName:(NSString*)dirName;

@end
