({
    doInit : function(component, event, helper) {
        helper.getGiftList(component, event, helper);
    },
    
    handleOptionSelected : function(component,event,helper){
        helper.getGiftList(component, event, helper);
    },
    
    handleMemberSelected : function(component,event,helper){
        //helper.getGiftListByMember(component, event, helper);
        helper.getGiftList(component, event, helper);      
    },
    
    getFilterRecords : function(component,event,helper){
        helper.getFilterRecords(component, event, helper);      
    },
     
    downloadCsv : function(component,event,helper){
        var stockData = component.get("v.giftList");
        var csv = helper.convertArrayOfObjectsToCSV(component,stockData);   
        
        if (csv == null){return;} 
            
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self';
        hiddenElement.download = 'Champaign Member Gift Status.csv';
        document.body.appendChild(hiddenElement);
        hiddenElement.click();
    },
     
    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.displaySpinner", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.displaySpinner", false);
    }
})