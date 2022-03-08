///
/// DHKeyPair.h
///

#import <Foundation/Foundation.h>

@class XPInt;

@interface DHKeyPair : NSObject

@property (nonatomic, readonly) XPInt * privateKey;
@property (nonatomic, readonly) XPInt * publicKey;

- (id) init;

- (id) initWithPrivateKey:(XPInt *)prk publicKey:(XPInt *)pubk;

@end
