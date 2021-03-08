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

#include "TargetConditionals.h"
#include <Foundation/Foundation.h>


#pragma mark - Static String Keys
static NSString * kColoursRGBA_R = @"RGBA-r";
static NSString * kColoursRGBA_G = @"RGBA-g";
static NSString * kColoursRGBA_B = @"RGBA-b";
static NSString * kColoursRGBA_A = @"RGBA-a";
static NSString * kColoursHSBA_H = @"HSBA-h";
static NSString * kColoursHSBA_S = @"HSBA-s";
static NSString * kColoursHSBA_B = @"HSBA-b";
static NSString * kColoursHSBA_A = @"HSBA-a";
static NSString * kColoursCIE_L = @"LABa-L";
static NSString * kColoursCIE_A = @"LABa-A";
static NSString * kColoursCIE_B = @"LABa-B";
static NSString * kColoursCIE_alpha = @"LABa-a";
static NSString * kColoursCMYK_C = @"CMYK-c";
static NSString * kColoursCMYK_M = @"CMYK-m";
static NSString * kColoursCMYK_Y = @"CMYK-y";
static NSString * kColoursCMYK_K = @"CMYK-k";


#pragma mark - Create correct iOS/OSX interface

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
@interface UIColor (Colours)

#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
@interface NSColor (Colours)

#endif


#pragma mark - Enums
// Color Scheme Generation Enum
typedef NS_ENUM(NSInteger, ColorScheme) {
    ColorSchemeAnalagous,
    ColorSchemeMonochromatic,
    ColorSchemeTriad,
    ColorSchemeComplementary
};

// ColorFormulation Type
typedef NS_ENUM(NSInteger, ColorFormulation) {
    ColorFormulationRGBA,
    ColorFormulationHSBA,
    ColorFormulationLAB,
    ColorFormulationCMYK
};

// ColorDistance
typedef NS_ENUM(NSInteger, ColorDistance) {
    ColorDistanceCIE76,
    ColorDistanceCIE94,
    ColorDistanceCIE2000,
};


#pragma mark - Color from Hex/RGBA/HSBA/CIE_LAB/CMYK
/**
 Creates a Color from a Hex representation string
 @param hexString   Hex string that looks like @"#FF0000" or @"FF0000"
 @return    Color
 */
+ (instancetype)colorFromHexString:(NSString *)hexString;

/**
 Creates a Color from an array of 4 NSNumbers (r,g,b,a)
 @param rgbaArray   4 NSNumbers for rgba between 0 - 1
 @return    Color
 */
+ (instancetype)colorFromRGBAArray:(NSArray *)rgbaArray;

/**
 Creates a Color from a dictionary of 4 NSNumbers
 Keys: kColoursRGBA_R, kColoursRGBA_G, kColoursRGBA_B, kColoursRGBA_A
 @param rgbaDictionary   4 NSNumbers for rgba between 0 - 1
 @return    Color
 */
+ (instancetype)colorFromRGBADictionary:(NSDictionary *)rgbaDict;

/**
 Creates a Color from an array of 4 NSNumbers (h,s,b,a)
 @param hsbaArray   4 NSNumbers for rgba between 0 - 1
 @return    Color
 */
+ (instancetype)colorFromHSBAArray:(NSArray *)hsbaArray;

/**
 Creates a Color from a dictionary of 4 NSNumbers
 Keys: kColoursHSBA_H, kColoursHSBA_S, kColoursHSBA_B, kColoursHSBA_A
 @param hsbaDictionary   4 NSNumbers for rgba between 0 - 1
 @return    Color
 */
+ (instancetype)colorFromHSBADictionary:(NSDictionary *)hsbaDict;

/**
 Creates a Color from an array of 4 NSNumbers (L,a,b,alpha)
 @param colors   4 NSNumbers for CIE_LAB between 0 - 1
 @return Color
 */
+ (instancetype)colorFromCIE_LabArray:(NSArray *)colors;

/**
 Creates a Color from a dictionary of 4 NSNumbers
 Keys: kColoursCIE_L, kColoursCIE_A, kColoursCIE_B, kColoursCIE_alpha
 @param colors   4 NSNumbers for CIE_LAB between 0 - 1
 @return Color
 */
+ (instancetype)colorFromCIE_LabDictionary:(NSDictionary *)colors;

/**
 Creates a Color from an array of 4 NSNumbers (C,M,Y,K)
 @param colors   4 NSNumbers for CMYK between 0 - 1
 @return Color
 */
+ (instancetype)colorFromCMYKArray:(NSArray *)cmyk;

/**
 Creates a Color from a dictionary of 4 NSNumbers
 Keys: kColoursCMYK_C, kColoursCMYK_M, kColoursCMYK_Y, kColoursCMYK_K
 @param colors   4 NSNumbers for CMYK between 0 - 1
 @return Color
 */
+ (instancetype)colorFromCMYKDictionary:(NSDictionary *)cmyk;



