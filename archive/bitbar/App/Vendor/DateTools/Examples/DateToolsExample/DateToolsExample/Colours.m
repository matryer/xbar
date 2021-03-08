// Copyright (C) 2013 by Benjamin Gordon
//
// Permission is hereby granted, free of charge, to any
// person obtaining a copy of this software and
// associated documentation files (the "Software"), to
// deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge,
// publish, distribute, sublicense, and/or sell copies of the
// Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall
// be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "Colours.h"

// Swizzle
#import <objc/runtime.h>

#pragma mark - Create correct iOS/OSX implementation

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
@implementation UIColor (Colours)

#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
@implementation NSColor (Colours)

#endif


#pragma mark - Color from Hex
+ (instancetype)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&rgbValue];
    
    return [[self class] colorWithR:((rgbValue & 0xFF0000) >> 16) G:((rgbValue & 0xFF00) >> 8) B:(rgbValue & 0xFF) A:1.0];
}


#pragma mark - Hex from Color
- (NSString *)hexString
{
    NSArray *colorArray	= [self rgbaArray];
    int r = [colorArray[0] floatValue] * 255;
    int g = [colorArray[1] floatValue] * 255;
    int b = [colorArray[2] floatValue] * 255;
    NSString *red = [NSString stringWithFormat:@"%02x", r];
    NSString *green = [NSString stringWithFormat:@"%02x", g];
    NSString *blue = [NSString stringWithFormat:@"%02x", b];
    
    return [NSString stringWithFormat:@"#%@%@%@", red, green, blue];
}


#pragma mark - Color from RGBA
+ (instancetype)colorFromRGBAArray:(NSArray *)rgbaArray
{
    if (rgbaArray.count < 4) {
        return [[self class] clearColor];
    }
    
    return [[self class] colorWithRed:[rgbaArray[0] floatValue]
                                green:[rgbaArray[1] floatValue]
                                 blue:[rgbaArray[2] floatValue]
                                alpha:[rgbaArray[3] floatValue]];
}

+ (instancetype)colorFromRGBADictionary:(NSDictionary *)rgbaDict
{
    if (rgbaDict[kColoursRGBA_R] && rgbaDict[kColoursRGBA_G] && rgbaDict[kColoursRGBA_B] && rgbaDict[kColoursRGBA_A]) {
        return [[self class] colorWithRed:[rgbaDict[kColoursRGBA_R] floatValue]
                                    green:[rgbaDict[kColoursRGBA_G] floatValue]
                                     blue:[rgbaDict[kColoursRGBA_B] floatValue]
                                    alpha:[rgbaDict[kColoursRGBA_A] floatValue]];
    }
    
    return [[self class] clearColor];
}


