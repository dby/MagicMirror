//
//  TalkRequest.m
//  MagicMirror2
//
//  Created by sys on 15/12/6.
//  Copyright © 2015年 sys. All rights reserved.
//
#import "TalkRequest.h"

@interface TalkRequest()
@property (nonatomic) NSString* info;
@end

@implementation TalkRequest

- (instancetype)initWithInfo:(NSString *)info {
    self = [super init];
    if (self) {
        _info = info;
    }
    return self;
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodGet;
}

- (id)requestArgument {
    return @{@"info": _info,
             @"key":@"d9b2ae153545861f5e3a1743c5d1927e"};
}

@end