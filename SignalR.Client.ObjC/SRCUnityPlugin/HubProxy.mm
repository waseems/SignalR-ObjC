#import "HubProxy.h"
#import "SignalRClient.h"
#import "SRCEventData.h"
#import "SRCInvokedServerMethodData.h"

@implementation HubProxy

- (void)receiveInvokedServerMethod:(id)data
                            withId:(NSString *)requestId
{
    SRCInvokedServerMethodData *dataObj = [[SRCInvokedServerMethodData alloc] init];
    dataObj.RequestId = requestId;
    dataObj.Data = [SignalRClient jsonSerialize:data];
    
    NSString *dataString = [SignalRClient jsonSerialize:dataObj];
    
    self.serverMethodInvoked(self.connectionId, self.hubName, dataString);
}

@end