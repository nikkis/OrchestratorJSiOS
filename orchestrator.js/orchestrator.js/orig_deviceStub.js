
//consoleLog("creating a new deviceStub");

/*
this.DeviceStub = function( deviceIdentity ) {
    
    this.deviceIdentity = deviceIdentity;
    
    this.talkingCapability = function() {
        consoleLog("talking capability called!");
        
    };
    
}
*/
/*
module.exports = {
    this.talkingCapability = function() {
        consoleLog("talking capability called!");
    }
};
*/


//function DeviceStub( identity, name, action ) {
function DeviceStub( identity ) {
    this.identity = identity;
/*    this.deviceName = name;
    this.action = action;
    this.ownerName = name;
*/
    this.invoke = function( methodArguments ) {
        return invokeNativeMathodCall(this.deviceIdentity, 'TalkingCapability', 'say');
    }
    
    this.destroy = function() {
        //this.action = null;
        //this.identity = null;
        //this.deviceName = null;
        log( 'deviceStub for id ' + this.identity + ' destroyed!' );
    }
}