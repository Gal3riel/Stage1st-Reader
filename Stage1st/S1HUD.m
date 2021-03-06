//
//  S1HUD.m
//  Stage1st
//
//  Created by Suen Gabriel on 2/23/13.
//  Copyright (c) 2013 Renaissance. All rights reserved.
//

#import "S1HUD.h"
#import "UIControl+BlockWrapper.h"

typedef enum {
    S1HUDStateShowText,
    S1HUDStateShowControl
} S1HUDState;


@implementation S1HUD {
    S1HUDState _state;
}

+ (S1HUD *)showHUDInView:(UIView *)view
{
    S1HUD *HUD = [[self alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    HUD.center = CGPointMake(roundf(CGRectGetMidX(view.bounds)), roundf(CGRectGetMidY(view.bounds)));
    HUD.alpha = 0.0;
    HUD.transform = CGAffineTransformMakeScale(0.85, 0.85);
    [view addSubview:HUD];
    [UIView animateWithDuration:0.2 animations:^{
        HUD.alpha = 1.0;
        HUD.transform = CGAffineTransformIdentity;
    }];
    return HUD;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        _state = S1HUDStateShowControl;
    }
    return self;
}

- (void)setText:(NSString *)text
{
    _text = text;
    [self removeSubviews];
    self.bounds = CGRectMake(0, 0, 120, 60);
    _state = S1HUDStateShowText;
    [self setNeedsDisplay];
}


- (void)showActivityIndicator
{
    [self removeSubviews];
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self addSubview:indicatorView];
    _state = S1HUDStateShowControl;
    [indicatorView startAnimating];
}

- (void)showRefreshButton
{
    [self removeSubviews];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.alpha = 0.8;
    [button setImage:[UIImage imageNamed:@"Refresh.png"] forState:UIControlStateNormal];
    [button addEventHandler:^(id sender, UIEvent *event) {
        if (self.refreshEventHandler) {
            self.refreshEventHandler(self);
        }
    } forControlEvent:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 40, 40);
    button.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self addSubview:button];
    _state = S1HUDStateShowControl;
}

- (void)removeSubviews
{
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *view = obj;
        [view removeFromSuperview];
    }];
}

- (void)drawRect:(CGRect)rect
{
    
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 0.316 green: 0.316 blue: 0.316 alpha: 1];
    UIColor* gradientColor = [UIColor colorWithRed: 0.419 green: 0.419 blue: 0.419 alpha: 1];
    UIColor* gradientColor2 = [UIColor colorWithRed: 0.054 green: 0.054 blue: 0.054 alpha: 1];
    UIColor* shadowColor2 = [UIColor colorWithRed: 0.855 green: 0.856 blue: 0.855 alpha: 1];
    UIColor* textColor = [UIColor colorWithRed: 0.88 green: 0.88 blue: 0.88 alpha: 1];
    
    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)gradientColor.CGColor,
                               (id)gradientColor2.CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    //// Shadow Declarations
    UIColor* innerShadow = shadowColor2;
    CGSize innerShadowOffset = CGSizeMake(0.1, 1.1);
    CGFloat innerShadowBlurRadius = 0.5;
    UIColor* outerShadow = gradientColor2;
    CGSize outerShadowOffset = CGSizeMake(0.1, 1.1);
    CGFloat outerShadowBlurRadius = 5;
    
    //// Frames
    CGRect frame = rect;
    
    
    //// Abstracted Attributes
    CGRect roundedRectangleRect = CGRectInset(rect, 7.5, 7.5);
    NSString* hUDTextContent = self.text;
    
    
    //// Rounded Rectangle Drawing
    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: roundedRectangleRect cornerRadius: 3];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, outerShadowOffset, outerShadowBlurRadius, outerShadow.CGColor);
    CGContextBeginTransparencyLayer(context, NULL);
    [roundedRectanglePath addClip];
    CGContextDrawLinearGradient(context, gradient,
                                CGPointMake(CGRectGetMidX(roundedRectangleRect), CGRectGetMinY(roundedRectangleRect)),
                                CGPointMake(CGRectGetMidX(roundedRectangleRect), CGRectGetMaxY(roundedRectangleRect)),
                                0);
    CGContextEndTransparencyLayer(context);
    
    ////// Rounded Rectangle Inner Shadow
    CGRect roundedRectangleBorderRect = CGRectInset([roundedRectanglePath bounds], -innerShadowBlurRadius, -innerShadowBlurRadius);
    roundedRectangleBorderRect = CGRectOffset(roundedRectangleBorderRect, -innerShadowOffset.width, -innerShadowOffset.height);
    roundedRectangleBorderRect = CGRectInset(CGRectUnion(roundedRectangleBorderRect, [roundedRectanglePath bounds]), -1, -1);
    
    UIBezierPath* roundedRectangleNegativePath = [UIBezierPath bezierPathWithRect: roundedRectangleBorderRect];
    [roundedRectangleNegativePath appendPath: roundedRectanglePath];
    roundedRectangleNegativePath.usesEvenOddFillRule = YES;
    
    CGContextSaveGState(context);
    {
        CGFloat xOffset = innerShadowOffset.width + round(roundedRectangleBorderRect.size.width);
        CGFloat yOffset = innerShadowOffset.height;
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                    innerShadowBlurRadius,
                                    innerShadow.CGColor);
        
        [roundedRectanglePath addClip];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(roundedRectangleBorderRect.size.width), 0);
        [roundedRectangleNegativePath applyTransform: transform];
        [[UIColor grayColor] setFill];
        [roundedRectangleNegativePath fill];
    }
    CGContextRestoreGState(context);
    
    CGContextRestoreGState(context);
    
    [color setStroke];
    roundedRectanglePath.lineWidth = 1;
    [roundedRectanglePath stroke];
    
    
    //// HUDText Drawing
    if (_state == S1HUDStateShowText) {
        UIFont *textFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
        CGFloat fontHeight = [textFont lineHeight];
        CGRect textRect = CGRectMake(8.0, floorf((frame.size.height-fontHeight)/2), frame.size.width-2*8.0, fontHeight);
        [textColor setFill];
        [hUDTextContent drawInRect:textRect withFont:textFont lineBreakMode:NSLineBreakByTruncatingMiddle alignment:NSTextAlignmentCenter];        
    }

    
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    

    
}

- (void)hideWithDelay:(NSTimeInterval)delay
{
    [UIView animateWithDuration:0.2 delay:delay options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(1.2, 1.2);
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

@end
