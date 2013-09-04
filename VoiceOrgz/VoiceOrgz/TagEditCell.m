//
//  TagEditCell.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 8/8/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import "TagEditCell.h"

@implementation TagEditCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)showLabel{
    UIView *view=[self viewWithTag:102];
    view.hidden=NO;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    
    [super setEditing:editing animated:animated];
    if(editing==NO){
        [self performSelector:@selector(showLabel) withObject:nil afterDelay:0.25f];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    [super willTransitionToState:state];
    
    UIView *view=[self viewWithTag:102];
    if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == 				UITableViewCellStateShowingDeleteConfirmationMask){
        view.hidden=YES;
    }
    
    else if ((state & UITableViewCellStateShowingEditControlMask) == 				UITableViewCellStateShowingEditControlMask){
        if(view.hidden)
            view.hidden=NO;
    }

}


@end




