//
//  AlfredKit.m
//  AlfredKit
//
//  Created by Magic-Unique on 2019/2/5.
//  Copyright (c) 2019 Magic-Unique. All rights reserved.
//

#import "AlfredKit.h"

@implementation AKItem

+ (instancetype)item {
    return [[self alloc] init];
}

+ (instancetype)itemWithCreator:(AKItemCreator)creator {
    AKItem *item = [[AKItem alloc] init];
    !creator?:creator(item);
    return item;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _valied = YES;
    }
    return self;
}

- (NSString *)xmlContent {
    NSMutableString *body = [[NSMutableString alloc] init];
    [body appendFormat:@"<item valid=\"%@\">\n", self.valied?@"yes":@"no"];
    
    if (self.title) {
        [body appendFormat:@"<title>%@</title>\n", self.title];
    }
    
    if (self.subtitle) {
        [body appendFormat:@"<subtitle>%@</subtitle>\n", self.subtitle];
    }
    
    if (self.arg) {
        [body appendFormat:@"<arg>%@</arg>\n", self.arg];
    }
    
    if (self.icon) {
        [body appendFormat:@"<icon>%@</icon>\n", self.icon];
    }
    
    [body appendString:@"</item>"];
    return [body copy];
}


@end

@interface AKList ()

@property (nonatomic, strong, readonly) NSMutableArray *mItems;

@end

@implementation AKList

- (void)addItems:(NSArray *)items {
    NSParameterAssert(items);
    if (items.count) {
        [self.mItems addObjectsFromArray:items];
    }
}

- (void)addItemWithCreator:(AKItemCreator)creator {
    NSParameterAssert(creator);
    [self addItem:[AKItem itemWithCreator:creator]];
}

- (void)addItem:(AKItem *)item {
    NSParameterAssert(item);
    [self.mItems addObject:item];
}

- (NSString *)xmlContent {
    NSMutableString *body = [NSMutableString string];
    [body appendString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"];
    [body appendString:@"<items>\n"];
    for (NSUInteger i = 0; i < self.mItems.count; i++) {
        AKItem *model = self.mItems[i];
        [body appendFormat:@"%@\n", [model xmlContent]];
    }
    [body appendString:@"</items>"];
    return [body copy];
}

- (void)show {
    NSString *body = [self xmlContent];
    printf("%s\n", body.UTF8String);
}

@synthesize mItems = _mItems;
- (NSMutableArray *)mItems {
    if (!_mItems) {
        _mItems = [[NSMutableArray alloc] init];
    }
    return _mItems;
}

@end
