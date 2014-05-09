
function generateCapabilityStub( deviceId, actionid, capabilityName, action, deviceStub ) {
    
    function GeneralStub( socket, deviceId, actionId, action, deviceStub ) {
        this.device = deviceStub;
        this.deviceId = deviceId;
    };
//    var socket = CONNECTION_POOL[ deviceId ];
    var CapabilityStub = require( ROOT + config.resources.capability_stubs + capabilityName + '.js' );
    
    var tempStub = new GeneralStub( socket, deviceId, actionid, action, deviceStub );
    
    for ( methodName in CapabilityStub ) {
        tempStub[ methodName ] = CapabilityStub[ methodName ]
    }
    
    return tempStub;
}