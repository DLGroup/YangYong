//
//  AppDelegate.h
//  CADemo
//
//  Created by tll007 on 12/26/12.
//  Copyright (c) 2012 diluntech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (weak) IBOutlet NSView *layerView;

@property (assign) IBOutlet NSWindow *window;
@property (strong) CALayer *layer;
@property (strong) CALayer *subLayer;

- (IBAction)implictLayerAnimation:(id)sender;
- (IBAction)implictLayerAnimationUsingCATransaction:(id)sender;
- (IBAction)animationUsingCABasicAnimation:(id)sender;
- (IBAction)animationUsingCAAnimationGroup:(id)sender;
- (IBAction)animationUsingCAKeyframeAnimation:(id)sender;
- (IBAction)shakeSelf:(id)sender;
- (IBAction)rotateSelf:(id)sender;
- (IBAction)scale3D:(id)sender;

@end
