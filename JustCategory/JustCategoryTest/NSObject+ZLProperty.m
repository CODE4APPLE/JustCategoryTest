//
//  NSObject+ZLProperty.m
//  JustCategoryTest
//
//  Created by zhangle on 15/12/8.
//  Copyright © 2015年 zhangle. All rights reserved.
//

#import "NSObject+ZLProperty.h"
#import <UIKit/UIKit.h>

NSString *ZLPropertyException = @"ZLPropertyException";

static inline NSString *__zl_setter_selector_name_of_property(NSString *property)
{
    NSString *headCharacter = [[property substringToIndex:1] uppercaseString];
    NSString *otherString = [property substringFromIndex:1];
    return [NSString stringWithFormat:@"set%@%@",headCharacter,otherString];
}

@implementation NSObject (ZLProperty)

+ (void)addObjcProperty:(NSString *)name {
    [self addObjcProperty:name associationPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

+ (void)addObjcProperty:(NSString *)name associationPolicy:(objc_AssociationPolicy)policy {
    if (!name.length) {
        [[NSException exceptionWithName:ZLPropertyException reason:@"property must not be empty in +addObjectProperty:associationPolicy:" userInfo:@{@"name":name,@"policy":@(policy)}] raise];
    }
    
    NSString *key = [NSString stringWithFormat:@"%p_%@",self,name];
    
    id setBlock = ^(id self, id value) {
        objc_setAssociatedObject(self, (__bridge void *)key, value, policy);
    };
    
    IMP set_imp = imp_implementationWithBlock(setBlock);
    
    NSString *setter_selector_name = __zl_setter_selector_name_of_property(name);
    BOOL result = class_addMethod([self class], NSSelectorFromString(setter_selector_name), set_imp, "v@:@");
    assert(result);
    
    id getBlock = ^(id self) {
        return objc_getAssociatedObject(self, (__bridge void *)key);
    };
    
    IMP get_imp = imp_implementationWithBlock(getBlock);
    
    result = class_addMethod([self class], NSSelectorFromString(name), get_imp, "@@:");
    assert(result);
    
}

+ (void)addBasicProperty:(NSString *)name ecodingType:(char *)type {
    if (!name.length) {
        [[NSException exceptionWithName:ZLPropertyException
                                 reason:@"property must not be empty in +addBasicProperty:encodingType:"
                               userInfo:@{@"name":name,@"type":@(type)}]
         raise];
    }

    if (strcmp(type, @encode(id)) == 0) {
        [self addObjcProperty:name];
    }
    
    NSString *key = [NSString stringWithFormat:@"%p_%@",self,name];
    id setblock;
    id getBlock;
#define blockWithCaseType(C_TYPE)                               \
    if (strcmp(type, @encode(C_TYPE)) == 0) {                   \
    setblock = ^(id self,C_TYPE var){                       \
    NSValue *value = [NSValue value:&var withObjCType:type];\
    objc_setAssociatedObject(self, (__bridge void *)key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);  \
    };                                                          \
    getBlock = ^C_TYPE (id self){                               \
    NSValue *value = objc_getAssociatedObject(self, (__bridge void*)key);   \
    C_TYPE var;                                             \
    [value getValue:&var];                                  \
    return var;                                             \
    };                                                          \
}
    blockWithCaseType(char);
    blockWithCaseType(unsigned char);
    blockWithCaseType(short);
    blockWithCaseType(int);
    blockWithCaseType(unsigned int);
    blockWithCaseType(long);
    blockWithCaseType(unsigned long);
    blockWithCaseType(long long);
    blockWithCaseType(float);
    blockWithCaseType(double);
    blockWithCaseType(BOOL);
    
    blockWithCaseType(CGPoint);
    blockWithCaseType(CGSize);
    blockWithCaseType(CGVector);
    blockWithCaseType(CGRect);
    blockWithCaseType(NSRange);
    blockWithCaseType(CFRange);
    blockWithCaseType(CGAffineTransform);
    blockWithCaseType(CATransform3D);
    blockWithCaseType(UIOffset);
    blockWithCaseType(UIEdgeInsets);
#undef blockWithCaseType
    
    if (!setblock || !getBlock) {
        [[NSException exceptionWithName:ZLPropertyException
                                 reason:@"type is an unknown type in +addBasicProperty:encodingType:"
                               userInfo:@{@"name":name,@"type":@(type)}]
         raise];
    }
    
    IMP setImp = imp_implementationWithBlock(setblock);
    NSString *selString = __zl_setter_selector_name_of_property(name);
    NSString *setType = [NSString stringWithFormat:@"v@:%@",@(type)];
    BOOL result = class_addMethod([self class], NSSelectorFromString(selString), setImp, [setType UTF8String]);
    assert(result);
    
    IMP getImp = imp_implementationWithBlock(getBlock);
    NSString *getType = [NSString stringWithFormat:@"%@@:",@(type)];
    result = class_addMethod([self class], NSSelectorFromString(name), getImp, [getType UTF8String]);
    assert(result);
}
@end
