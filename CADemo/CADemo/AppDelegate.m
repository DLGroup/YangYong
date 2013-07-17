//
//  AppDelegate.m
//  CADemo
//
//  Created by tll007 on 12/26/12.
//  Copyright (c) 2012 diluntech. All rights reserved.
//

#import "AppDelegate.h"
#include <time.h>
#import <QuartzCore/QuartzCore.h>

@implementation AppDelegate

@synthesize layer=_layer;
@synthesize layerView=_layerView;
@synthesize subLayer=_subLayer;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)awakeFromNib{
    [_layerView setWantsLayer:YES];
    _layer = [CALayer layer];
    
    CGRect  bounds=CGRectMake(0.0, 0.0, 50.0, 50.0);
    CGPoint pos=CGPointMake((_layerView.frame.origin.x + (_layerView.frame.size.width / 2)),
                            (_layerView.frame.origin.y + (_layerView.frame.size.height / 2)));
    [_layer setBounds:bounds];
    [_layer setPosition:pos];
    
    //set background color and make round corner
    CGColorRef color = CGColorCreateGenericRGB(0.1, 0.2, 0.3, 1);
    [_layer setBackgroundColor:color];
    [_layer setCornerRadius:10.0];
    CFRelease(color);
    
    //change default transition
    CATransition *transition=[CATransition animation];
    [transition setType:kCATransitionMoveIn];
    [transition setSubtype:kCATransitionFromTop];
    [transition setDuration:1.0];
    NSMutableDictionary *actions = [NSMutableDictionary dictionaryWithDictionary:[_layer actions]];
    [actions setObject:transition forKey:@"opacity"];
    [_layer setActions:actions];
    
    
    [[_layerView layer] addSublayer:_layer];
}


//implicit layer animation with default duration(0.25s)
- (IBAction)implictLayerAnimation:(id)sender {
    
    srand((unsigned int)time(0));
    
    CGColorRef color = CGColorCreateGenericRGB((float)rand()/INT_MAX,
                                               (float)rand()/INT_MAX,
                                               (float)rand()/INT_MAX,
                                               (float)rand()/INT_MAX);
    [_layer setBackgroundColor:color];
    CFRelease(color);
}

//explicit layer animation using transaction 
- (IBAction)implictLayerAnimationUsingCATransaction:(id)sender {
    
    srand((unsigned int)time(0));
    [_layer removeAllAnimations];
    
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:3.0]
                     forKey:kCATransactionAnimationDuration];
    CGColorRef color = CGColorCreateGenericRGB((float)rand()/INT_MAX,
                                               (float)rand()/INT_MAX,
                                               (float)rand()/INT_MAX,
                                               (float)rand()/INT_MAX);
    [_layer setBackgroundColor:color];
    CFRelease(color);

    [CATransaction commit];
}

//simple basic animation
//the CABasicAnimation class provides a way to animate between two values, a starting value and an ending value
 
- (IBAction)animationUsingCABasicAnimation:(id)sender {
    NSRect oldRect = NSMakeRect(0.0, 0.0, 50.0, 50.0);
    NSRect newRect = NSMakeRect(0.0, 0.0, 100.0, 100.0);
    [_layer removeAllAnimations];
    
    //key should be one of attribute of CALayer
    CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    [boundsAnimation setFromValue:[NSValue valueWithRect:oldRect]];
    [boundsAnimation setToValue:[NSValue valueWithRect:newRect]];
    [boundsAnimation setDuration:5.0];
    
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    [positionAnimation setFromValue: [NSValue valueWithPoint: NSPointFromCGPoint([_layer position])]];
    [positionAnimation setToValue:[NSValue valueWithPoint:NSMakePoint(100.0, 100.0)]];
    [positionAnimation setDuration:5.0];
    
    CABasicAnimation *borderWidthAnimation = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
    [borderWidthAnimation setFromValue:[NSNumber numberWithFloat:5.0]];
    [borderWidthAnimation setToValue:[NSNumber numberWithFloat:10.0]];
    [borderWidthAnimation setDuration:5.0];
    
    [_layer addAnimation:boundsAnimation forKey:@"bounds"];
    [_layer addAnimation:positionAnimation forKey:@"postion"];
    [_layer addAnimation:borderWidthAnimation forKey:@"boarder"];
}

//group animation
- (IBAction)animationUsingCAAnimationGroup:(id)sender {
    NSRect oldRect = NSMakeRect(0.0, 0.0, 50.0, 50.0);
    NSRect newRect = NSMakeRect(0.0, 0.0, 100.0, 100.0);
    [_layer removeAllAnimations];
    
    //key should be one of attribute of CALayer
    CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    [boundsAnimation setFromValue:[NSValue valueWithRect:oldRect]];
    [boundsAnimation setToValue:[NSValue valueWithRect:newRect]];
    [boundsAnimation setDuration:5.0];
    [boundsAnimation setBeginTime:0.0];
    [boundsAnimation setFillMode:kCAFillModeForwards];
    
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    [positionAnimation setFromValue: [NSValue valueWithPoint: NSPointFromCGPoint([_layer position])]];
    [positionAnimation setToValue:[NSValue valueWithPoint:NSMakePoint(100.0, 100.0)]];
    [positionAnimation setDuration:5.0];
    [positionAnimation setBeginTime:5.0];
    [positionAnimation setFillMode:kCAFillModeForwards];
    
    CABasicAnimation *borderWidthAnimation = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
    [borderWidthAnimation setFromValue:[NSNumber numberWithFloat:5.0]];
    [borderWidthAnimation setToValue:[NSNumber numberWithFloat:10.0]];
    [borderWidthAnimation setDuration:5.0];
    [borderWidthAnimation setBeginTime:10.0];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    [group setDuration:15.0];
    [group setAnimations:[NSArray arrayWithObjects:boundsAnimation, positionAnimation,borderWidthAnimation, nil]];
    [_layer addAnimation:group forKey:nil];
    
}

