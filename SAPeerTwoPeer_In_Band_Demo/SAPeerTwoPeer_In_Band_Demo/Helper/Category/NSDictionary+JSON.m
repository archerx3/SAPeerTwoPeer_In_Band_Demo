//
//  NSDictionary+JSON.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/22/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (JSON)

+ (NSDictionary *)dictionaryWithJSONString:(NSString *)jsonString
{
    NSParameterAssert(jsonString.length > 0);
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error)
    {
        NSLog(@"Error parsing JSON: %@", error.localizedDescription);
    }
    return dict;
}

+ (NSDictionary *)dictionaryWithJSONData:(NSData *)jsonData
{
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    if (error)
    {
        NSLog(@"Error parsing JSON: %@", error.localizedDescription);
    }
    return dict;
}

@end
