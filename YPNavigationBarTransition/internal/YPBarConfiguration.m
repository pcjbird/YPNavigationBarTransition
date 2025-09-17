/*
MIT License

Copyright (c) 2017 yiplee

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#import "YPBarConfiguration.h"

@implementation YPBarConfiguration

- (instancetype) init {
    return [self initWithBarConfigurations:YPNavigationBarConfigurationsDefault
                                 tintColor:nil
                           backgroundColor:nil
                           backgroundImage:nil
                 backgroundImageIdentifier:nil];
}

- (instancetype) initWithBarConfigurations:(YPNavigationBarConfigurations)configurations
                                 tintColor:(UIColor *)tintColor
                           backgroundColor:(UIColor *)backgroundColor
                           backgroundImage:(UIImage *)backgroundImage
                 backgroundImageIdentifier:(NSString *)backgroundImageIdentifier {
    self = [super init];
    if (!self) return nil;
    
    do {
        _hidden = (configurations & YPNavigationBarHidden) > 0;
        
        _barStyle = (configurations & YPNavigationBarStyleBlack) > 0 ? UIBarStyleBlack : UIBarStyleDefault;
        if (!tintColor) {
            tintColor = _barStyle == UIBarStyleBlack ? [UIColor whiteColor] : [UIColor blackColor];
        }
        _tintColor = tintColor;
        
        if (_hidden) break;
        
        _transparent = (configurations & YPNavigationBarBackgroundStyleTransparent) > 0;
        if (_transparent) break;
        
        // show shadow image only if not transparent
        _shadowImage = (configurations & YPNavigationBarShowShadowImage) > 0;
        _translucent = (configurations & YPNavigationBarBackgroundStyleOpaque) == 0;
        
        if ((configurations & YPNavigationBarBackgroundStyleImage) > 0 && backgroundImage) {
            _backgroundImage = backgroundImage;
            _backgroundImageIdentifier = [backgroundImageIdentifier copy];
        } else if (configurations & YPNavigationBarBackgroundStyleColor){
            _backgroundColor = backgroundColor;
        }
    } while (0);
    
    return self;
}

- (NSString*)description {
    NSMutableString *desc = [NSMutableString string];
    [desc appendFormat:@"<%@: %p", NSStringFromClass([self class]), self];
    [desc appendFormat:@", hidden: %@", self.hidden ? @"YES" : @"NO"];
    NSString* barStyleDescription = @"Unknown";
    switch (self.barStyle) {
        case UIBarStyleDefault:
            barStyleDescription = @"Default";
            break;
        case UIBarStyleBlack:
            barStyleDescription = @"Black";
            break;
        case UIBarStyleBlackOpaque:
            barStyleDescription = @"BlackOpaque";
            break;
        case UIBarStyleBlackTranslucent:
            barStyleDescription = @"BlackTranslucent";
            break;
        default:
            barStyleDescription = @"Unknown";
            break;
    }
    [desc appendFormat:@", barStyle: %@ (%@)", @(self.barStyle), barStyleDescription];
    [desc appendFormat:@", translucent: %@", self.translucent ? @"YES" : @"NO"];
    [desc appendFormat:@", transparent: %@", self.transparent ? @"YES" : @"NO"];
    [desc appendFormat:@", shadowImage: %@", self.shadowImage ? @"YES" : @"NO"];
    [desc appendFormat:@", tintColor: %@", self.tintColor];
    if (self.backgroundColor) {
        [desc appendFormat:@", backgroundColor: %@", self.backgroundColor];
    }
    if (self.backgroundImage) {
        [desc appendFormat:@", backgroundImage: %@", self.backgroundImage];
        if (self.backgroundImageIdentifier) {
            [desc appendFormat:@"(identifier: %@)", self.backgroundImageIdentifier];
        }
    }
    [desc appendString:@">"];
    return desc;
}

@end

@implementation YPBarConfiguration (YPBarTransition)

- (instancetype) initWithBarConfigurationOwner:(id<YPNavigationBarConfigureStyle>)owner {
    YPNavigationBarConfigurations configurations = [owner yp_navigtionBarConfiguration];
    UIColor *tintColor = [owner yp_navigationBarTintColor];
    
    UIImage *backgroundImage  = nil;
    NSString *imageIdentifier = nil;
    UIColor *backgroundColor = nil;
    
    if (!(configurations & YPNavigationBarBackgroundStyleTransparent)) {
        if (configurations & YPNavigationBarBackgroundStyleImage) {
            backgroundImage = [owner yp_navigationBackgroundImageWithIdentifier:&imageIdentifier];
        } else if (configurations & YPNavigationBarBackgroundStyleColor) {
            backgroundColor = [owner yp_navigationBackgroundColor];
        }
    }
    
    return [self initWithBarConfigurations:configurations
                                 tintColor:tintColor
                           backgroundColor:backgroundColor
                           backgroundImage:backgroundImage
                 backgroundImageIdentifier:imageIdentifier];
}

- (BOOL) isVisible {
    return !self.hidden && !self.transparent;
}

- (BOOL) useSystemBarBackground {
    return !self.backgroundColor && !self.backgroundImage;
}

@end
