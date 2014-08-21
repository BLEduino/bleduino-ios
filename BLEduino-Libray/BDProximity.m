//
//  BDProximity.m
//  BLEduino
//
//  Created by Ramon Gonzalez Rodriguez on 8/19/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import "AppDelegate.h"
#import "BDProximity.h"
#import "ProximityAlert.h"
#import "ProximityViewController.h"

@interface BDProximity()
//Proximity
//Alerts
@property (strong) NSMutableArray *distanceAlerts;
@property BOOL distanceAlertsEnabled;

//Current Distance
@property (strong) BDQueue *rssiReadings;
@property DistanceRange currentDistance;

@property (strong) NSMutableArray *calibrationReadings;
@property BOOL isCalibrating;
@property BOOL isMonitoring;
@end

@implementation BDProximity

#pragma mark -
#pragma mark Access to Proximity Monitor
/****************************************************************************/
/*				        Accesing Proximity Monitor    				        */
/****************************************************************************/
-(id)init {
    if (self = [super init]) {
        
        //Set notifications to monitor Alerts Enabled control, and distance calibration, and RSSI readings.
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(beginDistanceCalibration:)
                       name:PROXIMITY_BEGIN_CALIBRATION object:nil];
        
        [center addObserver:self selector:@selector(bleduinoDidUpdateRSSI:)
                       name:PROXIMITY_NEW_RSSI_READING object:nil];
        
        //Setup distance ranges.
        self.immediateRSSI = -48.0;
        self.nearRSSI = -67;
        self.farRSSI = -90;

        //Setup distance formula values. 
        self.pathLoss = 1.8;
        self.measuredPower = [NSNumber numberWithFloat:-60];
        
        //Setup aggregated RSSI queue.
        self.rssiReadings = [[BDQueue alloc] initWithCapacity:5];
    }
    return self;
}


+ (BDProximity *)sharedMonitor
{
    static id sharedMonitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMonitor = [[[self class] alloc] init];
    });
    return sharedMonitor;
}

- (void)startMonitoring
{
    if(!self.isMonitoring)
    {
        self.isMonitoring = YES;
        [self monitorBleduinoDistances];
    }
}

- (void)stopMonitoring
{
    self.isMonitoring = NO;
}

- (void)startCalibration
{
    if(!self.isCalibrating)
    {
        self.isCalibrating = YES;
        [self performSelector:@selector(sendFinishedDistanceCalibrationNotification) withObject:nil afterDelay:10];
    }
}

#pragma mark -
#pragma mark - Proximity Calibration
/****************************************************************************/
/*                          Proximity Calibration    				        */
/****************************************************************************/
- (void)beginDistanceCalibration:(NSNotification *)notification
{
    self.isCalibrating = YES;
    [self performSelector:@selector(sendFinishedDistanceCalibrationNotification) withObject:nil afterDelay:10];
}

- (void)sendFinishedDistanceCalibrationNotification
{
    //Calibration is over.
    self.isCalibrating = NO;
    self.measuredPower = [self.calibrationReadings valueForKeyPath:@"@avg.self"];
    [self.calibrationReadings removeAllObjects];
    
    //Notify proximity controller so the veiw can be updated back to displaying current distance.
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:PROXIMITY_FINISHED_CALIBRATION object:self];
    
    //Notify delegate.
    [self.delegate bleduino:self.monitoredBleduino didFinishCalibration:self.measuredPower];
}

#pragma mark -
#pragma mark - Proximity Distance Readins
/****************************************************************************/
/*                      Proximity Distance Readings    				        */
/****************************************************************************/
- (void)monitorBleduinoDistances
{
    if(self.isMonitoring)
    {
        self.monitoredBleduino.delegate = self;
        [self.monitoredBleduino readRSSI];
        
        [self performSelector:@selector(monitorBleduinoDistances) withObject:nil afterDelay:1];
    }
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    if(error)//Any errors?
    {
        //Notify delegate
        [self.delegate bleduino:peripheral didFailToUpdateValueForDistanceWithError:error];
    }
    else
    {
        NSNumber *currentRSSI = peripheral.RSSI;
        BOOL isValidReading = [self validateReading:currentRSSI];
        
        //Only keep 5s worth of readings.
        if([[self.rssiReadings array] count] == 5)[self.rssiReadings dequeue];
        [self.rssiReadings enqueue:currentRSSI];
        
        if(isValidReading && currentRSSI != nil)
        {
            //Collect reading.
            self.currentDistance = [self calculateDistanceRange:currentRSSI];
            NSNumber *min = [self calculateDistance:[[self.rssiReadings array] valueForKeyPath:@"@max.self"]];
            NSNumber *max = [self calculateDistance:[[self.rssiReadings array] valueForKeyPath:@"@min.self"]];
            //NOTE: Max RSSI value equals less loss of signal, hence minimum (closer) distance.
            
            //Is user calibrating rignt now?
            if(self.isCalibrating)[self.calibrationReadings addObject:currentRSSI];
            
            //Send notification
            NSDictionary *distanceInfo = @{@"CurrentDistance":[NSNumber numberWithLong:self.currentDistance],
                                           @"MaxDistance":max,
                                           @"MinDistance":min,
                                           @"RSSI":currentRSSI};
            
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:PROXIMITY_NEW_DISTANCE object:self userInfo:distanceInfo];
            
            //Notify delegate
            [self.delegate bleduino:peripheral
             didUpdateValueForRange:self.currentDistance
                        maxDistance:max
                        minDistance:min
                           withRSSI:currentRSSI];
        }
        
        [self performSelector:@selector(monitorBleduinoDistances) withObject:nil afterDelay:1];
    }
}

