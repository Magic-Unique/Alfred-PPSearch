//
//  CLCommand+Alfred.m
//  PPDownloader
//
//  Created by Unique on 2019/2/2.
//  Copyright © 2019 Unique. All rights reserved.
//

#import "CLCommand+Alfred.h"
#import <AppKit/AppKit.h>
#import <AlfredKit/AlfredKit.h>

@implementation CLCommand (Alfred)

+ (instancetype)alfred {
    CLCommand *alfred = [[self main] defineSubcommand:@"alfred"];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alfred.explain = @"Alfred 命令列表";
    });
    return alfred;
}

+ (void)__alfred_search {
    CLCommand *search = [[self alfred] defineSubcommand:@"search"];
    search.explain = @"搜索";
    search.setQuery(@"query").setAbbr('q').setExplain(@"搜索关键字");
    search.setFlag(@"appstore").setAbbr('a').setExplain(@"搜索正版结果");
    search.setFlag(@"jailbreak").setAbbr('j').setExplain(@"搜索越狱版结果，可不传");
    search.setFlag(@"detail").setAbbr('d').setExplain(@"只显示第一条数据，并显示详情");
    [search onHandlerRequest:^CLResponse *(CLCommand *command, CLRequest *request) {
        NSString *query = [request stringForQuery:@"query"];;
        PDIPAType type = ({
            PDIPAType type = PDIPATypeJailbreak;
            BOOL jailbreak = [request flag:@"jailbreak"];
            BOOL appstore = [request flag:@"appstore"];
            if (!jailbreak && appstore) {
                type = PDIPATypeAppStore;
            }
            type;
        });
        
        NSArray *results = [[PDHTTPSessionManager sharedManager] search:query
                                                               pageSize:9
                                                              pageIndex:0
                                                                   type:type];
        
        MUPath *iconRoot = [MUPath iconPath];
        
        AKList *result = [[AKList alloc] init];
        
        if ([request flag:@"detail"]) {
            PDSearchModel *model = results.firstObject;
            
            MUPath *icon = [iconRoot subpathWithComponent:model.thumb.lastPathComponent];
            if (icon.isFile == NO) {
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.thumb]];
                [data writeToFile:icon.string atomically:YES];
            }
            
            NSMutableArray *list = [NSMutableArray array];
            [list addObject:@{@"title":@"名称", @"value": model.title, @"icon":icon.string}];
            [list addObject:@{@"title":@"包名", @"value": model.buid}];
            [list addObject:@{@"title":@"版本", @"value": model.version}];
            [list addObject:@{@"title":@"大小", @"value": model.fsize}];
            [list addObject:@{@"title":@"下载", @"value": [NSString stringWithFormat:@"%@ 次", @(model.downloads)]}];
            [list addObject:@{@"title":@"点赞", @"value": [NSString stringWithFormat:@"%@ 次", @(model.stars)]}];
            [list addObject:@{@"title":@"更新", @"value": ({
                NSDateFormatter *formatter = [NSDateFormatter new];
                formatter.dateFormat = @"yyyy年MM月dd日";
                [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:model.updatetime]];
            })}];
            [list addObject:@{@"title":@"地址", @"value": model.downurl}];
            [list addObject:@{@"title":@"描述", @"value": model.desc}];
            
            
            for (NSDictionary *_item in list) {
                [result addItemWithCreator:^(AKItem *item) {
//                    item.title = [NSString stringWithFormat:@"【%@】 %@", _item[@"title"], _item[@"value"]];
                    item.title = _item[@"value"];
                    item.subtitle = _item[@"title"];
                    
                    item.icon = _item[@"icon"] ?: @"empty.png";
                    
                }];
            }
        } else {
            for (NSUInteger i = 0; i < results.count; i++) {
                PDSearchModel *model = results[i];
                
                // Download icon
                MUPath *icon = [iconRoot subpathWithComponent:model.thumb.lastPathComponent];
                if (icon.isFile == NO) {
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.thumb]];
                    [data writeToFile:icon.string atomically:YES];
                }
                
                [result addItemWithCreator:^(AKItem *item) {
                    item.title = ({
                        NSString *title = nil;
                        NSString *name = [model.title componentsSeparatedByString:@"-"].firstObject;
                        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        title = [NSString stringWithFormat:@"%@ %@ - %@", name, model.version, model.buid];
                        title;
                    });
                    item.subtitle = model.desc;
                    item.arg = [model mj_JSONString];
                    item.icon = icon.string;
                }];
            }
        }
        
        [result show];
        return nil;
    }];
}

