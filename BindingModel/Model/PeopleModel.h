//
//  PeopleModel.h
//  BindingTest
//
//  Created by Siri on 2019/5/26.
//  Copyright © 2019年 Siri. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PeopleModel : NSObject
@property (nonatomic ,copy) NSString *title;
@property (nonatomic ,copy) NSString *password;
@property (nonatomic ,assign) NSInteger age;
@end

NS_ASSUME_NONNULL_END