- (void)bleduinoDidUpdateRSSI:(NSNotification *)notification
{
    NSDictionary *payload = notification.userInfo;
    CBPeripheral *peripheral = [payload objectForKey:@"Peripheral"];
    NSError *error = [payload objectForKey:@"Error"];
    
    if(error)//Any errors?
    {
        //Notify delegate
        [self.delegate bleduino:peripheral didFailToUpdateValueForDistanceWithError:error];
    }
    else
    {
        NSNumber *currentRSSI = peripheral.RSSI;
        BOOL isValidReading = [self validateReading:currentRSSI];
        
        if(isValidReading && currentRSSI != nil)
        {
            //Collect reading. Only keep 5s worth of readings.
            if([[self.rssiReadings array] count] == 5)[self.rssiReadings dequeue];
            [self.rssiReadings enqueue:currentRSSI];
            
            //Setup readings for notification.
            NSNumber *agregatedRSSI =[[self.rssiReadings array] valueForKeyPath:@"@avg.self"];
            self.currentDistance = [self calculateDistanceRange:agregatedRSSI];
            NSNumber *min = [self calculateDistance:[[self.rssiReadings array] valueForKeyPath:@"@max.self"]];
            NSNumber *max = [self calculateDistance:[[self.rssiReadings array] valueForKeyPath:@"@min.self"]];
            //NOTE: Max RSSI value equals less loss of signal, hence minimum (closer) distance.
            
            //Is user calibrating rignt now?
            if(self.isCalibrating)[self.calibrationReadings addObject:currentRSSI];
            
            //Send notification
            NSDictionary *distanceInfo = @{@"CurrentDistance":[NSNumber numberWithLong:self.currentDistance],
                                           @"MaxDistance":max,
                                           @"MinDistance":min,
                                           @"RSSI":agregatedRSSI};
            
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:PROXIMITY_NEW_DISTANCE object:self userInfo:distanceInfo];
            
            //Notify delegate
            [self.delegate bleduino:peripheral
             didUpdateValueForRange:self.currentDistance
                        maxDistance:max
                        minDistance:min
                           withRSSI:currentRSSI];
        }
    }
}

- (BOOL) validateReading:(NSNumber *)rssi
{
    return ([rssi integerValue] <= 0);
}

- (DistanceRange) calculateDistanceRange:(NSNumber *)aRSSI
{
    DistanceRange distance;
    if([aRSSI floatValue] >= self.immediateRSSI)
    {
        distance = Immediate;
    }
    else if (self.measuredPower != nil &&
             ([aRSSI floatValue] <= ([self.measuredPower floatValue] + 5.0) &&
              [aRSSI floatValue] >= ([self.measuredPower floatValue] - 5.0)))
    {
    /*
     * Example: Measure power: -60, aRSSI: -61
     * -65 <= -61 <= -55
     */
        distance = VeryNear;
    }
    else if([aRSSI floatValue] >= self.nearRSSI)
    {
        distance = Near;
    }
    else if([aRSSI floatValue] >= self.farRSSI)
    {
        distance = Far;
    }
    else if([aRSSI floatValue] < self.farRSSI)
    {
        distance = VeryFar;
    }
    else
    {
        distance = Near;
    }
    
    return distance;
}


// Calculates distance in meters.
- (NSNumber *)calculateDistance:(NSNumber *)aRSSI
{
    if(aRSSI >= self.measuredPower)
    {
        return [NSNumber numberWithFloat:-1];
    }
    
    //(Measured Power - (Current) RSSI) / (10 * Path Loss Exponent)
    float exponent = ([self.measuredPower floatValue] - [aRSSI floatValue]) / (10.0 * self.pathLoss);
    float d = pow(10.0, exponent);
    
    NSNumber *distance = [NSNumber numberWithFloat:d];
    return distance;
}

@end
