//
//  ViewController.m
//  qwelpo
//
//  Created by Siri on 2019/5/24.
//  Copyright © 2019 Siri. All rights reserved.
//

#import "ViewController.h"
#import "ConclusionReportModel.h"
#import <objc/runtime.h>
#import "Masonry/Masonry.h"


#define currentUpdateValue(key,...) dealWith(key,(__VA_ARGS__)) // __VA_ARGS__ : 可变参数的宏,只能用于宏
#define dealWith(key,value) autoBinding(@encode(__typeof__((value))),key,(value))

@interface ViewController ()
@property (nonatomic ,strong)ConclusionReportModel *reportModel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self obtainWithNames:@"确定",@"取消",@"娃哈哈",nil];
    
    [self obtainWithKey:@"title" value:@"取消",@"娃哈哈"];
    
    currentUpdateValue(@"age",18);
    
    ConclusionReportModel *model = [[ConclusionReportModel alloc] init];
    model.update(@"title");
}

// 可变参数写法: names,...
- (void)obtainWithNames:(id)names,... {
    // args:当做一个数组容器
    va_list args;
    va_start(args, names);
    
    NSString *name;
    while ((name = va_arg(args, id))) {
        NSLog(@"%@",name);
    }
    va_end(args);
}

- (void)obtainWithKey:(NSString *)key value:(NSString *)value,...{
    
    //1.为value类型   2.属性名称   3.value
    autoBinding(@encode(__typeof__((value))),key,(value));
}

// 通过可变参数的形式给某个对象属性赋值
id autoBinding(const char *type, ...) {
    
    // 更多使用方式可以查看Masonry中的_MASBoxValue函数
    
    
    //type: 第二个参数的类型    ...:为@"title",@"标题"
    va_list v;
    
    // 这一步是给v赋值   v: 可以当成是一个数组, 数组的内容由[@"title",@"标题"]; (可以理解为,该函数参数是个数组,通过va_start 给V赋值,只能获取到索引为1之后的数据)
    va_start(v, type);
    
    //获取v索引为0的参数, 也就是title
    NSString *key = va_arg(v, NSString *);
    ConclusionReportModel *reportModel = [[ConclusionReportModel alloc] init];
    // 获取对象的属性
    Ivar ivar = class_getInstanceVariable([ConclusionReportModel class], [[NSString stringWithFormat:@"_%@",key] UTF8String]);
    
    id obj = nil;
    // strcmp:类型对比
    if (strcmp(type, @encode(id)) == 0) {
        // 由于是第二次调用,则获取v索引为1的参数
        id actual = va_arg(v, id);
        // 然后给对象的属性 赋值   (注意:通过该方式 object_setIvar,给属性赋值,不会触发kvo)
        object_setIvar(reportModel,ivar,actual);
    } else if (strcmp(type, @encode(CGPoint)) == 0) {
        CGPoint actual = (CGPoint)va_arg(v, CGPoint);
        void (*fcgpoint)(id, Ivar, CGPoint) = (void (*)(id, Ivar, CGPoint))object_setIvar;
        fcgpoint(reportModel,ivar,actual);
    } else if (strcmp(type, @encode(CGSize)) == 0) {
        CGSize actual = (CGSize)va_arg(v, CGSize);
        void (*fcgsize)(id, Ivar, CGSize) = (void (*)(id, Ivar, CGSize))object_setIvar;
        fcgsize(reportModel,ivar,actual);
    }  else if (strcmp(type, @encode(double)) == 0) {
        double actual = (double)va_arg(v, double);
        void (*fdouble)(id, Ivar, double) = (void (*)(id, Ivar, double))object_setIvar;
        fdouble(reportModel,ivar,actual);
    } else if (strcmp(type, @encode(float)) == 0) {
        float actual = (float)va_arg(v, double);
        void (*ffloat)(id, Ivar, float) = (void (*)(id, Ivar, float))object_setIvar;
        ffloat(reportModel,ivar,actual);
    } else if (strcmp(type, @encode(int)) == 0) {
        int actual = (int)va_arg(v, int);
        void (*fint)(id, Ivar, int) = (void (*)(id, Ivar, int))object_setIvar;
        fint(reportModel,ivar,actual);
    } else if (strcmp(type, @encode(long)) == 0) {
        long actual = (long)va_arg(v, long);
        void (*flong)(id, Ivar, long) = (void (*)(id, Ivar, long))object_setIvar;
        flong(reportModel,ivar,actual);
    } else if (strcmp(type, @encode(long long)) == 0) {
        long long actual = (long long)va_arg(v, long long);
        void (*flonglong)(id, Ivar, long long) = (void (*)(id, Ivar, long long))object_setIvar;
        flonglong(reportModel,ivar,actual);
    } else if (strcmp(type, @encode(short)) == 0) {
        short actual = (short)va_arg(v, int);
        void (*fshort)(id, Ivar, short) = (void (*)(id, Ivar, short))object_setIvar;
        fshort(reportModel,ivar,actual);
    } else if (strcmp(type, @encode(char)) == 0) {
        char actual = (char)va_arg(v, int);
        void (*fchar)(id, Ivar, char) = (void (*)(id, Ivar, char))object_setIvar;
        fchar(reportModel,ivar,actual);
    } else if (strcmp(type, @encode(bool)) == 0) {
        bool actual = (bool)va_arg(v, int);
        void (*fbool)(id, Ivar, bool) = (void (*)(id, Ivar, bool))object_setIvar;
        fbool(reportModel,ivar,actual);
    } else if (strcmp(type, @encode(unsigned char)) == 0) {
        unsigned char actual = (unsigned char)va_arg(v, unsigned int);
        void (*funsignedchar)(id, Ivar, unsigned char) = (void (*)(id, Ivar, unsigned char))object_setIvar;
        funsignedchar(reportModel,ivar,actual);
    } else if (strcmp(type, @encode(unsigned int)) == 0) {
        unsigned int actual = (unsigned int)va_arg(v, unsigned int);
        void (*funsignedint)(id, Ivar, unsigned int) = (void (*)(id, Ivar, unsigned int))object_setIvar;
        funsignedint(reportModel,ivar,actual);
    } else if (strcmp(type, @encode(unsigned long)) == 0) {
        unsigned long actual = (unsigned long)va_arg(v, unsigned long);
        void (*funsignedlong)(id, Ivar, unsigned long) = (void (*)(id, Ivar, unsigned long))object_setIvar;
        funsignedlong(reportModel,ivar,actual);
    } else if (strcmp(type, @encode(unsigned long long)) == 0) {
        unsigned long long actual = (unsigned long long)va_arg(v, unsigned long long);
        void (*funsignedlonglong)(id, Ivar, unsigned long long) = (void (*)(id, Ivar, unsigned long long))object_setIvar;
        funsignedlonglong(reportModel,ivar,actual);
    } else if (strcmp(type, @encode(unsigned short)) == 0) {
        unsigned short actual = (unsigned short)va_arg(v, unsigned int);
        void (*funsignedshort)(id, Ivar, unsigned short) = (void (*)(id, Ivar, unsigned short))object_setIvar;
        funsignedshort(reportModel,ivar,actual);
    }
    va_end(v);
    return obj;
}


@end
