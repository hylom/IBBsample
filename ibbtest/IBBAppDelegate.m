//
//  IBBAppDelegate.m
//  ibbtest
//
//  Created by Hiromichi Matsushima on 2014/04/06.
//  Copyright (c) 2014年 Hiromichi Matsushima. All rights reserved.
//

/*
 * iRig BlueBoard's UUID is 755F479F-1284-40FB-BFB9-5DFE9DD7C2D3
 */

#import "IBBAppDelegate.h"

@implementation IBBAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.cbManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];

    // iRig BuleBoard's UUID
    self.cbIbbUUID = [CBUUID UUIDWithString: @"755F479F-1284-40FB-BFB9-5DFE9DD7C2D3"];
    
    self.devices = [[NSMutableArray alloc] init];
    [self.deviceListController setContent:self.devices];
}

- (IBAction)doScan:(id)sender {
    NSLog(@"button pushed!");
    
//    [self.cbManager scanForPeripheralsWithServices:@[self.cbIbbUUID] options:nil];
    [self.cbManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"%ld",[self.cbManager state]);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"Discovered %@", peripheral.name);
    NSLog(@"UUID %@", peripheral.UUID);

    // save discovered devices
    NSString *uuid = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, peripheral.UUID);
    NSDictionary *device = @{@"name": peripheral.name,
                            @"UUID": uuid,
                             @"peripheral": peripheral};
    [self.deviceListController addObject:device];
}

- (IBAction)doConnect:(id)sender {
    // Get selected device
    NSInteger selected = [self.deviceListController selectionIndex];
    if (selected == NSNotFound) {
        return;
    }
    
    // FIXME: selected value is correct?
    NSLog(@"selected %ld", (long)selected);
    NSDictionary *selectedDevice = [self.devices objectAtIndex:selected];
    NSLog(@"ID %@", selectedDevice);

    // stop discvering
    [self.cbManager stopScan];
    
    // connect to device
    CBPeripheral *peripheral = [selectedDevice objectForKey:@"peripheral"];
    [self.cbManager connectPeripheral:peripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Peripheral connected");
    peripheral.delegate = self;
    self.cbPeripheral = peripheral;
    
    //[peripheral discoverServices:nil];
    //CBUUID *uuid = [CBUUID UUIDWithString: @"180a"];
    CBUUID *uuid = [CBUUID UUIDWithString: @"6B872736-F93E-4176-B3B1-143636CABB00"];

    
    [peripheral discoverServices:@[uuid]];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
        NSString *logFormat = @"Discovered service: UUID %@";
        //NSLog(@"Discovered service %@", service);
        NSLog(logFormat, service.UUID);
        CBUUID *uuid = [CBUUID UUIDWithString: @"6B872736-F93E-4176-B3B1-143636CABB01"];
        [peripheral discoverCharacteristics:@[uuid] forService:service];

    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSString *logFormat = @"service UUID: %@ char UUID: %@ r:%d wwr:%d w:%d n:%d i:%d ";
        NSLog(logFormat, service.UUID,
              characteristic.UUID,
              characteristic.properties & CBCharacteristicPropertyRead,
              characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse,
              characteristic.properties & CBCharacteristicPropertyWrite,
              characteristic.properties & CBCharacteristicPropertyNotify,
              characteristic.properties & CBCharacteristicPropertyIndicate
              );

        [self.IbbValues addObject:characteristic];
        NSLog(@"Start Watching");
        //[self.cbPeripheral readValueForCharacteristic:characteristic];
        [self.cbPeripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error changing notification state: %@", [error localizedDescription]);
    }
    NSLog(@"update Notification State");
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    //NSData *data = characteristic.value;
    NSLog(@"UUID: %@ value: %@", characteristic.UUID, characteristic.value);
    //[self.cbPeripheral readValueForCharacteristic:characteristic];
    //[self.cbPeripheral writeValue:characteristic.value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];

}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error writing characteristic value: %@",
              [error localizedDescription]);
    }
    NSLog(@"write done");
}

/*
 Discovered service: UUID Generic Access Profile
 Discovered service: UUID Generic Attribute Profile
 Discovered service: UUID Unknown (<180a>)
 Discovered service: UUID Unknown (<180f>)
 Discovered service: UUID Unknown (<6b872736 f93e4176 b3b11436 36cabb00>)
 
 Generic Access Profile -> Device Name r:2 wwr:0 w:0 n:0 i:0
 Generic Access Profile -> Appearence r:2 wwr:0 w:0 n:0 i:0
 Generic Access Profile -> Peripheral Privacy Flag r:2 wwr:0 w:8 n:0 i:0
 Generic Access Profile -> Reconnection Address r:2 wwr:0 w:8 n:0 i:0
 Generic Access Profile -> Peripheral Preferred Connection Parameters r:2 wwr:0 w:0 n:0 i:0

 Generic Attribute Profile -> Service Changed r:0 wwr:0 w:0 n:0 i:32
 
 Unknown (<180a>) -> Unknown (<2a23>) r:2 wwr:0 w:0 n:0 i:0
 Unknown (<180a>) -> Unknown (<2a24>) r:2 wwr:0 w:0 n:0 i:0
 Unknown (<180a>) -> Unknown (<2a26>) r:2 wwr:0 w:0 n:0 i:0
 Unknown (<180a>) -> Unknown (<2a28>) r:2 wwr:0 w:0 n:0 i:0
 Unknown (<180a>) -> Unknown (<2a29>) r:2 wwr:0 w:0 n:0 i:0
 
 Unknown (<180f>) -> Unknown (<2a19>) r:2 wwr:0 w:0 n:16 i:0
 
 Unknown (<6b872736 f93e4176 b3b11436 36cabb00>) -> Unknown (<6b872736 f93e4176 b3b11436 36cabb01>) r:0 wwr:0 w:0 n:16 i:0

Unknown (<6b872736 f93e4176 b3b11436 36cabb00>) -> Unknown (<6b872736 f93e4176 b3b11436 36cabb02>) r:0 wwr:0 w:8 n:0 i:0
 Unknown (<6b872736 f93e4176 b3b11436 36cabb00>) -> Unknown (<6b872736 f93e4176 b3b11436 36cabb03>) r:0 wwr:0 w:0 n:16 i:0
 Unknown (<6b872736 f93e4176 b3b11436 36cabb00>) -> Unknown (<6b872736 f93e4176 b3b11436 36cabb04>) r:2 wwr:0 w:8 n:0 i:0
 Unknown (<6b872736 f93e4176 b3b11436 36cabb00>) -> Unknown (<6b872736 f93e4176 b3b11436 36cabb05>) r:0 wwr:0 w:8 n:0 i:0
 Unknown (<6b872736 f93e4176 b3b11436 36cabb00>) -> Unknown (<6b872736 f93e4176 b3b11436 36cabb06>) r:2 wwr:0 w:0 n:0 i:0
 Unknown (<6b872736 f93e4176 b3b11436 36cabb00>) -> Unknown (<6b872736 f93e4176 b3b11436 36cabb07>) r:0 wwr:0 w:0 n:16 i:0
 Unknown (<6b872736 f93e4176 b3b11436 36cabb00>) -> Unknown (<6b872736 f93e4176 b3b11436 36cabb08>) r:0 wwr:0 w:8 n:0 i:0
 Unknown (<6b872736 f93e4176 b3b11436 36cabb00>) -> Unknown (<6b872736 f93e4176 b3b11436 36cabb09>) r:2 wwr:0 w:8 n:0 i:0

*/

- (IBAction)doDisconnect:(id)sender {
}

@end

