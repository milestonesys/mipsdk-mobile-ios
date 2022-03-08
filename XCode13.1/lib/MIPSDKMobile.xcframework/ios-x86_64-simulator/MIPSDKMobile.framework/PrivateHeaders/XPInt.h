///
/// XPInt.h
///

/* Dec 2014: Updated to use OpenSSL's bignum as GMP library will not be used anymore. */

#import <Foundation/Foundation.h>
#import <openssl/bn.h>

///XPInt
@interface XPInt : NSObject {
    BIGNUM *value;
}

- (XPInt *)initRandomWithNumberOfBytes:(const unsigned int) bytes;

- (XPInt *)initWithSI:(signed long)lval; 
- (XPInt *)initWithValue:(BIGNUM *)val;
- (XPInt *)initWithData: (NSData *)data;

- (XPInt *)pow:(XPInt *) pow mod:(XPInt *) mod;

- (NSData *)data;

- (NSString *)stringValue; 
- (NSString *)description;

@end
