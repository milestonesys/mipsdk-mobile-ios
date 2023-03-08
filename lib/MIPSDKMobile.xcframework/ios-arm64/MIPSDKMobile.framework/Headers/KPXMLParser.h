///
/// KPXMLParser.h
///
/// XML Parser, based on https://github.com/bcaccinolo/XML-to-NSDictionary

#import <Foundation/Foundation.h>

/// XML Parser, based on https://github.com/bcaccinolo/XML-to-NSDictionary
@interface KPXMLParser : NSObject <NSXMLParserDelegate>

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)errorPointer;

@end

