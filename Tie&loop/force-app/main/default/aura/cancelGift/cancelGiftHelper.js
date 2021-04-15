({
    exitModal : function(component, event, helper) {
        var refreshViewEvent = $A.get('e.force:refreshView');
        refreshViewEvent.fire();

        var navEvt = $A.get('e.force:navigateToSObject');
        var recordId = component.get('v.recordId');
        navEvt.setParams({
            "recordId": recordId 
        })
        navEvt.fire()
    }
})