//
//  RenameView.h
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 9/3/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RenameView : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *textField;
- (IBAction)valueChanged:(id)sender;

@end
