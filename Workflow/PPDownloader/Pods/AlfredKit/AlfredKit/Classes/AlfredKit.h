//
//  AlfredKit.h
//  AlfredKit
//
//  Created by Magic-Unique on 2019/2/5.
//  Copyright (c) 2019 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKItem, AKList;

typedef void(^AKItemCreator)(AKItem *item);

@interface AKItem : NSObject

@property (nonatomic, assign) BOOL valied;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, copy) NSString *arg;

@property (nonatomic, copy) NSString *icon;

+ (instancetype)item;
+ (instancetype)itemWithCreator:(AKItemCreator)creator;

@end

@interface AKList : NSObject

@property (nonatomic, copy, readonly) NSArray<AKItem *> *items;

- (void)addItem:(AKItem *)item;
- (void)addItemWithCreator:(AKItemCreator)creator;
- (void)addItems:(NSArray *)items;

- (void)show;

@end
