//
//  NSObject+ZLProperty.h
//  JustCategoryTest
//
//  Created by zhangle on 15/12/8.
//  Copyright © 2015年 zhangle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (ZLProperty)

+ (void)addObjcProperty:(NSString *)name;
+ (void)addObjcProperty:(NSString *)name associationPolicy:(objc_AssociationPolicy)policy;
+ (void)addBasicProperty:(NSString *)name ecodingType:(char *)type;

@end
