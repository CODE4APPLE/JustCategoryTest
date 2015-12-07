//
//  NSObject+ZLInvokeMethod.h
//  JustCategoryTest
//
//  Created by zhangle on 15/12/8.
//  Copyright © 2015年 zhangle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ZLInvokeMethod)

- (void)invokeAllInstanceMethodWithSelector:(SEL)selector;

+ (void)invokeAllClassMethodWithSelector:(SEL)selector;

@end
