consoleLog('TestLag');

var MyAction = {
    
    // the body
    body: function ( dev ) {
    
        dev.talkingCapability.say('jihaa');
    
        dev.testCapability.initMeasurement();
        i = 0;
        while ( i < 16 ) {
            ++i;
            dev.testCapability.dummyMethod();
        }
    
    
        dev.testCapability.calculateAverage();
    
    }
    
};

consoleLog('TestLag 2');


var devTemp = new DeviceStub( 'nikkis' );

MyAction.body( devTemp );

