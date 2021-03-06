//
//  BLCCircleSpinnerView.m
//  Blocstagram
//
//  Created by Stephen Palley on 12/31/14.
//  Copyright (c) 2014 Steve Palley. All rights reserved.
//

#import "BLCCircleSpinnerView.h"

@interface BLCCircleSpinnerView ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;

@end

@implementation BLCCircleSpinnerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CAShapeLayer*)circleLayer {
    if(!_circleLayer) {
        CGPoint arcCenter = CGPointMake(self.radius+self.strokeThickness/2+5, self.radius+self.strokeThickness/2+5); //center of circle
        CGRect rect = CGRectMake(0, 0, arcCenter.x*2, arcCenter.y*2); //rectangle around circle
        
        UIBezierPath* smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                                    radius:self.radius
                                                                startAngle:M_PI*3/2
                                                                  endAngle:M_PI/2+M_PI*5
                                                                 clockwise:YES]; //circular path
        
        _circleLayer = [CAShapeLayer layer]; //make shapelayer
        _circleLayer.contentsScale = [[UIScreen mainScreen] scale];
        _circleLayer.frame = rect;
        _circleLayer.fillColor = [UIColor clearColor].CGColor;
        _circleLayer.strokeColor = self.strokeColor.CGColor;
        _circleLayer.lineWidth = self.strokeThickness;
        _circleLayer.lineCap = kCALineCapRound;
        _circleLayer.lineJoin = kCALineJoinBevel;
        _circleLayer.path = smoothedPath.CGPath; //plug in circular path
        
        CALayer *maskLayer = [CALayer layer]; //mask layer to change opacity of cirle
        maskLayer.contents = (id)[[UIImage imageNamed:@"angle-mask"] CGImage];
        maskLayer.frame = _circleLayer.bounds;
        _circleLayer.mask = maskLayer;
        
        CFTimeInterval animationDuration = 1;
        CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"]; //animate the mask
        animation.fromValue = @0;
        animation.toValue = @(M_PI*2);
        animation.duration = animationDuration;
        animation.timingFunction = linearCurve;
        animation.removedOnCompletion = NO;
        animation.repeatCount = INFINITY;
        animation.fillMode = kCAFillModeForwards;
        animation.autoreverses = NO;
        [_circleLayer.mask addAnimation:animation forKey:@"rotate"];
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation]; //create group for start and end animations
        animationGroup.duration = animationDuration;
        animationGroup.repeatCount = INFINITY;
        animationGroup.removedOnCompletion = NO;
        animationGroup.timingFunction = linearCurve;
        
        CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        strokeStartAnimation.fromValue = @0.015;
        strokeStartAnimation.toValue = @0.515;
        
        CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        strokeEndAnimation.fromValue = @0.485;
        strokeEndAnimation.toValue = @0.985;
        
        animationGroup.animations = @[strokeStartAnimation, strokeEndAnimation];
        [_circleLayer addAnimation:animationGroup forKey:@"progress"];
        
    }
    return _circleLayer;
}

//put animation in the center of the view
- (void)layoutAnimatedLayer {
    [self.layer addSublayer:self.circleLayer];
    
    self.circleLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

//this is called when animation is added as a subview by another UIView object, ensuring it's layed out properly
- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview != nil) {
        [self layoutAnimatedLayer];
    }
    else {
        [self.circleLayer removeFromSuperlayer];
        self.circleLayer = nil;
    }
}

//this is called when the frame changes
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (self.superview != nil) {
        [self layoutAnimatedLayer];
    }
}

//if radius of circle changes, recreate animation
- (void)setRadius:(CGFloat)radius {
    _radius = radius;
    
    [_circleLayer removeFromSuperlayer];
    _circleLayer = nil;
    
    [self layoutAnimatedLayer];
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    _circleLayer.strokeColor = strokeColor.CGColor;
}

- (void)setStrokeThickness:(CGFloat)strokeThickness {
    _strokeThickness = strokeThickness;
    _circleLayer.lineWidth = _strokeThickness;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame]; //??? I think I need a tutorial on self & super...
    if (self) {
        self.strokeThickness = 2;
        self.radius = 12;
        self.strokeColor = [UIColor blackColor];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake((self.radius+self.strokeThickness/2+5)*2, (self.radius+self.strokeThickness/2+5)*2);
}

@end
