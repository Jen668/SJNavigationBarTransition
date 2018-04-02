//
//  UINavigationController+extend.m
//  RYTaxiClient
//
//  Created by 讯心科技 on 2017/7/10.
//  Copyright © 2017年 讯心科技. All rights reserved.
//

#import "UINavigationController+extend.h"
#import "UIViewController+Bar.h"
#import <objc/runtime.h>


@implementation UINavigationController (extend)


- (void)configOriginlNavBar
{
    self.navigationBar.translucent = YES;
    
    UIView *barBgView = self.navigationBar.subviews.firstObject;
    
    barBgView.backgroundColor = [UIColor clearColor];
    
    if (@available(iOS 10.0, *))
    {
        UIView *bgEffectView = [barBgView valueForKey:@"_backgroundEffectView"];
        if (bgEffectView && [self.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] == nil)
        {
            bgEffectView.alpha = 0.0;
        }
    }else
    {
        UIView *adaptiveBackDrop = [barBgView valueForKey:@"_adaptiveBackdrop"];
        UIView *backDropEffectView = [adaptiveBackDrop valueForKey:@"_backdropEffectView"];
        if (adaptiveBackDrop && backDropEffectView)
        {
            backDropEffectView.alpha = 0.0;
        }
    }
}

+ (void)swizzleOriginalSelector:(SEL)originalSelector withCurrentSelector:(SEL)currentSelector
{
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, currentSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            currentSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)load
{
    SEL originalSelector1  = @selector(initWithCoder:);
    SEL swizzledSelector1  = NSSelectorFromString(@"z_initWithCoder:");
    [self swizzleOriginalSelector:originalSelector1 withCurrentSelector:swizzledSelector1];
    
    SEL originalSelector2  = @selector(initWithRootViewController:);
    SEL swizzledSelector2  = NSSelectorFromString(@"z_initWithRootViewController:");
    [self swizzleOriginalSelector:originalSelector2 withCurrentSelector:swizzledSelector2];
}


- (instancetype)z_initWithCoder:(NSCoder *)aDecoder
{
    UINavigationController *nav = [self z_initWithCoder:aDecoder];
    
    nav.delegate = nav;
    
    return nav;
}

- (instancetype)z_initWithRootViewController:(UIViewController *)rootViewController
{
    UINavigationController *nav = [self z_initWithRootViewController:rootViewController];
    
    nav.delegate = nav;
    
    return nav;
}


#pragma mark- UINavigationBarDelegate
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item
{
    [self addBarForViewController:self.topViewController];
    
    return YES;
}


#pragma mark- UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self configOriginlNavBar];
    });
    
    UIView *shadow = [self.navigationBar.subviews.firstObject valueForKey:@"_shadowView"];
    
    shadow.hidden = viewController.barAlpha == 0.0;
    
    [self updateStatusBarStyleWithViewController:viewController];
}


#pragma mark- Methods
- (void)addBarForViewController:(UIViewController *)viewController
{
    if (viewController.navBarBackgroundImage)
    {
        UIImageView *bar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.navigationBar.subviews.firstObject.frame.size.width, self.navigationBar.subviews.firstObject.frame.size.height)];
        
        bar.image = viewController.navBarBackgroundImage;
        
        bar.alpha = viewController.barAlpha;
        
        [viewController.view addSubview:bar];
        
        [viewController.view bringSubviewToFront:bar];;
        
        viewController.navBar = bar;
    }else
    {
        UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.navigationBar.subviews.firstObject.frame.size.width, self.navigationBar.subviews.firstObject.frame.size.height)];
        
        bar.backgroundColor = viewController.navBarBackgroundColor;
        
        bar.alpha = viewController.barAlpha;
        
        [viewController.view addSubview:bar];
        
        [viewController.view bringSubviewToFront:bar];;
        
        viewController.navBar = bar;
    }
}


- (void)updateStatusBarStyleWithViewController:(UIViewController *)viewController
{
    if (viewController.barAlpha == 0)
    {
        if ([self colorBrigntness:viewController.view.backgroundColor] > 0.5)
        {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        } else
        {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        }
    } else
    {
        if ([self colorBrigntness:viewController.navBarBackgroundColor] > 0.5)
        {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
            
        } else
        {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        }
    }
}


- (CGFloat)colorBrigntness:(UIColor*)aColor
{
    CGFloat hue, saturation, brigntness, alpha;
    [aColor getHue:&hue saturation:&saturation brightness:&brigntness alpha:&alpha];
    return brigntness;
}


//- (UIColor *)getColorWithFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor percentComplete:(CGFloat)percentComplete
//{
//    CGFloat fromRed        = 0.0;
//    CGFloat fromGreen      = 0.0;
//    CGFloat fromBlue       = 0.0;
//    CGFloat fromColorAlpha = 0.0;
//    CGFloat toRed        = 0.0;
//    CGFloat toGreen      = 0.0;
//    CGFloat toBlue       = 0.0;
//    CGFloat toColorAlpha = 0.0;
//
//    [fromColor getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromColorAlpha];
//    [toColor getRed:&toRed green:&toGreen blue:&toBlue alpha:&toColorAlpha];
//
//    CGFloat newRed        = fromRed + (toRed - fromRed) * percentComplete;
//    CGFloat newGreen      = fromGreen + (toGreen - fromGreen) * percentComplete;
//    CGFloat newBlue       = fromBlue + (toBlue - fromBlue) * percentComplete;
//    CGFloat newColorAlpha = fromColorAlpha + (toColorAlpha - fromColorAlpha) * percentComplete;
//
//    return [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:newColorAlpha];
//}

@end