#pragma mark - Hex/RGBA/HSBA/CIE_LAB/CMYK from Color
/**
 Creates a Hex representation from a Color
 @return    NSString
 */
- (NSString *)hexString;

/**
 Creates an array of 4 NSNumbers representing the float values of r, g, b, a in that order.
 @return    NSArray
 */
- (NSArray *)rgbaArray;

/**
 Creates an array of 4 NSNumbers representing the float values of h, s, b, a in that order.
 @return    NSArray
 */
- (NSArray *)hsbaArray;

/**
 Creates a dictionary of 4 NSNumbers representing float values with keys: kColoursRGBA_R, kColoursRGBA_G, kColoursRGBA_B, kColoursRGBA_A
 @return    NSDictionary
 */
- (NSDictionary *)rgbaDictionary;

/**
 Creates a dictionary of 4 NSNumbers representing float values with keys: kColoursHSBA_H, kColoursHSBA_S, kColoursHSBA_B, kColoursHSBA_A
 @return    NSDictionary
 */
- (NSDictionary *)hsbaDictionary;

/**
 *  Creates an array of 4 NSNumbers representing the float values of L*, a, b, alpha in that order.
 *
 *  @return NSArray
 */
- (NSArray *)CIE_LabArray;

/**
 *  Creates a dictionary of 4 NSNumbers representing the float values with keys: kColoursCIE_L, kColoursCIE_A, kColoursCIE_B, kColoursCIE_alpha
 *
 *  @return NSDictionary
 */
- (NSDictionary *)CIE_LabDictionary;

/**
 *  Creates an array of 4 NSNumbers representing the float values of C, M, Y, K in that order.
 *
 *  @return NSArray
 */
- (NSArray *)cmykArray;

/**
 *  Creates a dictionary of 4 NSNumbers representing the float values with keys: kColoursCMYK_C, kColoursCMYK_M, kColoursCMYK_Y, kColoursCMYK_K
 *
 *  @return NSDictionary
 */
- (NSDictionary *)cmykDictionary;


#pragma mark - Color Components
/**
 *  Creates an NSDictionary with RGBA and HSBA color components inside.
 *
 *  @return NSDictionary
 */
- (NSDictionary *)colorComponents;

/**
 *  Returns the red value from an RGBA formulation of the UIColor.
 *
 *  @return CGFloat
 */
- (CGFloat)red;

/**
 *  Returns the green value from an RGBA formulation of the UIColor.
 *
 *  @return CGFloat
 */
- (CGFloat)green;

/**
 *  Returns the blue value from an RGBA formulation of the UIColor.
 *
 *  @return CGFloat
 */
- (CGFloat)blue;

/**
 *  Returns the hue value from an HSBA formulation of the UIColor.
 *
 *  @return CGFloat
 */
- (CGFloat)hue;

/**
 *  Returns the saturation value from an HSBA formulation of the UIColor.
 *
 *  @return CGFloat
 */
- (CGFloat)saturation;

/**
 *  Returns the brightness value from an HSBA formulation of the UIColor.
 *
 *  @return CGFloat
 */
- (CGFloat)brightness;

/**
 *  Returns the alpha value from an RGBA formulation of the UIColor.
 *
 *  @return CGFloat
 */
- (CGFloat)alpha;

/**
 *  Returns the lightness value from a CIELAB formulation of the UIColor.
 *
 *  @return CGFloat
 */
- (CGFloat)CIE_Lightness;

/**
 *  Returns the a value from a CIELAB formulation of the UIColor.
 *
 *  @return CGFloat
 */
- (CGFloat)CIE_a;

/**
 *  Returns the b value from a CIELAB formulation of the UIColor.
 *
 *  @return CGFloat
 */
- (CGFloat)CIE_b;

/**
 *  Returns the cyan value from a CMYK formulation of the UIColor.
 *
 *  @return CGFloat
 */
- (CGFloat)cyan;

/**
 *  Returns the magenta value from a CMYK formulation of the UIColor.
 *
 *  @return CGFloat
 */
- (CGFloat)magenta;

/**
 *  Returns the yellow value from a CMYK formulation of the UIColor.
 *
 *  @return CGFloat
 */
- (CGFloat)yellow;

/**
 *  Returns the black (K) value from a CMYK formulation of the UIColor.
 *
 *  @return CGFloat
 */
- (CGFloat)keyBlack;


#pragma mark - 4 Color Scheme from Color
/**
 Creates an NSArray of 4 Colors that complement the Color.
 @param type ColorSchemeAnalagous, ColorSchemeMonochromatic, ColorSchemeTriad, ColorSchemeComplementary
 @return    NSArray
 */
- (NSArray *)colorSchemeOfType:(ColorScheme)type;


#pragma mark - Contrasting Color from Color
/**
 Creates either [Color whiteColor] or [Color blackColor] depending on if the color this method is run on is dark or light.
 @return    Color
 */
- (instancetype)blackOrWhiteContrastingColor;


