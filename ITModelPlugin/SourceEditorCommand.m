//
//  SourceEditorCommand.m
//  ITModelPlugIns
//
//  Created by EDZ on 2018/9/1.
//  Copyright © 2018年 EDZ. All rights reserved.
//

#import "SourceEditorCommand.h"
#import <AppKit/AppKit.h>

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    [self generatePropertyCodeWithInvocation:invocation];
    
    completionHandler(nil);
}


#pragma mark - Public

- (void)generatePropertyCodeWithInvocation:(XCSourceEditorCommandInvocation *)invocation {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    
    NSString *text = [pasteboard stringForType:NSPasteboardTypeString];
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[text dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    if (dictionary.count > 0 && invocation.buffer.selections.count > 0) {
        NSString *propertiesCode = [self generatePropertyWithDictionary:dictionary];
        if (propertiesCode.length > 0) {
            XCSourceTextRange *textRange = [invocation.buffer.selections firstObject];
            [invocation.buffer.lines insertObject:propertiesCode atIndex:textRange.end.line];
        }
    }
}

- (NSString *)generatePropertyWithDictionary:(NSDictionary *)dictionary {
    
    NSMutableString *properties = [NSMutableString string];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *property = [self generatePropertyWithKey:key obj:obj];
        if (property.length > 0) {
            [properties appendString:property];
        }
    }];
    
    return properties;
}

- (NSString *)generatePropertyWithKey:(NSString *)key obj:(id)obj {
    
    NSString *property = nil;
    
    if ([obj isKindOfClass:[NSString class]]) {
        property = [NSString stringWithFormat:@"@property (copy, nonatomic) NSString *%@;\n", key];
    } else if ([obj isKindOfClass:[NSArray class]]) {
        property = [NSString stringWithFormat:@"@property (copy, nonatomic) NSArray *%@;\n", key];
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        property = [NSString stringWithFormat:@"@property (copy, nonatomic) NSDictionary *%@;\n", key];
    } else if ([[obj className] isEqualToString:@"__NSCFBoolean"]) {
        property = [NSString stringWithFormat:@"@property (assign, nonatomic, getter=is%@) BOOL %@;\n", [[key copy] capitalizedString], key];
    } else if ([[obj className] isEqualToString:@"__NSCFNumber"]) {
        property = [NSString stringWithFormat:@"@property (copy, nonatomic) NSNumber *%@;\n", key];
    } else {
        property = [NSString stringWithFormat:@"@property (strong, nonatomic) id %@;\n", key];
    }
    return property;
}

@end
