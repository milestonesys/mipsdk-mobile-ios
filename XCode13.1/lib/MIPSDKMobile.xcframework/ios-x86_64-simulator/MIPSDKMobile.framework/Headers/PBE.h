///
/// PBE.h
///

#import <Foundation/Foundation.h>

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>

///PBE
@interface PBE : NSObject {
    NSData * key;
    NSData * iv;
}

- (id) initWithData: (NSData *) data;

+ (int) keyBytesSize;

- (NSString *) encrypt: (NSString *) value;
- (NSString *) decrypt: (NSString *) value;

@end
