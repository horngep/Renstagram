//
//  Helper.m
//  Renstagram
//
//  Created by Ivan Ruiz Monjo on 19/08/14.
//  Copyright (c) 2014 Rens Gang. All rights reserved.
//

#import "Helper.h"

@implementation Helper

+ (UIImage *)roundedRectImageFromImage:(UIImage *)image withRadious:(CGFloat)radious {

    if(radious == 0.0f)
        return image;

    if( image != nil) {

        CGFloat imageWidth = image.size.width;
        CGFloat imageHeight = image.size.height;

        CGRect rect = CGRectMake(0.0f, 0.0f, imageWidth, imageHeight);
        UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        const CGFloat scale = window.screen.scale;
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, scale);

        CGContextRef context = UIGraphicsGetCurrentContext();

        CGContextBeginPath(context);
        CGContextSaveGState(context);
        CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextScaleCTM (context, radious, radious);

        CGFloat rectWidth = CGRectGetWidth (rect)/radious;
        CGFloat rectHeight = CGRectGetHeight (rect)/radious;

        CGContextMoveToPoint(context, rectWidth, rectHeight/2.0f);
        CGContextAddArcToPoint(context, rectWidth, rectHeight, rectWidth/2.0f, rectHeight, radious);
        CGContextAddArcToPoint(context, 0.0f, rectHeight, 0.0f, rectHeight/2.0f, radious);
        CGContextAddArcToPoint(context, 0.0f, 0.0f, rectWidth/2.0f, 0.0f, radious);
        CGContextAddArcToPoint(context, rectWidth, 0.0f, rectWidth, rectHeight/2.0f, radious);
        CGContextRestoreGState(context);
        CGContextClosePath(context);
        CGContextClip(context);

        [image drawInRect:CGRectMake(0.0f, 0.0f, imageWidth, imageHeight)];

        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
    
    return nil;
}



@end