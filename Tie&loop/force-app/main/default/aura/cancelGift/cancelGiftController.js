({
    handleNoClick : function(component, event, helper) {
        helper.exitModal(component, event, helper);
    },
    handleYesClick : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        var cancelGiftById = component.get("c.cancelGiftById");

        cancelGiftById.setParams({
                recordId: recordId
        });

        cancelGiftById.setCallback(this, function(res){
            var response = JSON.parse(res.getReturnValue());
            if(response.isSuccess){
                var details = response.results.body;
                helper.exitModal(component, event, helper);
            }else{
                component.set('v.errorMessage', response.errMsg);
            }
        });
        $A.enqueueAction(cancelGiftById);
    },    
    handleErrorMessageClose : function(component, event, helper) {
        component.set('v.errorMessage', '');
    }
})