#pragma mark - Complementary Color
/**
 Creates a complementary color - a color directly opposite it on the color wheel.
 @return    Color
 */
- (instancetype)complementaryColor;


#pragma mark - Distance between Colors
/**
 *  Returns a float of the distance between 2 colors. Defaults to the
 *  CIE94 specification found here: http://en.wikipedia.org/wiki/Color_difference
 *
 *  @param color Color to check self with.
 *
 *  @return CGFloat
 */
- (CGFloat)distanceFromColor:(id)color;

/**
 *  Returns a float of the distance between 2 colors, using one of
 *
 *
 *  @param color        Color to check against
 *  @param distanceType Formula to calculate with
 *
 *  @return CGFloat
 */
- (CGFloat)distanceFromColor:(id)color type:(ColorDistance)distanceType;


#pragma mark - Colors
// System Colors
+ (instancetype)infoBlueColor;
+ (instancetype)successColor;
+ (instancetype)warningColor;
+ (instancetype)dangerColor;

// Whites
+ (instancetype)antiqueWhiteColor;
+ (instancetype)oldLaceColor;
+ (instancetype)ivoryColor;
+ (instancetype)seashellColor;
+ (instancetype)ghostWhiteColor;
+ (instancetype)snowColor;
+ (instancetype)linenColor;

// Grays
+ (instancetype)black25PercentColor;
+ (instancetype)black50PercentColor;
+ (instancetype)black75PercentColor;
+ (instancetype)warmGrayColor;
+ (instancetype)coolGrayColor;
+ (instancetype)charcoalColor;

// Blues
+ (instancetype)tealColor;
+ (instancetype)steelBlueColor;
+ (instancetype)robinEggColor;
+ (instancetype)pastelBlueColor;
+ (instancetype)turquoiseColor;
+ (instancetype)skyBlueColor;
+ (instancetype)indigoColor;
+ (instancetype)denimColor;
+ (instancetype)blueberryColor;
+ (instancetype)cornflowerColor;
+ (instancetype)babyBlueColor;
+ (instancetype)midnightBlueColor;
+ (instancetype)fadedBlueColor;
+ (instancetype)icebergColor;
+ (instancetype)waveColor;

// Greens
+ (instancetype)emeraldColor;
+ (instancetype)grassColor;
+ (instancetype)pastelGreenColor;
+ (instancetype)seafoamColor;
+ (instancetype)paleGreenColor;
+ (instancetype)cactusGreenColor;
+ (instancetype)chartreuseColor;
+ (instancetype)hollyGreenColor;
+ (instancetype)oliveColor;
+ (instancetype)oliveDrabColor;
+ (instancetype)moneyGreenColor;
+ (instancetype)honeydewColor;
+ (instancetype)limeColor;
+ (instancetype)cardTableColor;

// Reds
+ (instancetype)salmonColor;
+ (instancetype)brickRedColor;
+ (instancetype)easterPinkColor;
+ (instancetype)grapefruitColor;
+ (instancetype)pinkColor;
+ (instancetype)indianRedColor;
+ (instancetype)strawberryColor;
+ (instancetype)coralColor;
+ (instancetype)maroonColor;
+ (instancetype)watermelonColor;
+ (instancetype)tomatoColor;
+ (instancetype)pinkLipstickColor;
+ (instancetype)paleRoseColor;
+ (instancetype)crimsonColor;

// Purples
+ (instancetype)eggplantColor;
+ (instancetype)pastelPurpleColor;
+ (instancetype)palePurpleColor;
+ (instancetype)coolPurpleColor;
+ (instancetype)violetColor;
+ (instancetype)plumColor;
+ (instancetype)lavenderColor;
+ (instancetype)raspberryColor;
+ (instancetype)fuschiaColor;
+ (instancetype)grapeColor;
+ (instancetype)periwinkleColor;
+ (instancetype)orchidColor;

// Yellows
+ (instancetype)goldenrodColor;
+ (instancetype)yellowGreenColor;
+ (instancetype)bananaColor;
+ (instancetype)mustardColor;
+ (instancetype)buttermilkColor;
+ (instancetype)goldColor;
+ (instancetype)creamColor;
+ (instancetype)lightCreamColor;
+ (instancetype)wheatColor;
+ (instancetype)beigeColor;

// Oranges
+ (instancetype)peachColor;
+ (instancetype)burntOrangeColor;
+ (instancetype)pastelOrangeColor;
+ (instancetype)cantaloupeColor;
+ (instancetype)carrotColor;
+ (instancetype)mandarinColor;

// Browns
+ (instancetype)chiliPowderColor;
+ (instancetype)burntSiennaColor;
+ (instancetype)chocolateColor;
+ (instancetype)coffeeColor;
+ (instancetype)cinnamonColor;
+ (instancetype)almondColor;
+ (instancetype)eggshellColor;
+ (instancetype)sandColor;
+ (instancetype)mudColor;
+ (instancetype)siennaColor;
+ (instancetype)dustColor;

@end
