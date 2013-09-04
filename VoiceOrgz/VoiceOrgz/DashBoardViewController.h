//
//  DashBoardViewController.h
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 2/25/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DirInfo;
@class CameraView;
@interface DashBoardViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    BOOL keyboardVisible;
    float tableHeight;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) UITextField *activeTextField;
@property (weak, nonatomic) DirInfo *dirInfo;
@property (strong, nonatomic)CameraView *layoutView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroudView;
@property (weak, nonatomic) IBOutlet UIImageView *recordBackgroudView;
@property (weak, nonatomic) IBOutlet UIImageView *cameraBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UIButton *cameraBtn;

- (IBAction)startCamera:(id)sender;
- (IBAction)startRecording:(id)sender;
@end
