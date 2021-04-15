({
    checkFieldValidation : function(component, event, helper){
        var selectedDate = component.get('v.scheduleAt');
            if(selectedDate === undefined || selectedDate === null){
                component.set('v.buttonDisabled', true);
                component.set('v.dateError', true);
                
            }else{
                var datePicked = helper.formatDate(component, event, helper, selectedDate);
                console.log('datePicked >>'+datePicked);
                var todaysDate = new Date();
                todaysDate.setHours(0,0,0,0);

                if(datePicked < todaysDate){
                    component.set('v.dateError', true);
                    component.set('v.buttonDisabled', true);
                }else{
                    component.set('v.dateError', false);
                    component.getEvent('dateValidation').fire();
                }
            }
            
    },
    formatDate : function(component, event, helper, date){
        var strArray = date.split("-");
        var dateStr = new Date(strArray[0], strArray[1]-1, strArray[2]);
        return dateStr;
    }
})