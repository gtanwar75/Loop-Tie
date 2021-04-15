({
    init : function(component, event, helper){
        setTimeout(() => {  
			helper.updateMeth(component,event,helper);        	
        }, 2000);
    },
    callCheckFieldValidation : function(component, event, helper) {
        if (typeof(component.scrollDebounce) !== 'undefined') {
            clearTimeout(component.scrollDebounce);
        }
        component.scrollDebounce = setTimeout($A.getCallback(function() {
            helper.checkFieldValidation(component, event, helper);
        }), 1000);
    }, 
    openHistoricalMessageModal : function(component, event, helper) {
        var currentState = component.get('v.messageModalOpen');
        component.set('v.messageModalOpen', !currentState);
    },
    getUserTeamMessages : function(component, event, helper){
        /*var getUserMessage = component.get('c.getUserMessages');
        var selectedTeam = component.get('v.selectedTeam');
        console.log('selectedTeam '+selectedTeam);
        getUserMessage.setParams({
            team : selectedTeam
        })
        
        getUserMessage.setCallback(this, function(res){
            var response = JSON.parse(res.getReturnValue());
            console.log('response>>',response)
            if(response.isSuccess){
                var body = response.results.body.data;
                console.log('body>>',body)
                component.set('v.previousMessagesList', body);
            }else{
                console.log('error messgae'+response.errMsg)
                component.set('v.errorMessage', response.errMsg);
            }
        });
        $A.enqueueAction(getUserMessage); */
    },
    handleMessageSelect : function(component, event, helper){
        var messageClicked = event.currentTarget.value;
        component.set('v.previousMessageSelected', messageClicked);
        component.set('v.fromPreviousMessage', true);
    },
    handleCustomDateSelection : function(component, event, helper){
        var recipientsList = component.get('v.recipientsList');
        var customDateField = component.get('v.customDateField');
        recipientsList.recipients.forEach(function(element){
            
            if(customDateField == 'Custom Dates'){
                element.scheduledAt = new Date().toISOString().slice(0, 10);
            }
            else{
                if(element[customDateField] != null){
                    var isFutureDate = helper.checkIfDateSelectedInFuture(component, event, helper, element[customDateField]);
                    if(!isFutureDate){
                        var newDate = helper.increaseDate(component, event, helper, element[customDateField]);
                        element.scheduledAt = newDate;
                    }else{
                        element.scheduledAt = element[customDateField];
                    }
                }else{
                    element.scheduledAt = new Date().toISOString().slice(0, 10);
                }
            }
        });
        component.set('v.recipientsList', recipientsList);
    },
    handleButtonStateChange : function(component, event, helper){
        var datePicker =  component.find('datePicker');
        for(var i = 0; i < datePicker.length; i++) {
            var dateErrorState = datePicker[i].get('v.dateError');
            if(dateErrorState){
                component.set('v.buttonDisabled', true);
                return;
            }
        }
        component.set('v.buttonDisabled', false);
        
        // To Remove the recipient from list if they dont have proper data.
        var data = event.getParam("data");
    },
    handleScheduleDateChanges : function(component, event, helper){
        var recipientsList = component.get('v.recipientsList');
        component.set('v.visibleRecipients', recipientsList.recipients.slice(0, component.get('v.visibleTiles')));
    },
    HandleDataMissingChange : function(component,event,helper){
        var recipientList = component.get("v.visibleRecipients");
        var dataMissingList = component.get("v.dataMissingRecipientList");
        component.set("v.visibleRecipients",dataMissingList);
        component.set("v.buttonDisabled",false);
    }, 
    update: function(component,event,helper){
        helper.updateMeth(component,event,helper);
         component.set("v.SearchKeyWord",'');
        helper.setSelectedRec(component,event,helper);
        component.set('v.errorMsg','');
    },
     handleComponentLookup : function(component, event, helper) {
    // get the selected User record from the event 	 
        var selectedUserGetFromEvent = event.getParam("recordByEvent");
          component.set("v.selectedRecord" , selectedUserGetFromEvent);
          helper.updateMeth(component,event,helper);
          
        
      
       
        var forclose = component.find("lookup-pill");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
  
        var forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');  
      
	},
     onfocus : function(component,event,helper){
       $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
         var getInputkeyWord = '';
         helper.searchHelper(component,event,getInputkeyWord);
        
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
       // get the search Input keyword   
         var getInputkeyWord = component.get("v.SearchKeyWord");
       // check if getInputKeyWord size id more then 0 then open the lookup result List and 
       // call the helper 
       // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
             var forOpen = component.find("searchRes");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
           
            
        }
        else{  
             component.set("v.listOfSearchRecords", null ); 
             var forclose = component.find("searchRes");
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');
          }
	},
    
  // function for clear the Record Selaction 
    clear :function(component,event,heplper){
         var pillTarget = component.find("lookup-pill");
         var lookUpTarget = component.find("lookupField"); 
        
         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');
        
         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');
      
         component.set("v.SearchKeyWord",null);
         component.set("v.listOfSearchRecords", null );
         component.set("v.selectedRecord", {} );   
    },    
    
})