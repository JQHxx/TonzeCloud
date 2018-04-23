//
//  BLEDeviceModel+connect.h
//  Product
//
//  Created by 梁家誌 on 16/8/18.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "BLEDeviceModel.h"

@interface BLEDeviceModel (connect)

typedef void(^getUUIDSuccessCallBack)(CBPeripheral *_Nullable peripheral, NSString *_Nullable uuidString);

- (void)connectBLEDeviceModel:(BLEDeviceModel *_Nonnull)model withType:(DeviceType )type callbackDevice:(getUUIDSuccessCallBack _Nullable)callback;
@end
