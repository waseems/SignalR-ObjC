#import "HubProxy.h"
#import "SignalRClient.h"

@implementation HubProxy

- (void)receiveEvent:(NSString *)eventName
				withParams:(NSString*)params
{
    NSDictionary *data = @{@"EventName" : eventName,
                           @"Params" : params};
    
    NSString *dataString = [SignalRClient jsonSerialize:data];
    
    self.eventReceived(self.connectionId, self.hubName, dataString);
}

- (void)receiveInvokedServerMethod:(id)data
{
    NSString *dataString = [SignalRClient jsonSerialize:data];
    
    self.serverMethodInvoked(self.connectionId, self.hubName, dataString);
}

@end