//keyframe animation enables you to specify the values for each of the major steps in your animation,
//then fills in the rest for you
- (IBAction)animationUsingCAKeyframeAnimation:(id)sender {
    CGFloat yOrign=[_layer position].y;
    CGFloat yLow=yOrign-50.0;
    CGFloat yHigh=yOrign+50.0;
    [_layer removeAllAnimations];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path,NULL,50.0,yLow);
    CGPathAddCurveToPoint(path,NULL,50.0 ,yHigh,150.0,yHigh,150.0,yLow);
    CGPathAddCurveToPoint(path,NULL,150.0,yHigh,250.0,yHigh,250.0,yLow);
    CGPathAddCurveToPoint(path,NULL,250.0,yHigh,350.0,yHigh,350.0,yLow);
    CGPathAddCurveToPoint(path,NULL,350.0,yHigh,450.0,yHigh,450.0,yLow);
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [animation setPath:path];
    [animation setDuration:3.0];
    [animation setAutoreverses:YES];
    CFRelease(path);
    
    [_layer addAnimation:animation forKey:@"keyFrame"];
}

- (IBAction)shakeSelf:(id)sender {
    
    if(!_subLayer){
        _subLayer=[CALayer layer];
        [_subLayer setFrame:CGRectMake(0.0,_layer.frame.size.height-20.0, 20.0, 20.0)];
        
        CGColorRef backColor = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0);
        [_subLayer setBackgroundColor:backColor];
        CFRelease(backColor);
        
        [_subLayer setBorderWidth:2];
        [_subLayer setCornerRadius:10];
        [_subLayer setDelegate:self];
    }
    [_subLayer removeFromSuperlayer];
    [_layer removeAllAnimations];
    
    [_layer addSublayer:_subLayer];
    [_subLayer setNeedsDisplay];
    
    CAKeyframeAnimation *animation=[CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    [animation setDuration:0.25];
    [animation setRepeatCount:10000];
    
    NSMutableArray *values=[NSMutableArray array];
    
    [values addObject:[NSNumber numberWithFloat:-2.0*M_PI/180.0]];
    [values addObject:[NSNumber numberWithFloat: 2.0*M_PI/180.0]];
    [values addObject:[NSNumber numberWithFloat:-2.0*M_PI/180.0]];

    [animation setValues:values];
    [_layer addAnimation:animation forKey:@"shake"];
}

- (IBAction)rotateSelf:(id)sender {
    CATransform3D transform;
    NSValue *value=nil;
    
    [_layer removeAllAnimations];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    //rote PI/2.0 angle around vector<1.0, 1.0, 0.0>
    transform = CATransform3DMakeRotation(M_PI/2.0, 0.0, 1.0, 1.0);
    
    value = [NSValue valueWithCATransform3D:transform];
    [animation setToValue:value];
    transform = CATransform3DMakeRotation(0.0, 0.0, 1.0, 1.0);
    
    value = [NSValue valueWithCATransform3D:transform];
    [animation setFromValue:value];
    
    [animation setAutoreverses:YES];
    [animation setDuration:1.0];
    [animation setRepeatCount:100];
    [_layer addAnimation:animation forKey:@"rotate"];

}

- (IBAction)scale3D:(id)sender {
    NSValue *value = nil;
    CATransform3D transform;
    [_layer removeAllAnimations];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transform = CATransform3DMakeScale(0.5, 0.5, 0.5);
    value = [NSValue valueWithCATransform3D:transform];
    [animation setToValue:value];
    transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
    value = [NSValue valueWithCATransform3D:transform];
    [animation setFromValue:value];
    [animation setAutoreverses:YES];
    [animation setDuration:1.0];
    [animation setRepeatCount:100];
    [_layer addAnimation:animation forKey:@"scale3D"];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context{
    if(layer==_subLayer){
        
        //draw a 'X' in layer
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGPathMoveToPoint(path,NULL,5.0,5.0);
        CGPathAddLineToPoint(path, NULL, 15.0, 15.0);
        
        CGPathMoveToPoint(path,NULL,5.0,15.0);
        CGPathAddLineToPoint(path, NULL, 15.0, 5.0);
        
        CGColorRef white =CGColorCreateGenericRGB(1.0, 1.0, 1.0, 1.0);
        CGContextSetStrokeColorWithColor(context, white);
        CGColorRelease(white);
        
        CGContextBeginPath(context);
        CGContextAddPath(context, path);
        
        CGContextSetLineWidth(context, 2.0);
        CGContextStrokePath(context);
        CGPathRelease(path);
    }
}

//hit test
- (void)mouseDown:(NSEvent*)theEvent {
    NSPoint mouseLocation = [NSEvent mouseLocation];
    NSPoint translated = [_window convertScreenToBase:mouseLocation];
    CGPoint point = NSPointToCGPoint(translated);
    
    CALayer *topLayer = [_layerView layer];
    id hitLayer = [topLayer hitTest:point];
    
    //click 'X'
    if (hitLayer==_subLayer) {
        [_subLayer removeFromSuperlayer];
        [_layer removeAnimationForKey:@"shake"];
    }

}

@end











