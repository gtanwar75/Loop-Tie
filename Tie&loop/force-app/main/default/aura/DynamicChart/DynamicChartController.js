({
    afterScriptsLoaded : function(component, event, helper){
        helper.doInit(component,event,helper);
    },  
    
    handleMemberSelected : function(component, event, helper){
        //helper.getGiftListByMember(component, event, helper);
        helper.doInit(component,event,helper);    
    }
})