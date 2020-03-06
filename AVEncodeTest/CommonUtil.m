//
//  CommonUtil.m
//  AVEncodeTest
//
//  Created by ShanYuQin on 2020/3/5.
//  Copyright © 2020 ShanYuQin. All rights reserved.
//

#import "CommonUtil.h"

@implementation CommonUtil


+(NSString *)bundlePath:(NSString *)fileName {
    return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:fileName];
}

+(NSString *)documentsPath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

@end