#pragma mark - RGBA from Color
- (NSArray *)rgbaArray
{
    CGFloat r=0,g=0,b=0,a=0;
    
    if ([self respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [self getRed:&r green:&g blue:&b alpha:&a];
    }
    else {
        const CGFloat *components = CGColorGetComponents(self.CGColor);
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }
    
    return @[@(r),
             @(g),
             @(b),
             @(a)];
}

- (NSDictionary *)rgbaDictionary
{
    CGFloat r=0,g=0,b=0,a=0;
    if ([self respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [self getRed:&r green:&g blue:&b alpha:&a];
    }
    else {
        const CGFloat *components = CGColorGetComponents(self.CGColor);
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }
    
    return @{kColoursRGBA_R:@(r),
             kColoursRGBA_G:@(g),
             kColoursRGBA_B:@(b),
             kColoursRGBA_A:@(a)};
}


#pragma mark - HSBA from Color
- (NSArray *)hsbaArray
{
    // Takes a [self class] and returns Hue,Saturation,Brightness,Alpha values in NSNumber form
    CGFloat h=0,s=0,b=0,a=0;
    
    if ([self respondsToSelector:@selector(getHue:saturation:brightness:alpha:)]) {
        [self getHue:&h saturation:&s brightness:&b alpha:&a];
    }
    
    return @[@(h),
             @(s),
             @(b),
             @(a)];
}

- (NSDictionary *)hsbaDictionary
{
    CGFloat h=0,s=0,b=0,a=0;
    
    if ([self respondsToSelector:@selector(getHue:saturation:brightness:alpha:)]) {
        [self getHue:&h saturation:&s brightness:&b alpha:&a];
    }
    
    return @{kColoursHSBA_H:@(h),
             kColoursHSBA_S:@(s),
             kColoursHSBA_B:@(b),
             kColoursHSBA_A:@(a)};
}


#pragma mark - Color from HSBA
+ (instancetype)colorFromHSBAArray:(NSArray *)hsbaArray
{
    if (hsbaArray.count < 4) {
        return [[self class] clearColor];
    }
    
    return [[self class] colorWithHue:[hsbaArray[0] doubleValue]
                           saturation:[hsbaArray[1] doubleValue]
                           brightness:[hsbaArray[2] doubleValue]
                                alpha:[hsbaArray[3] doubleValue]];
}

+ (instancetype)colorFromHSBADictionary:(NSDictionary *)hsbaDict
{
    if (hsbaDict[kColoursHSBA_H] && hsbaDict[kColoursHSBA_S] && hsbaDict[kColoursHSBA_B] && hsbaDict[kColoursHSBA_A]) {
        return [[self class] colorWithHue:[hsbaDict[kColoursHSBA_H] doubleValue]
                               saturation:[hsbaDict[kColoursHSBA_S] doubleValue]
                               brightness:[hsbaDict[kColoursHSBA_B] doubleValue]
                                    alpha:[hsbaDict[kColoursHSBA_A] doubleValue]];
    }
    
    return [[self class] clearColor];
}


#pragma mark - LAB from Color
- (NSArray *)CIE_LabArray {
    // Convert Color to XYZ format first
    NSArray *rgba = [self rgbaArray];
    CGFloat R = [rgba[0] floatValue];
    CGFloat G = [rgba[1] floatValue];
    CGFloat B = [rgba[2] floatValue];
    
    // Create deltaR block
    void (^deltaRGB)(CGFloat *R);
    deltaRGB = ^(CGFloat *R) {
        *R = (*R > 0.04045) ? pow((*R + 0.055)/1.055, 2.40) : (*R/12.92);
    };
    deltaRGB(&R);
    deltaRGB(&G);
    deltaRGB(&B);
    CGFloat X = R*41.24 + G*35.76 + B*18.05;
    CGFloat Y = R*21.26 + G*71.52 + B*7.22;
    CGFloat Z = R*1.93 + G*11.92 + B*95.05;
    
    // Convert XYZ to L*a*b*
    X = X/95.047;
    Y = Y/100.000;
    Z = Z/108.883;
    
    // Create deltaF block
    void (^deltaF)(CGFloat *f);
    deltaF = ^(CGFloat *f){
        *f = (*f > pow((6.0/29.0), 3.0)) ? pow(*f, 1.0/3.0) : (1/3)*pow((29.0/6.0), 2.0) * *f + 4/29.0;
    };
    deltaF(&X);
    deltaF(&Y);
    deltaF(&Z);
    NSNumber *L = @(116*Y - 16);
    NSNumber *a = @(500 * (X - Y));
    NSNumber *b = @(200 * (Y - Z));
    
    return @[L,
             a,
             b,
             rgba[3]];
}

- (NSDictionary *)CIE_LabDictionary {
    NSArray *colors = [self CIE_LabArray];
    return @{kColoursCIE_L:colors[0],
             kColoursCIE_A:colors[1],
             kColoursCIE_B:colors[2],
             kColoursCIE_alpha:colors[3],};
}


#pragma mark - Color from LAB
+ (instancetype)colorFromCIE_LabArray:(NSArray *)colors {
    if (!colors || colors.count < 4) {
        return [[self class] clearColor];
    }
    
    // Convert LAB to XYZ
    CGFloat L = [colors[0] floatValue];
    CGFloat A = [colors[1] floatValue];
    CGFloat B = [colors[2] floatValue];
    CGFloat Y = (L + 16.0)/116.0;
    CGFloat X = A/500 + Y;
    CGFloat Z = Y - B/200;
    
    void (^deltaXYZ)(CGFloat *);
    deltaXYZ = ^(CGFloat *k){
        *k = (pow(*k, 3.0) > 0.008856) ? pow(*k, 3.0) : (*k - 4/29.0)/7.787;
    };
    
    deltaXYZ(&X);
    deltaXYZ(&Y);
    deltaXYZ(&Z);
    X = X*.95047;
    Y = Y*1.00000;
    Z = Z*1.08883;
    
    // Convert XYZ to RGB
    CGFloat R = X*3.2406 + Y*-1.5372 + Z*-0.4986;
    CGFloat G = X*-0.9689 + Y*1.8758 + Z*0.0415;
    CGFloat _B = X*0.0557 + Y*-0.2040 + Z*1.0570;
    
    void (^deltaRGB)(CGFloat *);
    deltaRGB = ^(CGFloat *k){
        *k = (*k > 0.0031308) ? 1.055 * (pow(*k, (1/2.4))) - 0.055 : *k * 12.92;
    };
    
    deltaRGB(&R);
    deltaRGB(&G);
    deltaRGB(&_B);
    
    // return Color
    return [[self class] colorFromRGBAArray:@[@(R), @(G), @(_B), colors[3]]];
}

+ (instancetype)colorFromCIE_LabDictionary:(NSDictionary *)colors {
    if (!colors) {
        return [[self class] clearColor];
    }
    
    if (colors[kColoursCIE_L] && colors[kColoursCIE_A] && colors[kColoursCIE_B] && colors[kColoursCIE_alpha]) {
        return [self colorFromCIE_LabArray:@[colors[kColoursCIE_L],
                                             colors[kColoursCIE_A],
                                             colors[kColoursCIE_B],
                                             colors[kColoursCIE_alpha]]];
    }
    
    return [[self class] clearColor];
}


#pragma mark - Color to CMYK
- (NSArray *)cmykArray
{
    // Convert RGB to CMY
    NSArray *rgb = [self rgbaArray];
    CGFloat C = 1 - [rgb[0] floatValue];
    CGFloat M = 1 - [rgb[1] floatValue];
    CGFloat Y = 1 - [rgb[2] floatValue];
    
    // Find K
    CGFloat K = MIN(1, MIN(C, MIN(Y, M)));
    if (K == 1) {
        C = 0;
        M = 0;
        Y = 0;
    }
    else {
        void (^newCMYK)(CGFloat *);
        newCMYK = ^(CGFloat *x){
            *x = (*x - K)/(1 - K);
        };
        newCMYK(&C);
        newCMYK(&M);
        newCMYK(&Y);
    }
    
    return @[@(C),
             @(M),
             @(Y),
             @(K)];
}

- (NSDictionary *)cmykDictionary
{
    NSArray *colors = [self cmykArray];
    return @{kColoursCMYK_C:colors[0],
             kColoursCMYK_M:colors[1],
             kColoursCMYK_Y:colors[2],
             kColoursCMYK_K:colors[3]};
}

#pragma mark - CMYK to Color
+ (instancetype)colorFromCMYKArray:(NSArray *)cmyk
{
    if (!cmyk || cmyk.count < 4) {
        return [[self class] clearColor];
    }
    
    // Find CMY values
    CGFloat C = [cmyk[0] floatValue];
    CGFloat M = [cmyk[1] floatValue];
    CGFloat Y = [cmyk[2] floatValue];
    CGFloat K = [cmyk[3] floatValue];
    void (^cmyTransform)(CGFloat *);
    cmyTransform = ^(CGFloat *x){
        *x = *x * (1 - K) + K;
    };
    cmyTransform(&C);
    cmyTransform(&M);
    cmyTransform(&Y);
    
    // Translate CMY to RGB
    CGFloat R = 1 - C;
    CGFloat G = 1 - M;
    CGFloat B = 1 - Y;
    
    // return the Color
    return [[self class] colorFromRGBAArray:@[@(R),
                                              @(G),
                                              @(B),
                                              @(1)]];
}

+ (instancetype)colorFromCMYKDictionary:(NSDictionary *)cmyk
{
    if (!cmyk) {
        return [[self class] clearColor];
    }
    
    if (cmyk[kColoursCMYK_C] && cmyk[kColoursCMYK_M] && cmyk[kColoursCMYK_Y] && cmyk[kColoursCMYK_K]) {
        return [[self class] colorFromCMYKArray:@[cmyk[kColoursCMYK_C],
                                                  cmyk[kColoursCMYK_M],
                                                  cmyk[kColoursCMYK_Y],
                                                  cmyk[kColoursCMYK_K]]];
    }
    
    return [[self class] clearColor];
}


#pragma mark - Color Components
- (NSDictionary *)colorComponents
{
    NSMutableDictionary *components = [[self rgbaDictionary] mutableCopy];
    [components addEntriesFromDictionary:[self hsbaDictionary]];
    [components addEntriesFromDictionary:[self CIE_LabDictionary]];
    return components;
}

- (CGFloat)red
{
    return [[self rgbaArray][0] floatValue];
}

- (CGFloat)green
{
    return [[self rgbaArray][1] floatValue];
}

- (CGFloat)blue
{
    return [[self rgbaArray][2] floatValue];
}

- (CGFloat)hue
{
    return [[self hsbaArray][0] floatValue];
}

- (CGFloat)saturation
{
    return [[self hsbaArray][1] floatValue];
}

- (CGFloat)brightness
{
    return [[self hsbaArray][2] floatValue];
}

- (CGFloat)alpha
{
    return [[self rgbaArray][3] floatValue];
}

- (CGFloat)CIE_Lightness
{
    return [[self CIE_LabArray][0] floatValue];
}

- (CGFloat)CIE_a
{
    return [[self CIE_LabArray][1] floatValue];
}

- (CGFloat)CIE_b
{
    return [[self CIE_LabArray][2] floatValue];
}

- (CGFloat)cyan {
    return [[self cmykArray][0] floatValue];
}

- (CGFloat)magenta {
    return [[self cmykArray][1] floatValue];
}

- (CGFloat)yellow {
    return [[self cmykArray][2] floatValue];
}

- (CGFloat)keyBlack {
    return [[self cmykArray][3] floatValue];
}

#pragma mark - Generate Color Scheme
- (NSArray *)colorSchemeOfType:(ColorScheme)type
{
    NSArray *hsbArray = [self hsbaArray];
    float hue = [hsbArray[0] floatValue] * 360;
    float sat = [hsbArray[1] floatValue] * 100;
    float bright = [hsbArray[2] floatValue] * 100;
    float alpha = [hsbArray[3] floatValue];
    
    switch (type) {
        case ColorSchemeAnalagous:
            return [[self class] analagousColorsFromHue:hue saturation:sat brightness:bright alpha:alpha];
        case ColorSchemeMonochromatic:
            return [[self class] monochromaticColorsFromHue:hue saturation:sat brightness:bright alpha:alpha];
        case ColorSchemeTriad:
            return [[self class] triadColorsFromHue:hue saturation:sat brightness:bright alpha:alpha];
        case ColorSchemeComplementary:
            return [[self class] complementaryColorsFromHue:hue saturation:sat brightness:bright alpha:alpha];
        default:
            return nil;
    }
}


#pragma mark - Color Scheme Generation - Helper methods
+ (NSArray *)analagousColorsFromHue:(float)h saturation:(float)s brightness:(float)b alpha:(float)a
{
    return @[[[self class] colorWithHue:[[self class] addDegrees:30 toDegree:h]/360 saturation:(s-5)/100 brightness:(b-10)/100 alpha:a],
             [[self class] colorWithHue:[[self class] addDegrees:15 toDegree:h]/360 saturation:(s-5)/100 brightness:(b-5)/100 alpha:a],
             [[self class] colorWithHue:[[self class] addDegrees:-15 toDegree:h]/360 saturation:(s-5)/100 brightness:(b-5)/100 alpha:a],
             [[self class] colorWithHue:[[self class] addDegrees:-30 toDegree:h]/360 saturation:(s-5)/100 brightness:(b-10)/100 alpha:a]];
}

+ (NSArray *)monochromaticColorsFromHue:(float)h saturation:(float)s brightness:(float)b alpha:(float)a
{
    return @[[[self class] colorWithHue:h/360 saturation:(s/2)/100 brightness:(b/3)/100 alpha:a],
             [[self class] colorWithHue:h/360 saturation:s/100 brightness:(b/2)/100 alpha:a],
             [[self class] colorWithHue:h/360 saturation:(s/3)/100 brightness:(2*b/3)/100 alpha:a],
             [[self class] colorWithHue:h/360 saturation:s/100 brightness:(4*b/5)/100 alpha:a]];
}

+ (NSArray *)triadColorsFromHue:(float)h saturation:(float)s brightness:(float)b alpha:(float)a
{
    return @[[[self class] colorWithHue:[[self class] addDegrees:120 toDegree:h]/360 saturation:(7*s/6)/100 brightness:(b-5)/100 alpha:a],
             [[self class] colorWithHue:[[self class] addDegrees:120 toDegree:h]/360 saturation:s/100 brightness:b/100 alpha:a],
             [[self class] colorWithHue:[[self class] addDegrees:240 toDegree:h]/360 saturation:s/100 brightness:b/100 alpha:a],
             [[self class] colorWithHue:[[self class] addDegrees:240 toDegree:h]/360 saturation:(7*s/6)/100 brightness:(b-5)/100 alpha:a]];
}

+ (NSArray *)complementaryColorsFromHue:(float)h saturation:(float)s brightness:(float)b alpha:(float)a
{
    return @[[[self class] colorWithHue:h/360 saturation:s/100 brightness:(4*b/5)/100 alpha:a],
             [[self class] colorWithHue:h/360 saturation:(5*s/7)/100 brightness:b/100 alpha:a],
             [[self class] colorWithHue:[[self class] addDegrees:180 toDegree:h]/360 saturation:s/100 brightness:b/100 alpha:a],
             [[self class] colorWithHue:[[self class] addDegrees:180 toDegree:h]/360 saturation:(5*s/7)/100 brightness:b/100 alpha:a]];
}


#pragma mark - Contrasting Color
- (instancetype)blackOrWhiteContrastingColor
{
    NSArray *rgbaArray = [self rgbaArray];
    double a = 1 - ((0.299 * [rgbaArray[0] doubleValue]) + (0.587 * [rgbaArray[1] doubleValue]) + (0.114 * [rgbaArray[2] doubleValue]));
    return a < 0.5 ? [[self class] blackColor] : [[self class] whiteColor];
}


#pragma mark - Complementary Color
- (instancetype)complementaryColor
{
    NSMutableDictionary *hsba = [[self hsbaDictionary] mutableCopy];
    float newH = [[self class] addDegrees:180.0f toDegree:([hsba[kColoursHSBA_H] floatValue]*360)];
    [hsba setObject:@(newH) forKey:kColoursHSBA_H];
    return [[self class] colorFromHSBADictionary:hsba];
    
}


#pragma mark - Distance between Colors
- (CGFloat)distanceFromColor:(id)color
{
    // Defaults to CIE94
    return [self distanceFromColor:color type:ColorDistanceCIE94];
}

- (CGFloat)distanceFromColor:(id)color type:(ColorDistance)distanceType {
    /**
     *
     *  Detecting a difference in two colors is not as trivial as it sounds.
     *  One's first instinct is to go for a difference in RGB values, leaving
     *  you with a sum of the differences of each point. It looks great! Until
     *  you actually start comparing colors. Why do these two reds have a different
     *  distance than these two blues *in real life* vs computationally?
     *  Human visual perception is next in the line of things between a color
     *  and your brain. Some colors are just perceived to have larger variants inside
     *  of their respective areas than others, so we need a way to model this
     *  human variable to colors. Enter CIELAB. This color formulation is supposed to be
     *  this model. So now we need to standardize a unit of distance between any two
     *  colors that works independent of how humans visually perceive that distance.
     *  Enter CIE76,94,2000. These are methods that use user-tested data and other
     *  mathematically and statistically significant correlations to output this info.
     *  You can read the wiki articles below to get a better understanding historically
     *  of how we moved to newer and better color distance formulas, and what
     *  their respective pros/cons are.
     *
     *  References:
     *  
     *  http://en.wikipedia.org/wiki/Color_difference
     *  http://en.wikipedia.org/wiki/Just_noticeable_difference
     *  http://en.wikipedia.org/wiki/CIELAB
     *
     */
    
    // Check if it's a color
    if (![color isKindOfClass:[self class]]) {
        // NSLog(@"Not a %@ object.", NSStringFromClass([self class]));
        return MAXFLOAT;
    }
    
    // Set Up Common Variables
    NSArray *lab1 = [self CIE_LabArray];
    NSArray *lab2 = [color CIE_LabArray];
    CGFloat L1 = [lab1[0] floatValue];
    CGFloat A1 = [lab1[1] floatValue];
    CGFloat B1 = [lab1[2] floatValue];
    CGFloat L2 = [lab2[0] floatValue];
    CGFloat A2 = [lab2[1] floatValue];
    CGFloat B2 = [lab2[2] floatValue];
    
    // CIE76 first
    if (distanceType == ColorDistanceCIE76) {
        CGFloat distance = sqrtf(pow((L1-L2), 2) + pow((A1-A2), 2) + pow((B1-B2), 2));
        return distance;
    }
    
    // More Common Variables
    CGFloat kL = 1;
    CGFloat kC = 1;
    CGFloat kH = 1;
    CGFloat k1 = 0.045;
    CGFloat k2 = 0.015;
    CGFloat deltaL = L1 - L2;
    CGFloat C1 = sqrt((A1*A1) + (B1*B1));
    CGFloat C2 = sqrt((A2*A2) + (B2*B2));
    CGFloat deltaC = C1 - C2;
    CGFloat deltaH = sqrt(pow((A1-A2), 2.0) + pow((B1-B2), 2.0) - pow(deltaC, 2.0));
    CGFloat sL = 1;
    CGFloat sC = 1 + k1*(sqrt((A1*A1) + (B1*B1)));
    CGFloat sH = 1 + k2*(sqrt((A1*A1) + (B1*B1)));
    
    // CIE94
    if (distanceType == ColorDistanceCIE94) {
        return sqrt(pow((deltaL/(kL*sL)), 2.0) + pow((deltaC/(kC*sC)), 2.0) + pow((deltaH/(kH*sH)), 2.0));
    }
    
    // CIE2000
    // More variables
    CGFloat deltaLPrime = L2 - L1;
    CGFloat meanL = (L1 + L2)/2;
    CGFloat meanC = (C1 + C2)/2;
    CGFloat aPrime1 = A1 + A1/2*(1 - sqrt(pow(meanC, 7.0)/(pow(meanC, 7.0) + pow(25.0, 7.0))));
    CGFloat aPrime2 = A2 + A2/2*(1 - sqrt(pow(meanC, 7.0)/(pow(meanC, 7.0) + pow(25.0, 7.0))));
    CGFloat cPrime1 = sqrt((aPrime1*aPrime1) + (B1*B1));
    CGFloat cPrime2 = sqrt((aPrime2*aPrime2) + (B2*B2));
    CGFloat cMeanPrime = (cPrime1 + cPrime2)/2;
    CGFloat deltaCPrime = cPrime1 - cPrime2;
    CGFloat hPrime1 = atan2(B1, aPrime1);
    CGFloat hPrime2 = atan2(B2, aPrime2);
    hPrime1 = fmodf(hPrime1, [self radiansFromDegree:360]);
    hPrime2 = fmodf(hPrime2, [self radiansFromDegree:360]);
    CGFloat deltahPrime = 0;
    if (fabsf(hPrime1 - hPrime2) <= [self radiansFromDegree:180]) {
        deltahPrime = hPrime2 - hPrime1;
    }
    else {
        deltahPrime = (hPrime2 <= hPrime1) ? hPrime2 - hPrime1 + [self radiansFromDegree:360] : hPrime2 - hPrime1 - [self radiansFromDegree:360];
    }
    CGFloat deltaHPrime = 2 * sqrt(cPrime1*cPrime2) * sin(deltahPrime/2);
    CGFloat meanHPrime = (fabsf(hPrime1 - hPrime2) <= [self radiansFromDegree:180]) ? (hPrime1 + hPrime2)/2 : (hPrime1 + hPrime2 + [self radiansFromDegree:360])/2;
    CGFloat T = 1 - 0.17*cos(meanHPrime - [self radiansFromDegree:30]) + 0.24*cos(2*meanHPrime)+0.32*cos(3*meanHPrime + [self radiansFromDegree:6]) - 0.20*cos(4*meanHPrime - [self radiansFromDegree:63]);
    sL = 1 + (0.015 * pow((meanL - 50), 2))/sqrt(20 + pow((meanL - 50), 2));
    sC = 1 + 0.045*cMeanPrime;
    sH = 1 + 0.015*cMeanPrime*T;
    CGFloat Rt = -2 * sqrt(pow(cMeanPrime, 7)/(pow(cMeanPrime, 7) + pow(25.0, 7))) * sin([self radiansFromDegree:60]* exp(-1 * pow((meanHPrime - [self radiansFromDegree:275])/[self radiansFromDegree:25], 2)));
    
    // Finally return CIE2000 distance
    return sqrt(pow((deltaLPrime/(kL*sL)), 2) + pow((deltaCPrime/(kC*sC)), 2) + pow((deltaHPrime/(kH*sH)), 2) + Rt*(deltaC/(kC*sC))*(deltaHPrime/(kH*sH)));
}


#pragma mark - System Colors
+ (instancetype)infoBlueColor
{
	return [[self class] colorWithR:47 G:112 B:225 A:1.0];
}

+ (instancetype)successColor
{
	return [[self class] colorWithR:83 G:215 B:106 A:1.0];
}

+ (instancetype)warningColor
{
	return [[self class] colorWithR:221 G:170 B:59 A:1.0];
}

+ (instancetype)dangerColor
{
	return [[self class] colorWithR:229 G:0 B:15 A:1.0];
}


#pragma mark - Whites
+ (instancetype)antiqueWhiteColor
{
	return [[self class] colorWithR:250 G:235 B:215 A:1.0];
}

+ (instancetype)oldLaceColor
{
	return [[self class] colorWithR:253 G:245 B:230 A:1.0];
}

+ (instancetype)ivoryColor
{
	return [[self class] colorWithR:255 G:255 B:240 A:1.0];
}

+ (instancetype)seashellColor
{
	return [[self class] colorWithR:255 G:245 B:238 A:1.0];
}

+ (instancetype)ghostWhiteColor
{
	return [[self class] colorWithR:248 G:248 B:255 A:1.0];
}

+ (instancetype)snowColor
{
	return [[self class] colorWithR:255 G:250 B:250 A:1.0];
}

+ (instancetype)linenColor
{
	return [[self class] colorWithR:250 G:240 B:230 A:1.0];
}


#pragma mark - Grays
+ (instancetype)black25PercentColor
{
	return [[self class] colorWithWhite:0.25 alpha:1.0];
}

+ (instancetype)black50PercentColor
{
	return [[self class] colorWithWhite:0.5  alpha:1.0];
}

+ (instancetype)black75PercentColor
{
	return [[self class] colorWithWhite:0.75 alpha:1.0];
}

+ (instancetype)warmGrayColor
{
	return [[self class] colorWithR:133 G:117 B:112 A:1.0];
}

+ (instancetype)coolGrayColor
{
	return [[self class] colorWithR:118 G:122 B:133 A:1.0];
}

+ (instancetype)charcoalColor
{
	return [[self class] colorWithR:34 G:34 B:34 A:1.0];
}


#pragma mark - Blues
+ (instancetype)tealColor
{
	return [[self class] colorWithR:28 G:160 B:170 A:1.0];
}

+ (instancetype)steelBlueColor
{
	return [[self class] colorWithR:103 G:153 B:170 A:1.0];
}

+ (instancetype)robinEggColor
{
	return [[self class] colorWithR:141 G:218 B:247 A:1.0];
}

+ (instancetype)pastelBlueColor
{
	return [[self class] colorWithR:99 G:161 B:247 A:1.0];
}

+ (instancetype)turquoiseColor
{
	return [[self class] colorWithR:112 G:219 B:219 A:1.0];
}

+ (instancetype)skyBlueColor
{
	return [[self class] colorWithR:0 G:178 B:238 A:1.0];
}

+ (instancetype)indigoColor
{
	return [[self class] colorWithR:13 G:79 B:139 A:1.0];
}

+ (instancetype)denimColor
{
	return [[self class] colorWithR:67 G:114 B:170 A:1.0];
}

+ (instancetype)blueberryColor
{
	return [[self class] colorWithR:89 G:113 B:173 A:1.0];
}

+ (instancetype)cornflowerColor
{
	return [[self class] colorWithR:100 G:149 B:237 A:1.0];
}

+ (instancetype)babyBlueColor
{
	return [[self class] colorWithR:190 G:220 B:230 A:1.0];
}

+ (instancetype)midnightBlueColor
{
	return [[self class] colorWithR:13 G:26 B:35 A:1.0];
}

+ (instancetype)fadedBlueColor
{
	return [[self class] colorWithR:23 G:137 B:155 A:1.0];
}

+ (instancetype)icebergColor
{
	return [[self class] colorWithR:200 G:213 B:219 A:1.0];
}

+ (instancetype)waveColor
{
	return [[self class] colorWithR:102 G:169 B:251 A:1.0];
}


#pragma mark - Greens
+ (instancetype)emeraldColor
{
	return [[self class] colorWithR:1 G:152 B:117 A:1.0];
}

+ (instancetype)grassColor
{
	return [[self class] colorWithR:99 G:214 B:74 A:1.0];
}

+ (instancetype)pastelGreenColor
{
	return [[self class] colorWithR:126 G:242 B:124 A:1.0];
}

+ (instancetype)seafoamColor
{
	return [[self class] colorWithR:77 G:226 B:140 A:1.0];
}

+ (instancetype)paleGreenColor
{
	return [[self class] colorWithR:176 G:226 B:172 A:1.0];
}

+ (instancetype)cactusGreenColor
{
	return [[self class] colorWithR:99 G:111 B:87 A:1.0];
}

+ (instancetype)chartreuseColor
{
	return [[self class] colorWithR:69 G:139 B:0 A:1.0];
}

+ (instancetype)hollyGreenColor
{
	return [[self class] colorWithR:32 G:87 B:14 A:1.0];
}

+ (instancetype)oliveColor
{
	return [[self class] colorWithR:91 G:114 B:34 A:1.0];
}

+ (instancetype)oliveDrabColor
{
	return [[self class] colorWithR:107 G:142 B:35 A:1.0];
}

+ (instancetype)moneyGreenColor
{
	return [[self class] colorWithR:134 G:198 B:124 A:1.0];
}

+ (instancetype)honeydewColor
{
	return [[self class] colorWithR:216 G:255 B:231 A:1.0];
}

+ (instancetype)limeColor
{
	return [[self class] colorWithR:56 G:237 B:56 A:1.0];
}

+ (instancetype)cardTableColor
{
	return [[self class] colorWithR:87 G:121 B:107 A:1.0];
}


#pragma mark - Reds
+ (instancetype)salmonColor
{
	return [[self class] colorWithR:233 G:87 B:95 A:1.0];
}

+ (instancetype)brickRedColor
{
	return [[self class] colorWithR:151 G:27 B:16 A:1.0];
}

+ (instancetype)easterPinkColor
{
	return [[self class] colorWithR:241 G:167 B:162 A:1.0];
}

+ (instancetype)grapefruitColor
{
	return [[self class] colorWithR:228 G:31 B:54 A:1.0];
}

+ (instancetype)pinkColor
{
	return [[self class] colorWithR:255 G:95 B:154 A:1.0];
}

+ (instancetype)indianRedColor
{
	return [[self class] colorWithR:205 G:92 B:92 A:1.0];
}

+ (instancetype)strawberryColor
{
	return [[self class] colorWithR:190 G:38 B:37 A:1.0];
}

+ (instancetype)coralColor
{
	return [[self class] colorWithR:240 G:128 B:128 A:1.0];
}

+ (instancetype)maroonColor
{
	return [[self class] colorWithR:80 G:4 B:28 A:1.0];
}

+ (instancetype)watermelonColor
{
	return [[self class] colorWithR:242 G:71 B:63 A:1.0];
}

+ (instancetype)tomatoColor
{
	return [[self class] colorWithR:255 G:99 B:71 A:1.0];
}

+ (instancetype)pinkLipstickColor
{
	return [[self class] colorWithR:255 G:105 B:180 A:1.0];
}

+ (instancetype)paleRoseColor
{
	return [[self class] colorWithR:255 G:228 B:225 A:1.0];
}

+ (instancetype)crimsonColor
{
	return [[self class] colorWithR:187 G:18 B:36 A:1.0];
}


#pragma mark - Purples
+ (instancetype)eggplantColor
{
	return [[self class] colorWithR:105 G:5 B:98 A:1.0];
}

+ (instancetype)pastelPurpleColor
{
	return [[self class] colorWithR:207 G:100 B:235 A:1.0];
}

+ (instancetype)palePurpleColor
{
	return [[self class] colorWithR:229 G:180 B:235 A:1.0];
}

+ (instancetype)coolPurpleColor
{
	return [[self class] colorWithR:140 G:93 B:228 A:1.0];
}

+ (instancetype)violetColor
{
	return [[self class] colorWithR:191 G:95 B:255 A:1.0];
}

+ (instancetype)plumColor
{
	return [[self class] colorWithR:139 G:102 B:139 A:1.0];
}

+ (instancetype)lavenderColor
{
	return [[self class] colorWithR:204 G:153 B:204 A:1.0];
}

+ (instancetype)raspberryColor
{
	return [[self class] colorWithR:135 G:38 B:87 A:1.0];
}

+ (instancetype)fuschiaColor
{
	return [[self class] colorWithR:255 G:20 B:147 A:1.0];
}

+ (instancetype)grapeColor
{
	return [[self class] colorWithR:54 G:11 B:88 A:1.0];
}

+ (instancetype)periwinkleColor
{
	return [[self class] colorWithR:135 G:159 B:237 A:1.0];
}

+ (instancetype)orchidColor
{
	return [[self class] colorWithR:218 G:112 B:214 A:1.0];
}


#pragma mark - Yellows
+ (instancetype)goldenrodColor
{
	return [[self class] colorWithR:215 G:170 B:51 A:1.0];
}

+ (instancetype)yellowGreenColor
{
	return [[self class] colorWithR:192 G:242 B:39 A:1.0];
}

+ (instancetype)bananaColor
{
	return [[self class] colorWithR:229 G:227 B:58 A:1.0];
}

+ (instancetype)mustardColor
{
	return [[self class] colorWithR:205 G:171 B:45 A:1.0];
}

+ (instancetype)buttermilkColor
{
	return [[self class] colorWithR:254 G:241 B:181 A:1.0];
}

+ (instancetype)goldColor
{
	return [[self class] colorWithR:139 G:117 B:18 A:1.0];
}

+ (instancetype)creamColor
{
	return [[self class] colorWithR:240 G:226 B:187 A:1.0];
}

+ (instancetype)lightCreamColor
{
	return [[self class] colorWithR:240 G:238 B:215 A:1.0];
}

+ (instancetype)wheatColor
{
	return [[self class] colorWithR:240 G:238 B:215 A:1.0];
}

+ (instancetype)beigeColor
{
	return [[self class] colorWithR:245 G:245 B:220 A:1.0];
}


#pragma mark - Oranges
+ (instancetype)peachColor
{
	return [[self class] colorWithR:242 G:187 B:97 A:1.0];
}

+ (instancetype)burntOrangeColor
{
	return [[self class] colorWithR:184 G:102 B:37 A:1.0];
}

+ (instancetype)pastelOrangeColor
{
	return [[self class] colorWithR:248 G:197 B:143 A:1.0];
}

+ (instancetype)cantaloupeColor
{
	return [[self class] colorWithR:250 G:154 B:79 A:1.0];
}

+ (instancetype)carrotColor
{
	return [[self class] colorWithR:237 G:145 B:33 A:1.0];
}

+ (instancetype)mandarinColor
{
	return [[self class] colorWithR:247 G:145 B:55 A:1.0];
}


#pragma mark - Browns
+ (instancetype)chiliPowderColor
{
	return [[self class] colorWithR:199 G:63 B:23 A:1.0];
}

+ (instancetype)burntSiennaColor
{
	return [[self class] colorWithR:138 G:54 B:15 A:1.0];
}

+ (instancetype)chocolateColor
{
	return [[self class] colorWithR:94 G:38 B:5 A:1.0];
}

+ (instancetype)coffeeColor
{
	return [[self class] colorWithR:141 G:60 B:15 A:1.0];
}

+ (instancetype)cinnamonColor
{
	return [[self class] colorWithR:123 G:63 B:9 A:1.0];
}

+ (instancetype)almondColor
{
	return [[self class] colorWithR:196 G:142 B:72 A:1.0];
}

+ (instancetype)eggshellColor
{
	return [[self class] colorWithR:252 G:230 B:201 A:1.0];
}

+ (instancetype)sandColor
{
	return [[self class] colorWithR:222 G:182 B:151 A:1.0];
}

+ (instancetype)mudColor
{
	return [[self class] colorWithR:70 G:45 B:29 A:1.0];
}

+ (instancetype)siennaColor
{
	return [[self class] colorWithR:160 G:82 B:45 A:1.0];
}

+ (instancetype)dustColor
{
	return [[self class] colorWithR:236 G:214 B:197 A:1.0];
}


#pragma mark - Private


#pragma mark - RGBA Helper method
+ (instancetype)colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue A:(CGFloat)alpha
{
    return [[self class] colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}


#pragma mark - Degrees Helper method for Color Schemes
+ (float)addDegrees:(float)addDeg toDegree:(float)staticDeg
{
    staticDeg += addDeg;
    if (staticDeg > 360) {
        float offset = staticDeg - 360;
        return offset;
    }
    else if (staticDeg < 0) {
        return -1 * staticDeg;
    }
    else {
        return staticDeg;
    }
}

- (CGFloat)radiansFromDegree:(CGFloat)degree {
    return degree * M_PI/180;
}


#pragma mark - Swizzle


#pragma mark - On Load - Flip methods
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL rgbaSelector = @selector(getRed:green:blue:alpha:);
        SEL swizzledRGBASelector = @selector(colours_getRed:green:blue:alpha:);
        SEL hsbaSelector = @selector(getHue:saturation:brightness:alpha:);
        SEL swizzledHSBASelector = @selector(colours_getHue:saturation:brightness:alpha:);
        Method rgbaMethod = class_getInstanceMethod(class, rgbaSelector);
        Method swizzledRGBAMethod = class_getInstanceMethod(class, swizzledRGBASelector);
        Method hsbaMethod = class_getInstanceMethod(class, hsbaSelector);
        Method swizzledHSBAMethod = class_getInstanceMethod(class, swizzledHSBASelector);
        
        // Attempt adding the methods
        BOOL didAddRGBAMethod =
        class_addMethod(class,
                        rgbaSelector,
                        method_getImplementation(swizzledRGBAMethod),
                        method_getTypeEncoding(swizzledRGBAMethod));
        
        BOOL didAddHSBAMethod =
        class_addMethod(class,
                        hsbaSelector,
                        method_getImplementation(swizzledHSBAMethod),
                        method_getTypeEncoding(swizzledHSBAMethod));
        
        // Replace methods
        if (didAddRGBAMethod) {
            class_replaceMethod(class,
                                swizzledRGBASelector,
                                method_getImplementation(swizzledRGBAMethod),
                                method_getTypeEncoding(swizzledRGBAMethod));
        } else {
            method_exchangeImplementations(rgbaMethod, swizzledRGBAMethod);
        }
        
        if (didAddHSBAMethod) {
            class_replaceMethod(class,
                                swizzledHSBASelector,
                                method_getImplementation(swizzledHSBAMethod),
                                method_getTypeEncoding(swizzledHSBAMethod));
        } else {
            method_exchangeImplementations(hsbaMethod, swizzledHSBAMethod);
        }
    });
}


