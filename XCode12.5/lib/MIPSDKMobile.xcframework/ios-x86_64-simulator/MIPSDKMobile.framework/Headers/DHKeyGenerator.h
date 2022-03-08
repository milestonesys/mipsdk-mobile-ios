///
/// DHKeyGenerator.h
///

#import <Foundation/Foundation.h>

@class XPInt;
@class DHKeyPair;

@interface DHKeyGenerator : NSObject {
@private
    XPInt * P;
    XPInt * G;
}

- (id) init;
- (id) init_2048;
- (id) initWithP:(XPInt *)pVal G:(XPInt *)gVal;

- (DHKeyPair *) generateKeyPair;

- (DHKeyPair *) generateKeyPairWithX: (XPInt *) X;

- (NSData *) secretKeyBytesWithKeySize: (NSUInteger) keySize publicKey:(XPInt *)publicKey privateKey:(XPInt *)privateKey;

@end
