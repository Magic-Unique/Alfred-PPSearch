//
//  MUPath+Alfred.m
//  PPDownloader
//
//  Created by Unique on 2019/2/2.
//  Copyright © 2019 Unique. All rights reserved.
//

#import "MUPath+Alfred.h"

@implementation MUPath (Alfred)

+ (instancetype)rootPath {
    MUPath *rootPath = [MUPath pathWithString:@"~/.ppdownloader"];
    [rootPath createDirectoryWithCleanContents:NO];
    return rootPath;
}

+ (instancetype)iconPath {
    MUPath *iconPath = [[self rootPath] subpathWithComponent:@"icons"];
    [iconPath createDirectoryWithCleanContents:NO];
    return iconPath;
}

+ (instancetype)detailPath {
    MUPath *detailPath = [[self rootPath] subpathWithComponent:@"details"];
    [detailPath createDirectoryWithCleanContents:NO];
    return detailPath;
}

@end
