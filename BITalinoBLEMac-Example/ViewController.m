//
//  ViewController.m
//  BITalinoBLEMac-Example
//
//  Created by Jasmin Nisic on 22/06/16.
//  Copyright © 2016 JasminNisic. All rights reserved.
//

#import "ViewController.h"
#define BITALINO_IDENTIFIER @"EC763E0C-0CAF-4C70-AD48-1BC4EBA4CF71"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    sampleRate=1;
    _CM = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    _CM.delegate=self;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];


}
- (IBAction)btnConnectOnTap:(id)sender {
    if(self.CM!=nil){
        [self.CM stopScan];        
    }
    if(_devicesTableView.selectedRow==-1){
        NSLog(@"Nothing is selected");
        return;
    }
    CBPeripheral* selectedDevice = [devices objectAtIndex:[_devicesTableView selectedRow]];
    if(![bitalino isConnected] || bitalino==nil){
        bitalino = [[BITalinoBLE alloc] initWithUUID:selectedDevice.identifier.UUIDString];
        bitalino.delegate=self;
        [bitalino scanAndConnect];
    } else{
        [bitalino disconnect];
    }
}

- (IBAction)btnScanOnClick:(id)sender {
    if(self.CM!=nil){
        [self.CM stopScan];
    }
    if([self scanForPeripherals]==0){
        devices = [[NSMutableArray alloc] init];
        [self.devicesTableView reloadData];
    };
}

- (IBAction)sliderOnChange:(NSSlider*)sender {
    _lblThreshold.stringValue = [NSString stringWithFormat:@"%.1f V", sender.floatValue];
}

- (IBAction)btnSetBatteryOnClick:(id)sender {
    int threshold = (_sliderThreshold.doubleValue-_sliderThreshold.minValue)/(_sliderThreshold.maxValue-_sliderThreshold.minValue)*63;
    if([bitalino isConnected] && ![bitalino isRecording]){
        [bitalino setBatteryThreshold:threshold];
    } else{
        NSRunAlertPanel(@"Error", @"Battery threshold can be set only when BITalino is connected and in idle mode.", @"OK", nil, nil);
    }

}

- (IBAction)btnStartOnClick:(id)sender {
    if([bitalino isConnected]){
        if(![bitalino isRecording]){
            NSMutableArray* inputs = [[NSMutableArray alloc] init];
            if([_switchA0 state]==NSOnState){
                [inputs addObject:@(0)];
            }
            if([_switchA1 state]==NSOnState){
                [inputs addObject:@(1)];
            }
            if([_switchA2 state]==NSOnState){
                [inputs addObject:@(2)];
            }
            if([_switchA3 state]==NSOnState){
                [inputs addObject:@(3)];
            }
            if([_switchA4 state]==NSOnState){
                [inputs addObject:@(4)];
            }
            if([_switchA5 state]==NSOnState){
                [inputs addObject:@(5)];
            }
            [bitalino startRecordingFromAnalogChannels:inputs withSampleRate:sampleRate numberOfSamples:50 samplesCompletion:^(BITalinoFrame *frame) {
                NSLog(@"Frame acquired: %ld", frame.seq);
            }];
        } else{
            [bitalino stopRecording];
        }
    } else{
        NSRunAlertPanel(@"Error", @"BITalino is not connected.", @"OK", nil, nil);
    }
}

- (IBAction)btnSetDigitalOutputOnClick:(id)sender {
    if([bitalino isConnected] /*&& ![bitalino isRecording]*/){
        NSArray* outputs = @[@([_switchD1 state]==NSOnState),
                             @([_switchD2 state]==NSOnState),
                             @([_switchD3 state]==NSOnState),
                             @([_switchD4 state]==NSOnState)
                             ];
        [bitalino setDigitalOutputs:outputs];
    }else{
        NSRunAlertPanel(@"Error", @"BITalino is not connected.", @"OK", nil, nil);        
    }
}

- (IBAction)btnSampleRateOnTap:(NSButton *)sender {
    switch (sampleRate) {
        case 1:
            sampleRate=10;
            break;
        case 10:
            sampleRate=100;
            break;
        case 100:
            sampleRate=1000;
            break;
        case 1000:
            sampleRate=1;
            break;
        default:
            break;
    }
    [sender setTitle:[NSString stringWithFormat:@"%d Hz", sampleRate]];
}

- (int)scanForPeripherals{
    if (self.CM.state != CBCentralManagerStatePoweredOn){
        NSLog(@"Bluetooth is not powered on.");
        return -1;
    }
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    [self.CM scanForPeripheralsWithServices:nil options:options];
    return 0;
}

#pragma BITalinoBLE delegates
-(void)bitalinoDidConnect:(BITalinoBLE *)bitalino{
    _lblStatus.stringValue=@"Connected";
    [_btnConnect setTitle:@"Disconnect"];
}

-(void)bitalinoDidDisconnect:(BITalinoBLE *)bitalino{
    _lblStatus.stringValue=@"Not connected";
    [_btnConnect setTitle:@"Connect"];
}

-(void)bitalinoBatteryThresholdUpdated:(BITalinoBLE *)bitalino{
    NSLog(@"Battery threshold changed to %.2f V", _sliderThreshold.floatValue);
}

-(void)bitalinoBatteryDigitalOutputsUpdated:(BITalinoBLE *)bitalino{
    NSLog(@"Digital outputs updated");
}

-(void)bitalinoRecordingStarted:(BITalinoBLE *)bitalino{
    [_btnStart setTitle:@"Stop"];
}

-(void)bitalinoRecordingStopped:(BITalinoBLE *)bitalino{
    [_btnStart setTitle:@"Start"];
}

#pragma BLE delegates
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    if(![self discoveredDeviceWithUUID:peripheral.identifier.UUIDString]){
        [devices addObject:peripheral];
        [self.devicesTableView reloadData];
    }
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
}

#pragma devicesTableView data source
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return devices.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *result = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    CBPeripheral* peripheral = [devices objectAtIndex:row];
    result.textField.stringValue = [NSString stringWithFormat:@"%@\n%@", peripheral.name, peripheral.identifier.UUIDString];
    return result;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 40;
}

#pragma helpers
-(BOOL)discoveredDeviceWithUUID:(NSString*)uuid{
    for(CBPeripheral* peripheral in devices){
        if([[peripheral.identifier UUIDString] isEqualToString:uuid]){
            return YES;
        }
    }
    return NO;
}

@end
