///
///  XPSDKBinaryUtils.c
///

short int get_int8 (char * start);
int get_int16 (char * start);
int get_int32 (char * start);
long long get_int64 (char * start);

unsigned short int get_uint8 (char * start);
unsigned int get_uint16 (char * start);
unsigned int get_uint32 (char * start);
unsigned long long get_uint64 (char * start);

long long CFWordFlip (long long val);

void memCopyRev (char * dest, char * source, size_t bytes);
void memCopyRev2Bytes(char * dest, char * source);
void memCopyRev4Bytes(char * dest, char * source);
void memCopyRev8Bytes(char * dest, char * source);
