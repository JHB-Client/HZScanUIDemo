//
//  NSString+urlJudge.m
//  HZScanUIDemo
//
//  Created by admin on 2019/11/22.
//  Copyright © 2019 admin. All rights reserved.
//

#import "NSString+urlJudge.h"

@implementation NSString (urlJudge)
- (BOOL)isUrl {
    
    if(self == nil) {
        return NO;
    }
    
    NSString *url;
    if (self.length>4 && [[self substringToIndex:4] isEqualToString:@"www."]) {
        url = [NSString stringWithFormat:@"http://%@",self];
    }else{
        url = self;
    }
    NSString *urlRegex = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
    NSPredicate* urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];
    return [urlTest evaluateWithObject:url];
}
@end
