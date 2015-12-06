//
//  Constant.h
//  MagicMirror2
//
//  Created by sys on 15/12/2.
//  Copyright © 2015年 sys. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

#import <UIKit/UIKit.h>

#define SCREEN_WIDTH    CGRectGetWidth([UIApplication sharedApplication].keyWindow.bounds)
#define SCREEN_HEIGHT   CGRectGetHeight([UIApplication sharedApplication].keyWindow.bounds)
#define SCREEN_SCALE    [[UIScreen mainScreen] scale]

static NSString * const BaseURL         = @"http://www.tuling123.com/openapi/api?";

#endif /* Constant_h */
