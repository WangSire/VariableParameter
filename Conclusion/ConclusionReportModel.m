//
//  ConclusionReportModel.m
//  Conclusion
//
//  Created by Siri on 2019/5/26.
//  Copyright © 2019年 Siri. All rights reserved.
//

#import "ConclusionReportModel.h"

@implementation ConclusionReportModel

- (void (^)(NSString *name))update{
    // 第一步 返回block
    return ^(NSString *name){
        
        // 第五步 执行update block块中内容
        NSLog(@"------- %@",name);
    };
}

- (void)obtainWithName:(NSString *)name{
    NSLog(@"%@",name);
}

id updateValue(char num1)
{ // 第三步    注意:因为updateblock,需要传递一个参数,所以本函数必须要返回一个值
    id obj = nil;
    NSLog(@"++++= %c",num1);
    return obj;
}

@end
