//
//  NSObject+ZLInvokeMethod.m
//  JustCategoryTest
//
//  Created by zhangle on 15/12/8.
//  Copyright © 2015年 zhangle. All rights reserved.
//

#import "NSObject+ZLInvokeMethod.h"
#import <objc/runtime.h>

static inline void __zl_invoke_method(id self, SEL selector)
{
    Class class = object_getClass(self);
    
    uint count;
    
    Method *method_list = class_copyMethodList(class, &count);
    
    for (int i = 0; i < count; i++) {
        Method method = method_list[i];
        if (!sel_isEqual(selector, method_getName(method))) {
            continue;
        }
        
        IMP imp = method_getImplementation(method);
        
        ((void(*)(id,SEL))imp)(self, selector);
    }
}

@implementation NSObject (ZLInvokeMethod)

- (void)invokeAllInstanceMethodWithSelector:(SEL)selector
{
    __zl_invoke_method(self, selector);
}

+ (void)invokeAllClassMethodWithSelector:(SEL)selector
{
    __zl_invoke_method(self, selector);
}

@end
