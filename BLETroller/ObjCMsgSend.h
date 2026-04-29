#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

void BLETrollerObjCSendVoid(id obj, SEL sel);
void BLETrollerObjCSendObject(id obj, SEL sel, id _Nullable arg);
void BLETrollerObjCSendUInt8(id obj, SEL sel, uint8_t arg);
void BLETrollerObjCActivateWithCompletion(id obj, void (^completion)(id _Nullable error));

NS_ASSUME_NONNULL_END

