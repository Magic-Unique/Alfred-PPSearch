//
//  PDHTTPSessionManager.m
//  PPDownloader
//
//  Created by Unique on 2019/2/1.
//  Copyright © 2019 Unique. All rights reserved.
//

#import "PDHTTPSessionManager.h"

static NSString *PPH_BASE_URL = @"https://jsondata.25pp.com/index.html?Tunnel-Command=";

@implementation PDHTTPSessionManager

+ (instancetype)sharedManager {
    static PDHTTPSessionManager *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[self alloc] init];
    });
    return _shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    }
    return self;
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;
    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
        disposition = NSURLSessionAuthChallengeUseCredential;
        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];//URLCredential(trust: challenge.protectionSpace.serverTrust!)
    } else {
        if (challenge.previousFailureCount > 0) {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        } else {
            credential = [self.session.configuration.URLCredentialStorage defaultCredentialForProtectionSpace:challenge.protectionSpace];
            
            if (credential != nil) {
                disposition = NSURLSessionAuthChallengeUseCredential;
            }
        }
    }
    completionHandler(disposition, credential);
}

- (id)search:(NSString *)query pageSize:(NSUInteger)pageSize pageIndex:(NSUInteger)pageIndex type:(PDIPAType)type {
    NSString *URL = [PPH_BASE_URL stringByAppendingString:type == PDIPATypeJailbreak ? @"4262469664" : @"4262469686"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:({
        NSData *data = nil;
        NSUInteger clFlag = ({
            NSUInteger clFlag = 0;
            switch (type) {
                case PDIPATypeAppStore:
                    clFlag = 3;
                    break;
                case PDIPATypeJailbreak:
                    clFlag = 1;
                    break;
                default:
                    break;
            }
            clFlag;
        });
        data = [NSJSONSerialization dataWithJSONObject:@{@"dcType":@(0),
                                                         @"keyword":query,
                                                         @"clFlag":@(clFlag),
                                                         @"perCount":@(pageSize),
                                                         @"page":@(pageIndex)}
                                               options:kNilOptions
                                                 error:nil];
        data;
    })];
    
    NSMutableArray *list = [NSMutableArray array];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSArray *contents = JSON[@"content"];
        [list addObjectsFromArray:[PDSearchModel mj_objectArrayWithKeyValuesArray:contents]];
        dispatch_semaphore_signal(semaphore);
    }];
    [task resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return list;
}

@end
