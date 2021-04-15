({
	checkFieldValidation : function(component, event, helper){
        var value = component.get('v.value');
        var activeStep = component.get('v.activeStep');
        if(activeStep === 0){
            if(value === undefined || value === ''){
                component.set('v.buttonDisabled', true);
            }else{
                component.set('v.buttonDisabled', false);
            }
        }
    },
})