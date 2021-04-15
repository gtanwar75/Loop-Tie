({
    init : function(component, event, helper){
        var steps = [
            {label: "Select Recipients"},
            {label: "Select Gift Collection"},
            {label: "Customize Gift Email"},
            {label: "Customize Design"},
            {label: "Review  Send"}
        ]

        //--get todays date
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1; //January is 0!
        var yyyy = today.getFullYear();
        var today = yyyy +'-'+ mm +'-'+ dd;
        component.set('v.selectedDate', today);
        //--/todays date

        var userLoggedIn = component.get('v.userLoggedIn');
        if(!userLoggedIn){
            component.set('v.isLoading', true);
        }

        component.set('v.steps', steps);
        component.set('v.totalSteps', steps.length);
        var isListView = component.get('v.isListView');
        var recordId = component.get('v.recordId');
        var filterId = component.get('v.filterId');
        var getRecipients = component.get("c.getRecipientInfo");
        var selectedRecipientIds = component.get('v.selectedRecipientIds');
        var valueStr = component.get('v.value');
        var emailsList = [];
        var memberType = component.get('v.memberType');
           
            if(!isListView){ //isListView  = false
                console.log('selectedRecipientIdsList !'+selectedRecipientIdsList);
                console.log('recordId @@'+recordId);
                var selectedRecipientIdsList=[recordId]
                getRecipients.setParams({
                queryRecordIds: selectedRecipientIdsList,
            });
            }else{
                var selectedRecipientIdsList = JSON.parse(selectedRecipientIds);
                console.log('selectedRecipientIdsList @@'+selectedRecipientIdsList);
                component.set('v.selectedRecipientIdsList', selectedRecipientIdsList);
                getRecipients.setParams({
                    queryRecordIds: selectedRecipientIdsList,
                });
            }

            if(!isListView){
                getRecipients.setCallback(this, function(res){
                    var response = JSON.parse(res.getReturnValue());
                    if(response.isSuccess){
                        var getRecipientsResponse = response.results;
                        var objectName = getRecipientsResponse.objectName;
                        
                        if(objectName === 'Lead'){
                            component.set('v.multiLookupObjType', 'Lead');
                        }
                        if(objectName === 'Campaign' && memberType === 'Lead'){
                            component.set('v.multiLookupObjType', 'Lead');
                        }
                        if(objectName === 'Campaign' && memberType === 'Contact'){
                            component.set('v.multiLookupObjType', 'Contact');
                        }
                        if(objectName === 'Campaign' && memberType === 'Campaign'){
                            component.set('v.multiLookupObjType', 'Campaign');
                        }

                        var value = '';
                        var missingEmailsList = [];
                        getRecipientsResponse.recipients.forEach(function(elements){
                            if(elements.email != null){
                                value = value + elements.id + ';';
                            }else{
                                missingEmailsList.push(elements.id);
                            }
                        });
                        component.set('v.recipientIdsMissingEmail', missingEmailsList);
                        component.set('v.value', value);
                        //alert('valueeeeeee'+value)
                        component.set('v.senderName', getRecipientsResponse.senderName);
                        component.set('v.senderName', getRecipientsResponse.senderName);
                        var subStr = getRecipientsResponse.senderName + ' sent you a gift!';
                        component.set('v.subjectLine', subStr);
                        component.set('v.entryPointObj', getRecipientsResponse.objectName);
                        helper.checkFieldValidation(component, event, helper);
                    }else{
                         component.set('v.errorMessage', response.errMsg);
                    }
                });
                $A.enqueueAction(getRecipients);

            }else if(isListView && !$A.util.isEmpty(selectedRecipientIdsList)){
                getRecipients.setCallback(this, function(res){
                    var response = JSON.parse(res.getReturnValue());
                    if(response.isSuccess){
                        var getRecipientsResponse = response.results;
                        console.log(getRecipientsResponse);
                        var objectName = getRecipientsResponse.objectName;
                        
                        
                        
                        if(objectName === 'Lead'){
                            component.set('v.multiLookupObjType', 'Lead');
                        }
                        if(objectName === 'Campaign'){
                            component.set('v.multiLookupObjType', 'Campaign');
                        }
                        
                        var value = '';
                        var missingEmailsList = [];
                        getRecipientsResponse.recipients.forEach(function(elements){
                            if(elements.email != null){
                                if(!emailsList.includes(elements.email)){
                                    emailsList.push(elements.email);
                                    value = value + elements.id + ';';
                                }else{
                                    //have duplicate emails
                                    component.set('v.duplicateEmailsError', true);
                                }
                            }else{
                                missingEmailsList.push(elements.id);
                            }
                        });
                        component.set('v.recipientIdsMissingEmail', missingEmailsList);
                        component.set('v.value', value);
                        component.set('v.senderName', getRecipientsResponse.senderName);
                        var subStr = getRecipientsResponse.senderName + ' sent you a gift!';
                        component.set('v.subjectLine', subStr);
                        component.set('v.entryPointObj', getRecipientsResponse.objectName);
                        helper.checkFieldValidation(component, event, helper);
                    }else{
                         component.set('v.errorMessage', response.errMsg);
                    }
                });
                $A.enqueueAction(getRecipients);
            }else{
                var getListViewObjType = component.get("c.getListViewObjType");
                getListViewObjType.setParams({
                        listViewId: filterId
                });

                getListViewObjType.setCallback(this, function(res){
                    var response = JSON.parse(res.getReturnValue());
                    if(response.isSuccess){
                        var getListViewObjTypeResponse = response.results;
                        var objectName = getListViewObjTypeResponse.objectName;
						
                        if(objectName === 'Lead'){
                            component.set('v.multiLookupObjType', 'Lead');
                        }
						
                        component.set('v.senderName', getListViewObjTypeResponse.senderName);
                        var subStr = getListViewObjTypeResponse.senderName + ' sent you a gift!';
                        component.set('v.subjectLine', subStr);
                        component.set('v.entryPointObj', getListViewObjTypeResponse.objectName);
                        helper.checkFieldValidation(component, event, helper);
                    }else{
                         component.set('v.errorMessage', response.errMsg);
                    }
                });
                $A.enqueueAction(getListViewObjType);
            }
            //get saved team webhook
            var getWebHookURL = component.get("c.getWebHookURL");
            getWebHookURL.setCallback(this, function(res){
                var response = JSON.parse(res.getReturnValue());
                if(response.isSuccess){
                    var webhook = response.results.pboUrl;
                    component.set('v.webhookURL', webhook);
                    helper.verifyUserHasApiToken(component, event, helper);
                }else{
                     component.set('v.errorMessage', response.errMsg);
                     component.set('v.isLoading', false);
                }
            })
            $A.enqueueAction(getWebHookURL);
        
         //get current logged and all user
        var action = component.get("c.getUsers");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.userList",response.getReturnValue().UserList);
                component.set('v.currentUser',response.getReturnValue().currUserId) //hiding this and get from user lookup
            }else if(state === "ERROR"){
              
            }
             
        });
        $A.enqueueAction(action);
        
          
        var action = component.get("c.getFieldsByObject");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var arrayMapKeys = [];
                var result = response.getReturnValue();
                for(var key in result){
                    arrayMapKeys.push({
                        key: key, 
                        value: result[key]
                    });
                }
                component.set("v.userLookupFields",arrayMapKeys);
            }else if(statue === "ERROR"){
                
            }
          });
        $A.enqueueAction(action);

    },
    handleNextClick : function(component, event, helper) {
        var activeStep = component.get('v.activeStep');
        var steps = component.get('v.steps');
        var totalSteps = steps.length;
        var value = component.get('v.value');
        if(activeStep === 4) { 
			
            helper.createGiftRequestObject(component, event, helper);
            helper.verifyTeamWebHook(component, event, helper);
            component.set('v.isLoading', true);

        } else {
            var isValid = helper.checkFieldValidation(component, event, helper);
            if(isValid){
                console.log('activeStep >>'+activeStep);
                if(activeStep === 1){
                    helper.getMultiLookupRecipientIds(component, event, helper, value);
                }else if(activeStep === 2 && component.get('v.selectedDiffSender') && component.get('v.senderSelection') == 'different-sender'){
                    helper.getDifferentSender(component,event,helper);
                }else{
                    component.set('v.activeStep', ++activeStep);
                    component.set('v.stepHeader', steps[activeStep].label);
                    helper.calculateProgressPercent(component, helper);
                }
                if(activeStep === 4){
                    var recipientsList = component.get('v.recipientsList');
                    component.set('v.recipientsList', recipientsList);
                    helper.getPreviewLink(component, event, helper);
                }
            }
        }
    },
    handlePreviousClick : function(component, event, helper) {
        var activeStep = component.get('v.activeStep');
        var steps = component.get('v.steps');
        var totalSteps = steps.length;
        var listView = component.get('v.isListView');
        var listViewId = component.get('v.filterId');

        if(listView){
            if(activeStep === 0){
                var navEvt = $A.get("e.force:navigateToList");
                navEvt.setParams({
                    "listViewId": listViewId,
                });
                navEvt.fire();
            }else{

                component.set('v.errorMessage', '');
                component.set('v.activeStep', --activeStep);
                component.set('v.stepHeader', steps[activeStep].label);
                helper.calculateProgressPercent(component, helper);
                helper.checkFieldValidation(component, event, helper);
            }
        }else{
            if(activeStep === 0) {
                var navEvt = $A.get('e.force:navigateToSObject');
                var recordId = component.get('v.recordId');
                navEvt.setParams({
                    "recordId": recordId
                })
                navEvt.fire()
            } else {

                component.set('v.errorMessage', '');
                component.set('v.activeStep', --activeStep);
                component.set('v.stepHeader', steps[activeStep].label);
                helper.calculateProgressPercent(component, helper);
                helper.checkFieldValidation(component, event, helper);
            };
        }
    },
    handleExitClick : function(component, event, helper) {
        var listView = component.get('v.isListView');
        var listViewId = component.get('v.filterId');
        if(listView){
            var navEvt = $A.get("e.force:navigateToList");
            navEvt.setParams({
                "listViewId": listViewId
            });
            navEvt.fire();
        }else{
            var navEvt = $A.get('e.force:navigateToSObject');
            var recordId = component.get('v.recordId');
            navEvt.setParams({
                "recordId": recordId
            })
            navEvt.fire()
        }
        component.set('v.exitModalShown', false);
    },
    handlePreviewButtonClick : function(component, event, helper) {
        var url = component.get('v.previewLink');
        window.open(url,'_blank');
    },
    handleErrorMessageClose : function(component, event, helper) {
        component.set('v.errorMessage', '');
    },
    handleShowExitModal : function(component, event, helper) {
        var currentState = component.get('v.exitModalShown');
        component.set('v.exitModalShown', !currentState);
    },
    handleMissingChangeValue : function(component,event,helper){
        var recipientMainList = component.get("v.recipientsList");
        var recipientList = recipientMainList.recipients;
        var value = '';
        var recipientId = event.getParam("data");
        var idx = 0;
        var updatedRecipientList = new Array();
        recipientList.forEach(function(recipient){
            if(recipient.id != recipientId){
                value += recipient.id+';'; 
                updatedRecipientList.push(recipient);
            }
        });
        recipientMainList.recipients = updatedRecipientList;
        component.set("v.recipientsList",recipientMainList);
        component.set('v.value',value);
        if(component.get("v.dataMissingRecipientList").length == 0){
            component.set("v.buttonDisabled",false);
        }
    },
    
})