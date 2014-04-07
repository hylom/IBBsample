//
//  IBBAppDelegate.h
//  ibbtest
//
//  Created by Hiromichi Matsushima on 2014/04/06.
//  Copyright (c) 2014年 Hiromichi Matsushima. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOBluetooth/IOBluetooth.h>

@interface IBBAppDelegate : NSObject <NSApplicationDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *cbManager;
@property (strong, nonatomic) CBPeripheral *cbPeripheral;
@property (strong, nonatomic) CBUUID *cbIbbUUID;
@property (assign) IBOutlet NSWindow *window;

@property (strong, nonatomic) NSMutableArray *devices;
@property (strong, nonatomic) NSMutableArray *IbbValues;
@property (weak) IBOutlet NSArrayController *deviceListController;

@end
