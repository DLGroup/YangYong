//
//  AddPicView.h
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 7/23/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VoiceInfo;
@interface AddPicView : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    int imageCount;
}
- (IBAction)takePic:(id)sender;
- (IBAction)controller:(id)sender;
@property (retain, nonatomic) IBOutlet UIImageView *imagePreView;
@property (retain, nonatomic) IBOutlet UILabel *label;
@property (assign, nonatomic) VoiceInfo *voice;
@property (assign, nonatomic) UIImagePickerController* ipc;
@property (retain, nonatomic) NSMutableArray *imgArray;
@property (retain, nonatomic) IBOutlet UIView *pictureView;
@property (retain, nonatomic) IBOutlet UILabel *alertView;
@property (retain, nonatomic) IBOutlet UIButton *cameraBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil ipc:(UIImagePickerController*)ipc voice:(VoiceInfo*)voice;

@end
