//
//  Mp3Encoder.hpp
//  AVEncodeTest
//
//  Created by ShanYuQin on 2020/3/5.
//  Copyright © 2020 ShanYuQin. All rights reserved.
//

#ifndef Mp3Encoder_hpp
#define Mp3Encoder_hpp

#include <stdio.h>
#include "lame.h"
class Mp3Encoder {
private:
    FILE * pcmFile;
    FILE * mp3File;
    lame_t lameClient;
public:
    Mp3Encoder();
    ~Mp3Encoder();
    int Init(const char * pcmFilePath,const char * mp3FilePath,int sampleRate, int channels,int bitRate);
    void Encode();
    void Destory();
};

#endif /* Mp3Encoder_hpp */
