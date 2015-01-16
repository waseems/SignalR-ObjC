#import "SignalRClient.h"

static SignalRClient *signalRClient = nil;

// When native code plugin is implemented in .mm / .cpp file, then functions
// should be surrounded with extern "C" block to conform C function naming rules
extern "C" {
    
    // This takes a char* you get from Unity and converts it to an NSString* to use in your objective c code.
    NSString *CreateNSString(const char *string)
    {
        if (string != NULL)
            return [NSString stringWithUTF8String:string];
        else
            return [NSString stringWithUTF8String:""];
    }
    
    /*
     * init
     */
    
    void _srcInit()
    {
        NSLog(@"_srcInit");
        
        if (signalRClient == nil)
		{
            signalRClient = [[SignalRClient alloc] init];
		}
		else
		{
			NSLog(@"_srcInit: static SignalRClient instance already exists, not initializing a new one.");
		}
    }
    
    /*
     * hub connection methods
     */
    
    void _srcCreateConnection(const char* connectionId, const char* url, const char* query)
    {
        NSLog(@"_srcCreateConnection: %s, %s, %s", connectionId, url, query);
        
        if (signalRClient == nil) return;
        
        [signalRClient createConnection:CreateNSString(connectionId) toUrl:CreateNSString(url) withQuery:CreateNSString(query)];
    }
	
	void _srcCreateProxy(const char* hubName, const char* connectionId)
    {
        NSLog(@"_srcCreateProxy: %s, %s", hubName, connectionId);
        
        if (signalRClient == nil) return;
        
        [signalRClient createProxy:CreateNSString(hubName) inConnection:CreateNSString(connectionId)];
    }
	
	void _srcStartConnection(const char* connectionId, int transportType)
    {
        NSLog(@"_srcCreateProxy: %s, %d", connectionId, transportType);
        
        if (signalRClient == nil) return;
        
        [signalRClient startConnection:CreateNSString(connectionId) withTransport:(SRCTransportType)transportType];
    }
    
    void _srcStopConnection(const char* connectionId)
    {
        NSLog(@"_srcStopConnection: %s", connectionId);
        
        if (signalRClient == nil) return;
        
        [signalRClient stopConnection:CreateNSString(connectionId)];
    }
    
    void _srcSendMessage(const char* data, const char* connectionId)
    {
        NSLog(@"_srcSendMessage: %s, %s", data, connectionId);
        
        if (signalRClient == nil) return;
        
        [signalRClient sendMessage:CreateNSString(data) inConnection:CreateNSString(connectionId)];
    }
    
    /*
     * hub proxy methods
     */
	
	void _srcCallServerMethod(const char* methodName, const char* params, const char* hubName, const char* connectionId)
    {
        NSLog(@"_srcCallServerMethod: %s, %s, %s, %s", methodName, params, hubName, connectionId);
        
        if (signalRClient == nil) return;
        
        [signalRClient callServerMethod:CreateNSString(methodName) withArgs:CreateNSString(params) inHub:CreateNSString(hubName) inConnection:CreateNSString(connectionId)];
    }
	
	void _srcSubscribeToEvent(const char* eventName, const char* hubName, const char* connectionId)
    {
        NSLog(@"_srcSubscribeToEvent: %s, %s, %s", eventName, hubName, connectionId);
        
        if (signalRClient == nil) return;
        
        [signalRClient subscribeToEvent:CreateNSString(eventName) inHub:CreateNSString(hubName) inConnection:CreateNSString(connectionId)];
    }
	
    /*
     * callback setters
     */
    
	void _srcSetConnectionStateChangeCallback(SRCConnectionStateChangeCallback *callback)
	{
        NSLog(@"_srcSetConnectionStateChangeCallback");
        
        if (signalRClient == nil) return;
        
		[signalRClient setConnectionStateChangeCallback:callback];
	}
	
	void _srcSetMessageSentCallback(SRCConnectionCallback *callback)
	{
        NSLog(@"_srcSetMessageSentCallback");
        
        if (signalRClient == nil) return;
        
		[signalRClient setMessageSentCallback:callback];
	}
	
	void _srcSetMessageReceivedCallback(SRCConnectionCallback *callback)
	{
        NSLog(@"_srcSetMessageReceivedCallback");
        
        if (signalRClient == nil) return;
        
		[signalRClient setMessageReceivedCallback:callback];
	}
	
	void _srcSetServerMethodInvokedCallback(SRCProxyCallback *callback)
	{
        NSLog(@"_srcSetServerMethodInvokedCallback");
        
        if (signalRClient == nil) return;
        
		[signalRClient setServerMethodInvokedCallback:callback];
	}
	
	void _srcSetEventReceivedCallback(SRCProxyCallback *callback)
	{
        NSLog(@"_srcSetEventReceivedCallback");
        
        if (signalRClient == nil) return;
        
		[signalRClient setEventReceivedCallback:callback];
	}
}