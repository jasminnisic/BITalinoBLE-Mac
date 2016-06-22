//
//  ViewController.h
//  BITalinoBLEMac-Example
//
//  Created by Jasmin Nisic on 22/06/16.
//  Copyright © 2016 JasminNisic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BitalinoBLEMac/BITalinoBLE.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>

@interface ViewController : NSViewController<NSTableViewDelegate, NSTableViewDataSource, BITalinoBLEDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>{
    int sampleRate;
    BITalinoBLE* bitalino;
    NSMutableArray* devices;
}
@property (weak) IBOutlet NSTableView *devicesTableView;
@property (strong, nonatomic) CBCentralManager *CM;
@property (weak) IBOutlet NSButton *btnConnect;
@property (weak) IBOutlet NSTextField *lblStatus;
@property (weak) IBOutlet NSSlider *sliderThreshold;
@property (weak) IBOutlet NSTextField *lblThreshold;
@property (weak) IBOutlet NSButton *btnStart;
@property (weak) IBOutlet NSButton *switchA0;
@property (weak) IBOutlet NSButton *switchA1;
@property (weak) IBOutlet NSButton *switchA2;
@property (weak) IBOutlet NSButton *switchA3;
@property (weak) IBOutlet NSButton *switchA4;
@property (weak) IBOutlet NSButton *switchA5;
@property (weak) IBOutlet NSButton *switchD1;
@property (weak) IBOutlet NSButton *switchD2;
@property (weak) IBOutlet NSButton *switchD3;
@property (weak) IBOutlet NSButton *switchD4;

@end

