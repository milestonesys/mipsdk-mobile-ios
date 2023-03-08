///
/// DHEncryption.h
///

#import <Foundation/Foundation.h>

@class XPInt;
@class DHKeyGenerator;
@class DHKeyPair;

@class PBE;

@interface DHEncryption : NSObject {
    DHKeyGenerator * keyGenerator;
    DHKeyPair * keyPair;
    
    PBE * pbe;
}

- (id) init;

- (id) initWithKeyPair: (DHKeyPair *) samplePair;

- (NSString *) publicKeyEncoded;

- (void) generateSecretKeyFromString: (NSString *) base64EncodedString;

- (NSString *) encrypt:(NSString *)string;
- (NSString *) decrypt:(NSString *)string;

@property (readonly) int key_size;

@end
