
/// Action code begins


function MyAction( dev1 ) {
    
    consoleLog('jeejee1');
    
    var pp = dev1.talkingCapability.say('test number one');
    consoleLog('pp1: ' + pp);
    
    pp = dev1.talkingCapability.say('test number two');
    consoleLog('pp2: ' + pp);

    pp = dev1.talkingCapability.say('test number three');
    consoleLog('pp2: ' + pp);
    
}





var devTemp = new DeviceStub( 'nikkis' );


MyAction( devTemp );



