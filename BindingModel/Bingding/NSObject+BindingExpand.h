//
//  NSObject+BindingExpand.h
//  BindingTest
//
//  Created by Siri on 2019/5/26.
//  Copyright © 2019年 Siri. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^observerCallBack)(id obj);


@interface BindingManagement : NSObject

@property (nonatomic, strong)NSObject *target;

/** 删除所有观察事件 */
- (void)removeAllObservers;

/** 设置需要监听的key 以及回调事件 */
- (void)observeKeyPath:(NSString *)keyPath callBack:(observerCallBack)callBack;
@end


NS_ASSUME_NONNULL_BEGIN

/*
  // __VA_ARGS__ : 可变参数的宏,只能用于宏  (,... 则就是用 __VA_ARGS__来接收)
  bindingAssignment(value的类型,属性名称,value)
 */
#define updateValue(key,...) updateValue(bindingAssignment(@encode(__typeof__(((__VA_ARGS__)))),key,((__VA_ARGS__))))
id bindingAssignment(const char *type, ...);

@interface NSObject (BindingExpand)
/** 绑定属性 */
- (NSObject *(^)(NSString *key, observerCallBack callBack))bing;

/** 绑定model */
- (void)bindWithModel:(NSObject *)model;

/** 更新数据 */
- (NSObject * (^)(id,...))updateValue;
@end

NS_ASSUME_NONNULL_END
