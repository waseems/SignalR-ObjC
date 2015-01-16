#import "HubProxy.h"
#import "SignalRClient.h"
#import "SRCEventData.h"
#import "SRCInvokedServerMethodData.h"

@implementation HubProxy

- (void)receiveEvent:(NSString *)eventName
          withParams:(NSString*)params
{
    SRCEventData *dataObj = [SRCEventData init];
    dataObj.EventName = eventName;
    dataObj.Data = params;
    
    NSString *dataString = [SignalRClient jsonSerialize:dataObj];
    
    self.eventReceived(self.connectionId, self.hubName, dataString);
}

- (void)receiveInvokedServerMethod:(id)data
                            withId:(NSString *)requestId
{
    SRCInvokedServerMethodData *dataObj = [SRCInvokedServerMethodData init];
    dataObj.RequestId = requestId;
    dataObj.Data = [SignalRClient jsonSerialize:data];
    
    NSString *dataString = [SignalRClient jsonSerialize:dataObj];
    
    self.serverMethodInvoked(self.connectionId, self.hubName, dataString);
}

@end