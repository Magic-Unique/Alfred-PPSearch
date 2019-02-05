//
//  main.m
//  PPDownloader
//
//  Created by Unique on 2019/2/1.
//  Copyright © 2019 Unique. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [[CLLanguage ChineseLanguage] apply];
        [CLCommand setVersion:@"1.0.0"];
        [CLCommand main].explain = @"PPHelper downloader scrpt for Alfred.";
        // __init_ is not valied in Alfred.app's workflow scrpit, is only for Terminal.app
//        [CLCommand defineCommandsForClass:@"CLCommand" metaSelectorPrefix:@"__init_"];
        [CLCommand defineCommandsForClass:@"CLCommand" metaSelectorPrefix:@"__alfred_"];
        CLCommandMain();
    }
    return 0;
}
