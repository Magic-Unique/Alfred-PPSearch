//
//  PDHTTPSessionManager.h
//  PPDownloader
//
//  Created by Unique on 2019/2/1.
//  Copyright © 2019 Unique. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDHTTPSessionManager : NSObject <NSURLSessionDelegate>

@property (nonatomic, strong, readonly) NSURLSession *session;

+ (instancetype)sharedManager;

- (id)search:(NSString *)query pageSize:(NSUInteger)pageSize pageIndex:(NSUInteger)pageIndex type:(PDIPAType)type;

@end
