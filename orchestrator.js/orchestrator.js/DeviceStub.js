

function DeviceStub( identity ) {
    consoleLog("Generating DeviceStub for " + identity);
    
    function TalkingCapability() {
        
        this.say = function( line ) {
            consoleLog('tc::say');
            var retVal = invokeMethod('TalkingCapability', 'say', [line] );
            return retVal;
        }
        
    }
    
    this.talkingCapability = new TalkingCapability();
    
    
    function TestCapability() {
        
        this.initMeasurement = function() {
            var retVal = invokeMethod('TestCapability', 'initMeasurement', [] );
            return retVal;
        }
        this.dummyMethod = function() {
            var retVal = invokeMethod('TestCapability', 'dummyMethod', [] );
            return retVal;
        }
        this.calculateAverage = function() {
            var retVal = invokeMethod('TestCapability', 'calculateAverage', [] );
            return retVal;
        }
    }
    
    this.testCapability = new TestCapability();
    
}
