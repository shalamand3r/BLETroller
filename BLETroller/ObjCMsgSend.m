#import "ObjCMsgSend.h"

#import <objc/message.h>

void BLETrollerObjCSendVoid(id obj, SEL sel) {
    ((void (*)(id, SEL))objc_msgSend)(obj, sel);
}

void BLETrollerObjCSendObject(id obj, SEL sel, id arg) {
    ((void (*)(id, SEL, id))objc_msgSend)(obj, sel, arg);
}

void BLETrollerObjCSendUInt8(id obj, SEL sel, uint8_t arg) {
    ((void (*)(id, SEL, uint8_t))objc_msgSend)(obj, sel, arg);
}

void BLETrollerObjCActivateWithCompletion(id obj, void (^completion)(id error)) {
    ((void (*)(id, SEL, id))objc_msgSend)(obj, sel_registerName("activateWithCompletion:"), completion);
}

