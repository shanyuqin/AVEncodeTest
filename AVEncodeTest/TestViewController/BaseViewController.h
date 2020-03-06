//
//  BaseViewController.h
//  AVEncodeTest
//
//  Created by ShanYuQin on 2020/3/6.
//  Copyright © 2020 ShanYuQin. All rights reserved.
//

#import <UIKit/UIKit.h>


//y第一种引用方式
//#import <libavformat/avformat.h>

//第二种引用方式
/**
 extern "C" {};
 作用：
 为了在C++代码中调用用C写成的库文件，就需要用extern"C"来告诉编译器:这是一个用C写成的库文件，请用C的方式来链接它们。
 原因：
  C++支持函数重载，而C是不支持函数重载的，两者语言的编译规则不一样。编译器对函数名的处理方法也不一样。
 关键字：extern "C" 表示编译生成的内部符号名使用C约定。
 */

#ifdef __cplusplus
extern "C" {
#endif
    
#include "libavformat/avformat.h"
#include "libavutil/frame.h"
#include "libavutil/samplefmt.h"
#include "libswscale/swscale.h"
#include "libswresample/swresample.h"
#include "libavutil/pixdesc.h"
#include "libavfilter/avfilter.h"



#ifdef __cplusplus
};
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
