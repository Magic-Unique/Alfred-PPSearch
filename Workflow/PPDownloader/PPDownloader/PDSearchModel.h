//
//  PDSearchModel.h
//  PPDownloader
//
//  Created by Unique on 2019/2/1.
//  Copyright © 2019 Unique. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDSearchModel : NSObject

@property (nonatomic, assign, readonly) NSUInteger id;

@property (nonatomic, copy, readonly) NSString *thumb;

@property (nonatomic, copy, readonly) NSString *version;

/**
 Build identifier
 */
@property (nonatomic, copy, readonly) NSString *buid;

@property (nonatomic, assign, readonly) NSUInteger resType;

@property (nonatomic, copy, readonly) NSString *fsize;

@property (nonatomic, assign, readonly) NSUInteger downloads;

@property (nonatomic, copy, readonly) NSString *desc;

@property (nonatomic, copy, readonly) NSString *title;

@property (nonatomic, assign, readonly) double price;

@property (nonatomic, copy, readonly) NSString *downurl;

@property (nonatomic, assign, readonly) NSUInteger stars;

@property (nonatomic, assign, readonly) NSTimeInterval updatetime;

@property (nonatomic, assign, readonly) NSUInteger package;

@property (nonatomic, assign, readonly) NSUInteger dcType;

@property (nonatomic, assign, readonly) NSUInteger itemId;

@end
