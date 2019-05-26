//
//  ConclusionReportModel.h
//  Conclusion
//
//  Created by Siri on 2019/5/26.
//  Copyright © 2019年 Siri. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConclusionReportModel : NSObject

//第二步 走这个update()      第四步: 获取到函数返回值后,执行该update
#define update(value)      update(updateValue(value))
id updateValue(char num1);

@property (nonatomic ,copy) NSString *title;
@property (nonatomic ,assign) NSInteger age;

- (void (^)(NSString *name))update;
- (void)obtainWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
