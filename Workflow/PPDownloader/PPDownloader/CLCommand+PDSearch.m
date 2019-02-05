//
//  CLCommand+PDSearch.m
//  PPDownloader
//
//  Created by Unique on 2019/2/1.
//  Copyright © 2019 Unique. All rights reserved.
//

#import "CLCommand+PDSearch.h"
//#import "PDSearchModel.h"

@implementation CLCommand (PDSearch)

+ (void)__init_search {
    // `search` commmand is not valied in Alfred workflow.
    CLCommand *search = [[self main] defineSubcommand:@"search"];
    search.explain = @"搜索 ipa 信息";
    search.addRequirePath(@"Query").setExplain(@"搜索关键字");
    search.setQuery(@"page-size").optional().setDefaultValue(@"10").setExplain(@"每个页面显示几个结果，默认 10");
    search.setQuery(@"page-index").optional().setDefaultValue(@"0").setExplain(@"显示第几个页面（从 0 开始），默认 0");
    search.setFlag(@"appstore").setAbbr('a').setExplain(@"搜索正版结果");
    search.setFlag(@"jailbreak").setAbbr('j').setExplain(@"搜索越狱版结果，可不传");
    [search onHandlerRequest:^CLResponse *(CLCommand *command, CLRequest *request) {
        NSString *query = request.paths.firstObject;
        NSInteger pageSize = [request stringForQuery:@"page-size"].integerValue;
        pageSize = pageSize > 0 ? pageSize : 10;
        NSInteger pageIndex = [request stringForQuery:@"page-index"].integerValue;
        pageIndex = pageIndex >= 0 ? pageIndex : 0;
        PDIPAType type = ({
            PDIPAType type = PDIPATypeJailbreak;
            BOOL jailbreak = [request flag:@"jailbreak"];
            BOOL appstore = [request flag:@"appstore"];
            if (!jailbreak && appstore) {
                type = PDIPATypeAppStore;
            }
            type;
        });
        
        [request verbose:@"正在搜索%@商店...", type == PDIPATypeJailbreak ? @"越狱" : @"正版"];
        NSArray *results = [[PDHTTPSessionManager sharedManager] search:query
                                                               pageSize:pageSize
                                                              pageIndex:pageIndex
                                                                   type:type];
        
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        for (NSUInteger i = 0; i < results.count; i++) {
            PDSearchModel *model = results[i];
            CCPrintf(CCStyleBord, @"%@ %@\n", @(pageSize * pageIndex + i + 1).stringValue, model.title);
            CCPrintf(0, @"\t    Bundle ID: %@\n", model.buid);
            CCPrintf(0, @"\t      Version: %@\n", model.version);
            CCPrintf(0, @"\t         Size: %@\n", model.fsize);
            CCPrintf(0, @"\t Download URL: %@\n", model.downurl);
            CCPrintf(0, @"\t  Update Time: %@\n", [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:model.updatetime]]);
        }
        return nil;
    }];
}

@end