+ (void)__alfred_get {
    CLCommand *get = [[CLCommand alfred] defineSubcommand:@"get"];
    get.explain = @"取输入项目的 ipa 下载地址";
    get.setQuery(@"input").setAbbr('i').setExplain(@"搜索结果的 JSON 字符串");
    get.setQuery(@"key").setAbbr('k').setExplain(@"要取得信息的 key");
    [get onHandlerRequest:^CLResponse *(CLCommand *command, CLRequest *request) {
        NSString *JSONString = [request stringForQuery:@"input"];
        NSString *key = [request stringForQuery:@"key"];
        NSData *data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSString *value = JSON[key];
        printf("%s", value.UTF8String);
        return nil;
    }];
}

+ (void)__alfred_detail {
    // alfred.detail is not valied.
    CLCommand *detail = [[CLCommand alfred] defineSubcommand:@"detail"];
    detail.explain = @"显示详情";
    detail.setQuery(@"input").setAbbr('i').setExplain(@"搜索结果的 JSON 字符串");
    [detail onHandlerRequest:^CLResponse *(CLCommand *command, CLRequest *request) {
        NSString *JSONString = [request stringForQuery:@"input"];
        NSData *data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        PDSearchModel *model = [PDSearchModel mj_objectWithKeyValues:JSON];
        if (model) {
            NSMutableString *string = [NSMutableString new];
            [string appendFormat:@"应用名称：%@\n", model.title];
            [string appendFormat:@"应用包名：%@\n", model.buid];
            [string appendFormat:@"当前版本：%@\n", model.version];
            [string appendFormat:@"文件大小：%@\n", model.fsize];
            [string appendFormat:@"下载次数：%@\n", @(model.downloads)];
            [string appendFormat:@"下载地址：%@\n", model.downurl];
            CLPrintf(@"%@", string);
        }
        return nil;
    }];
}

+ (void)__alfred_extra {
    CLCommand *extra = [[CLCommand alfred] defineSubcommand:@"extra"];
    extra.explain = @"附加命令";
    [extra onHandlerRequest:^CLResponse *(CLCommand *command, CLRequest *request) {
        MUPath *root = [MUPath rootPath];
        AKList *result = [AKList new];
        [result addItemWithCreator:^(AKItem *item) {
            item.title = [NSString stringWithFormat:@"PP助手 - 清除缓存(%.2fKB)", root.attributes.fileSize/1024.0];
            item.subtitle = @"将会清除所有缓存文件(~/ppdownloader)，包括搜索到的应用图标文件";
            item.arg = @"clean-all";
            item.icon = @"pp_icon.png";
        }];
        [result addItemWithCreator:^(AKItem *item) {
            MUPath *icons = [MUPath iconPath];
            item.title = [NSString stringWithFormat:@"PP助手 - 清除图标(%@ 个, %.2fKB)", @(icons.files.count), icons.attributes.fileSize/1024.0];
            item.subtitle = @"将会清除所有搜索到的应用图标文件(~/ppdownloader/icons)";
            item.arg = @"clean-icons";
            item.icon = @"pp_icon.png";
        }];
        [result show];
        return nil;
    }];
    
    CLCommand *cleanAll = [extra defineSubcommand:@"clean-all"];
    [cleanAll onHandlerRequest:^CLResponse *(CLCommand *command, CLRequest *request) {
        [[MUPath rootPath] remove];
        printf("已清除所有缓存");
        return nil;
    }];
    
    CLCommand *cleanIcons = [extra defineSubcommand:@"clean-icons"];
    [cleanIcons onHandlerRequest:^CLResponse *(CLCommand *command, CLRequest *request) {
        [[MUPath iconPath] remove];
        printf("已清除所有图标");
        return nil;
    }];
}

@end
