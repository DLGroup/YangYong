//
//  TagNew.h
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 8/5/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagNew : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (copy, nonatomic) NSString *lastTagName;
@property (weak, nonatomic) IBOutlet UIView *alertView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil lastTagName:(NSString*)lastTagName;
- (IBAction)valueChanged:(id)sender;

@end
