
/// Action code begins


function MyAction( dev1 ) {
    
    consoleLog('jeejee1');
    
    var pp = dev1.talkingCapability.say('mun line 1');
    consoleLog('pp1: ' + pp);
    
    pp = dev1.talkingCapability.say('mun line 2');
    consoleLog('pp2: ' + pp);
    
}



/// generate devices


function DeviceStub( identity ) {
    
    function TalkingCapability() {

        this.say = function( line ) {
            consoleLog('tc::say');
            
            return 'paluuarvo! ' + line;
        }
    
    }
    
    this.talkingCapability = new TalkingCapability();
    
}




function generateCapabilityStub( deviceId, actionid, capabilityName, action, deviceStub ) {
    
    function GeneralStub( socket, deviceId, actionId, action, deviceStub ) {
        this.Fiber = require( 'fibers' );
        this.socket = socket;
        this.actionId = actionId;
        //this.action = action;
        this.device = deviceStub;
        this.deviceId = deviceId;
    };
    var socket = CONNECTION_POOL[ deviceId ];
    var CapabilityStub = require( ROOT + config.resources.capability_stubs + capabilityName + '.js' );
    
    var tempStub = new GeneralStub( socket, deviceId, actionid, action, deviceStub );
    
    for ( methodName in CapabilityStub ) {
        tempStub[ methodName ] = CapabilityStub[ methodName ]
    }
    
    return tempStub;
}


function createDevices( deviceModels, actionId, action ) {
    var deviceStubs = [];
    for ( i in deviceModels ) {
        var deviceId = deviceModels[ i ].identity;
        var deviceName = deviceModels[ i ].username;
        
        var deviceStub = new DeviceStub( deviceId, deviceName, action );
        if ( !CONNECTION_POOL[ deviceId ] ) {
            throw ( 'Device with id: ' + deviceId + ' not connected!' );
        }
        
        var capabilityNames = ( deviceModels[ i ].capabilities ).sort();
        var capabiltitiesAndColors = [];
        for ( var i = 0; i < capabilityNames.length; i++ ) {
            var capa = capabilityNames[ i ];
            deviceStub[ capa[ 0 ].toLowerCase() + capa.slice( 1 ) ] = generateCapabilityStub( deviceId, actionId, capabilityNames[ i ], action, deviceStub );
            //deviceStubs.push(deviceStub);
        }
        deviceStubs.push( deviceStub );
    };
    return deviceStubs;
}




//var devTemp = new DeviceStub( 'nikkis' );

var devicesModels = [];
deviceModels.push( {
                  identity: 'nikkis@iphone',
                  username: 'nikkis',
                  capabilities: ['TalkingCapability']
                  } );

deviceModels.push( {
                  identity: 'nikkis@ipad',
                  username: 'nikkis',
                  capabilities: ['TalkingCapability']
                  } );

var actionId = 'id343124334343434';





MyAction( devTemp );



