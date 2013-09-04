//
//  FolderNew.h
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 8/5/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FolderNew : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (copy, nonatomic) NSString *lastFolderName;
@property (weak, nonatomic) IBOutlet UIView *alertView;
- (IBAction)valueChanged:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil lastFolderName:(NSString*)lastFolderName;

@end
