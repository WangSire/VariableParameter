//
//  NSObject+BindingExpand.m
//  BindingTest
//
//  Created by Siri on 2019/5/26.
//  Copyright © 2019年 Siri. All rights reserved.
//

#import "NSObject+BindingExpand.h"
#import <objc/runtime.h>
#import <CoreGraphics/CoreGraphics.h>



static NSString * const kBindingManagementModelKey = @"kBindingManagementModelKey";
static NSMutableDictionary *stashedObserver = nil;
static id objectSelf = nil;  //在C函数中,无法使用self! 只用id来引用

@interface BindingManagement ()
@property (nonatomic ,strong) NSMutableDictionary *keyPathsAndCallBacks;
@end
@implementation BindingManagement
/*
 管理业务层model属性的Observer
 */

- (void)dealloc {
    [self removeAllObservers];
}

- (void)removeAllObservers {
    [self.keyPathsAndCallBacks enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self.target removeObserver:self forKeyPath:key];

    }];
}

- (void)observeKeyPath:(NSString *)keyPath callBack:(observerCallBack)callBack {
    NSAssert(keyPath.length, @"keyPath不合法");
    
    /*加载默认值*/
    id value = [self.target valueForKeyPath:keyPath];
    if (value) {
        callBack(value);
    }
    
    /*添加观察者*/
    [self.keyPathsAndCallBacks setObject:callBack forKey:keyPath];
    [self.target addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    observerCallBack callBack = self.keyPathsAndCallBacks[keyPath];
    if (callBack) {
        callBack(change[NSKeyValueChangeNewKey]);
    }
}

- (NSMutableDictionary *)keyPathsAndCallBacks {
    if (!_keyPathsAndCallBacks) {
        _keyPathsAndCallBacks = [NSMutableDictionary dictionary];
    }
    return _keyPathsAndCallBacks;
}

@end


@implementation NSObject (BindingExpand)

- (NSObject * _Nonnull (^)(NSString *key, observerCallBack callBack))bing{
    if (!stashedObserver) {
        stashedObserver = [NSMutableDictionary dictionary];
    }
    BindingManagement *management = objc_getAssociatedObject(self, &kBindingManagementModelKey);
    
    return ^(NSString *key, observerCallBack callBack){
        // 如果先bing属性,则把绑定的属性先暂存起来,然后在绑定model后,再把该数据传递过期
        if (!management) {
            NSString *viewP = [NSString stringWithFormat:@"%p",self];
            NSMutableDictionary *viewStashMap = stashedObserver[viewP];
            if (!viewStashMap) {
                viewStashMap = [NSMutableDictionary dictionary];
            }
            [viewStashMap setObject:callBack forKey:key];
            [stashedObserver setObject:viewStashMap forKey:viewP];
            return self;
        }
        [management observeKeyPath:key callBack:callBack];
        return self;
    };
}

-(void)bindWithModel:(NSObject *)model {
    
    /*
     给当前对象添加一个关联对象BindingManagement，该关联对象主要用于 (之所以用关联对象来管理KVO事件,是因为关联对象的释放操作是在属性释放之后! 也就是说属性全部释放后,才会去释放关联对象)
     1.存储@{绑定的Key，回调Block}对应关系。
     2.根据@{绑定的Key，回调Block}中的Key，进行KVO监听。
     3.监听view Dealloc事件，自动移除KVO监听。
     */
    
    BindingManagement *management = objc_getAssociatedObject(self, &kBindingManagementModelKey);
    if (!management) {
        management = [[BindingManagement alloc] init];
        management.target = model;
        objc_setAssociatedObject(self, &kBindingManagementModelKey, management, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    if (management.target) {
        [management removeAllObservers];
    }
    
    /*
     stashedObserver: 主要用于
     1.如果bindModel调用在绑定keyPath之后调用，会自动把当前@{绑定的Key，回调Block}结构保存到暂存区。
     2.调用bindModel的时候先根据当前view的地址指针去stashedObserver取暂存的数据。
     3.如果暂存区有数据则调用BindingManagement注册方法进行自动注册。
     4.注册完成进行清空临时缓存。
     */
    NSString *viewP = [NSString stringWithFormat:@"%p",self];
    NSDictionary *viewStashMap = stashedObserver[viewP];
    if (viewStashMap) {
        [viewStashMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [management observeKeyPath:key callBack:obj];
        }];
        //清空临时缓存
        [stashedObserver removeObjectForKey:viewP];
    }
}

- (NSObject * _Nonnull (^)(id _Nonnull, ...))updateValue{
    objectSelf = self;
    return ^(id attribute, ...){
        return self;
    };
}

id bindingAssignment(const char *type, ...) {
    
    //type: value的类型    ...:为@"title",text
    va_list list;
    
    // 这一步是给v赋值   v: 可以当成是一个数组, 数组的内容由[@"title",@"标题"];
    va_start(list, type);
    
    //获取v索引为0的参数, 也就是title
    NSString *key = va_arg(list, NSString *);
    BindingManagement *watchDog = objc_getAssociatedObject(objectSelf, &kBindingManagementModelKey);
    // 获取对象的属性
    Ivar ivar = class_getInstanceVariable([watchDog.target class], [[NSString stringWithFormat:@"_%@",key] UTF8String]);
    
    // 注意:因为updateValue,需要传递一个参数,所以本函数必须要返回一个值 (具体的执行流程可以查看Conclusion 工程)
    id obj = nil;
    
    if (strcmp(type, @encode(id)) == 0) {
        
        // 由于是第二次调用,则获取v索引为1的参数
        id actual = va_arg(list, id);
        // 然后给对象的属性 赋值   (注意:通过该方式 object_setIvar,给属性赋值,不会触发kvo)
        object_setIvar(watchDog.target,ivar,actual);
    } else if (strcmp(type, @encode(CGPoint)) == 0) {
#warning fix me!!!
        CGPoint actual = (CGPoint)va_arg(list, CGPoint);
        void (*fcgpoint)(id, Ivar, CGPoint) = (void (*)(id, Ivar, CGPoint))object_setIvar;
        fcgpoint(watchDog.target,ivar,actual);
    } else if (strcmp(type, @encode(CGSize)) == 0) {
#warning fix me!!!
        CGSize actual = (CGSize)va_arg(list, CGSize);
        void (*fcgsize)(id, Ivar, CGSize) = (void (*)(id, Ivar, CGSize))object_setIvar;
        fcgsize(watchDog.target,ivar,actual);
    }  else if (strcmp(type, @encode(double)) == 0) {
        double actual = (double)va_arg(list, double);
        void (*fdouble)(id, Ivar, double) = (void (*)(id, Ivar, double))object_setIvar;
        fdouble(watchDog.target,ivar,actual);
    } else if (strcmp(type, @encode(float)) == 0) {
        float actual = (float)va_arg(list, double);
        void (*ffloat)(id, Ivar, float) = (void (*)(id, Ivar, float))object_setIvar;
        ffloat(watchDog.target,ivar,actual);
    } else if (strcmp(type, @encode(int)) == 0) {
        int actual = (int)va_arg(list, int);
        void (*fint)(id, Ivar, int) = (void (*)(id, Ivar, int))object_setIvar;
        fint(watchDog.target,ivar,actual);
    } else if (strcmp(type, @encode(long)) == 0) {
        long actual = (long)va_arg(list, long);
        void (*flong)(id, Ivar, long) = (void (*)(id, Ivar, long))object_setIvar;
        flong(watchDog.target,ivar,actual);
    } else if (strcmp(type, @encode(long long)) == 0) {
        long long actual = (long long)va_arg(list, long long);
        void (*flonglong)(id, Ivar, long long) = (void (*)(id, Ivar, long long))object_setIvar;
        flonglong(watchDog.target,ivar,actual);
    } else if (strcmp(type, @encode(short)) == 0) {
        short actual = (short)va_arg(list, int);
        void (*fshort)(id, Ivar, short) = (void (*)(id, Ivar, short))object_setIvar;
        fshort(watchDog.target,ivar,actual);
    } else if (strcmp(type, @encode(char)) == 0) {
        char actual = (char)va_arg(list, int);
        void (*fchar)(id, Ivar, char) = (void (*)(id, Ivar, char))object_setIvar;
        fchar(watchDog.target,ivar,actual);
    } else if (strcmp(type, @encode(bool)) == 0) {
        bool actual = (bool)va_arg(list, int);
        void (*fbool)(id, Ivar, bool) = (void (*)(id, Ivar, bool))object_setIvar;
        fbool(watchDog.target,ivar,actual);
    } else if (strcmp(type, @encode(unsigned char)) == 0) {
        unsigned char actual = (unsigned char)va_arg(list, unsigned int);
        void (*funsignedchar)(id, Ivar, unsigned char) = (void (*)(id, Ivar, unsigned char))object_setIvar;
        funsignedchar(watchDog.target,ivar,actual);
    } else if (strcmp(type, @encode(unsigned int)) == 0) {
        unsigned int actual = (unsigned int)va_arg(list, unsigned int);
        void (*funsignedint)(id, Ivar, unsigned int) = (void (*)(id, Ivar, unsigned int))object_setIvar;
        funsignedint(watchDog.target,ivar,actual);
    } else if (strcmp(type, @encode(unsigned long)) == 0) {
        unsigned long actual = (unsigned long)va_arg(list, unsigned long);
        void (*funsignedlong)(id, Ivar, unsigned long) = (void (*)(id, Ivar, unsigned long))object_setIvar;
        funsignedlong(watchDog.target,ivar,actual);
    } else if (strcmp(type, @encode(unsigned long long)) == 0) {
        unsigned long long actual = (unsigned long long)va_arg(list, unsigned long long);
        void (*funsignedlonglong)(id, Ivar, unsigned long long) = (void (*)(id, Ivar, unsigned long long))object_setIvar;
        funsignedlonglong(watchDog.target,ivar,actual);
    } else if (strcmp(type, @encode(unsigned short)) == 0) {
        unsigned short actual = (unsigned short)va_arg(list, unsigned int);
        void (*funsignedshort)(id, Ivar, unsigned short) = (void (*)(id, Ivar, unsigned short))object_setIvar;
        funsignedshort(watchDog.target,ivar,actual);
    }
    va_end(list);
    return obj;
}

@end
