
// Other helpers
function Console() {
    this.log = function( s ) {
        consoleLog( s );
    }
}


console = new Console();
log = console.log;

function Module() {
    this.exports = function() {
        // empty, but replaced later on
    }
}

module = new Module();


function getStubByDeviceIdParam( device_id_param ) {
    var r = undefined;
    for ( j in deviceStubs ) {
        var stub = deviceStubs[ j ];
        if ( device_id_param == 'device:' + stub.identity ) {
            log( 'match' );
            return stub;
        }
    }
    return r;
}

function replaceIdsWithDevices( paramsArray ) {
    for ( i in paramsArray ) {
        var param = paramsArray[ i ];
        if ( param instanceof Array ) {
            replaceIdsWithDevices( param );
        } else if ( param.slice( 0, 7 ) == 'device:' ) {
            log( 'device param: ' + param );
            paramsArray[ i ] = getStubByDeviceIdParam( param );
        } else {
            log( 'regular param: ' + param );
        }
    }
}






// Device stub generation

function DeviceStub( identity ) {
    consoleLog("Generating DeviceStub for " + identity);
    
    this.identity = identity;
    
    function TalkingCapability() {
        
        this.say = function( line, filter, pitch ) {
            console.log('tc::say');
            var retVal = invokeMethod(identity, 'TalkingCapability', 'say', [line, filter, pitch] );
            return retVal;
        }
        
    }
    
    this.talkingCapability = new TalkingCapability();
    
    
    function TestCapability() {
        
        this.initMeasurement = function() {
            var retVal = invokeMethod(identity, 'TestCapability', 'initMeasurement', [] );
            return retVal;
        }
        this.dummyMethod = function() {
            var retVal = invokeMethod(identity, 'TestCapability', 'dummyMethod', [] );
            return retVal;
        }
        this.calculateAverage = function() {
            var retVal = invokeMethod(identity, 'TestCapability', 'calculateAverage', [] );
            return retVal;
        }
    }
    
    this.testCapability = new TestCapability();
    
}





function createDevices( deviceModels ) {
    var deviceStubs = [];
    for ( i in deviceModels ) {
        var deviceId = deviceModels[ i ].identity;
        var deviceName = deviceModels[ i ].username;

        var deviceStub = new DeviceStub( deviceId );
//        var deviceStub = new DeviceStub( deviceId, deviceName, action );
//        if ( !CONNECTION_POOL[ deviceId ] ) {
//            throw ( 'Device with id: ' + deviceId + ' not connected!' );
//        }
        
        var capabilityNames = ( deviceModels[ i ].capabilities ).sort();
        for ( var i = 0; i < capabilityNames.length; i++ ) {
            var capa = capabilityNames[ i ];
            //deviceStub[ capa[ 0 ].toLowerCase() + capa.slice( 1 ) ] = generateCapabilityStub( deviceId, actionId, capabilityNames[ i ], action, deviceStub );
        }
        deviceStubs.push( deviceStub );
    };
    return deviceStubs;
}





