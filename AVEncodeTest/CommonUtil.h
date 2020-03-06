//
//  CommonUtil.h
//  AVEncodeTest
//
//  Created by ShanYuQin on 2020/3/5.
//  Copyright © 2020 ShanYuQin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommonUtil : NSObject

+(NSString *)bundlePath:(NSString *)fileName;

+(NSString *)documentsPath:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