#pragma mark - Swizzled Methods
- (BOOL)colours_getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha
{
    if (CGColorGetNumberOfComponents(self.CGColor) == 4) {
        return [self colours_getRed:red green:green blue:blue alpha:alpha];
    }
    else if (CGColorGetNumberOfComponents(self.CGColor) == 2) {
        CGFloat white;
        CGFloat m_alpha;
        if ([self getWhite:&white alpha:&m_alpha]) {
            *red = white * 1.0;
            *green = white * 1.0;
            *blue = white * 1.0;
            *alpha = m_alpha;
            return YES;
        }
    }
    
    return NO;
}


- (BOOL)colours_getHue:(CGFloat *)hue saturation:(CGFloat *)saturation brightness:(CGFloat *)brightness alpha:(CGFloat *)alpha
{
    if (CGColorGetNumberOfComponents(self.CGColor) == 4) {
        return [self colours_getHue:hue saturation:saturation brightness:brightness alpha:alpha];
    }
    else if (CGColorGetNumberOfComponents(self.CGColor) == 2) {
        CGFloat white = 0;
        CGFloat a = 0;
        if ([self getWhite:&white alpha:&a]) {
            *hue = 0;
            *saturation = 0;
            *brightness = white * 1.0;
            *alpha = a * 1.0;
            
            return YES;
        }
    }
    
    return NO;
}


@end
