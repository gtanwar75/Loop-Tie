({
    checkFieldValidation : function(component, event, helper){
        var senderName = component.get('v.senderName');
        var selectedDate = component.get('v.selectedDate');
        var subjectLine = component.get('v.subjectLine');
        var message = component.get('v.message');
        var activeStep = component.get('v.activeStep');
        console.log('Validation Call');
        if(activeStep === 2){
            if(senderName === '' || selectedDate === undefined || selectedDate === null || subjectLine === '' ){
                component.set('v.buttonDisabled', true);
            }else{
                var datePicked = helper.formatDate(component, event, helper, selectedDate);
                var todaysDate = new Date();
                todaysDate.setHours(0,0,0,0);
                
                if(datePicked < todaysDate){
                    component.set('v.dateError', true);
                    component.set('v.buttonDisabled', true);
                }else{
                    component.set('v.dateError', false);
                    component.set('v.buttonDisabled', false);
                    component.set('v.textMessageError', false);
                    helper.setSelectedDateToAll(component, event, helper);
                }
            }
            if(message === ''){
                component.set('v.textMessageError', true);
            }else{
                component.set('v.textMessageError', false);
            }
            if(selectedDate === undefined || selectedDate === null){
                component.set('v.dateError', true);
            }
        }
    },
    formatDate : function(component, event, helper, date){
        var strArray = date.split("-");
        var dateStr = new Date(strArray[0], strArray[1]-1, strArray[2]);
        return dateStr;
    },
    checkIfDateSelectedInFuture : function(component, event, helper, date){
        var strArray = date.split("-");
        var dateStr = new Date(strArray[0], strArray[1]-1, strArray[2]);
        var todaysDate = new Date();
        todaysDate.setHours(0,0,0,0);
        dateStr.setHours(0,0,0,0);
        if( dateStr >= todaysDate){
            return true;
        }
        return false;
    },
    increaseDate : function(component, event, helper, date){
        var strArray = date.split("-");
        var todaysYear = new Date().toISOString().slice(0, 10);
        var strTodayArray = todaysYear.split("-");
        var todaysYear = parseInt(strTodayArray[0]);
        var todaysYearStr = String(todaysYear);
        var usersMonthStr = String(strArray[1]);
        var usersDayStr = String(strArray[2]);
        
        var dateStr = ""+ todaysYearStr + "-" + usersMonthStr + "-" + usersDayStr;
        var isFuture = helper.checkIfDateSelectedInFuture(component, event, helper, dateStr);
        
        if(isFuture){
            return dateStr;
        }else{
            todaysYear = parseInt(todaysYearStr) + 1;
            todaysYearStr = String(todaysYear);
            var dateStr = ""+ todaysYearStr + "-" + usersMonthStr + "-" + usersDayStr;
            return dateStr;
        }
    },
    updateMeth: function(component,event,helper){
        
        var senderSelection = component.get('v.senderSelection');
        var signType = '';
        if(component.find("signaturetype")){
            signType = component.find("signaturetype").get('v.value');
        }
        component.set("v.signType",signType);
        var getsignType = component.get('v.signType')
        if(senderSelection === 'same-sender'){
            var cmpTarget = component.find('sameSender');
            $A.util.addClass(cmpTarget, 'slds-show');
            var cmpTarget = component.find('sameSender');
            $A.util.removeClass(cmpTarget, 'slds-hide');
            var options = [
                {'label': 'Full Name', 'value': 'full-name'},
                {'label': 'First Name', 'value': 'first-name'},
                {'label': 'Custom', 'value': 'custom'}
            ]
           
            var currentUser =  component.get('v.currentUser'); //id of the current User
           
            var selectedUser = component.get('v.selectedRecord'); //selected pill record          
            var userList = component.get("v.userList"); //List of User coming from SendGift
            var userName = '';
            for(var i=0;i<userList.length;i++){
                if(selectedUser){
                    if(userList[i].Id === selectedUser.Id){
                        if(getsignType === 'full-name'){
                            userName = selectedUser.Name;
                            component.set('v.disabled',true)
                        }if(getsignType === 'first-name'){
                            userName = selectedUser.FirstName;
                            component.set('v.disabled',true)
                        }if(getsignType === 'custom'){
                            userName = selectedUser.Name;
                            component.set('v.disabled',false)
                        }
                    }
                }else if(userList[i].Id === currentUser){
                    selectedUser = userList[i];
                    if(getsignType === 'full-name'){
                        userName = userList[i].Name;
                        component.set('v.disabled',true)
                    }if(getsignType === 'first-name'){
                        userName = userList[i].FirstName;
                        component.set('v.disabled',true)
                    }if(getsignType === 'custom'){
                        userName = userList[i].Name;
                        component.set('v.disabled',false)
                    }
                }
            }    
            component.set("v.subjectLine",userName+' '+component.get("v.subjectPostMessage"));
            component.set("v.senderName",userName);
            component.set('v.signatureOptions',options)
            component.set('v.senderSelection',senderSelection)
            component.set("v.selectedRecord",selectedUser);
            
        }else{
            var cmpTarget = component.find('sameSender');
            $A.util.addClass(cmpTarget, 'slds-hide');
            var cmpTarget = component.find('sameSender');
            $A.util.removeClass(cmpTarget, 'slds-show');
            
            var options = [ {'label': 'Full Name', 'value': 'full-name'},
                           {'label': 'First Name', 'value': 'first-name'}
                          ]
            
            var selectedUserId = component.find("selectedUser1").get('v.value');
            if(selectedUserId === 'undefined' || selectedUserId===''){
                component.set("v.subjectLine",'');
                component.set("v.senderName",''); 
            }else{
                component.set("v.subjectLine",'{'+selectedUserId+'}'+' '+component.get("v.subjectPostMessage"));
                component.set("v.senderName",'{'+selectedUserId+'}' );
            }
            var subjectLineId = component.find('subjectLine');
            var subjectLineValue = subjectLineId.get('v.value');
            component.set('v.subLineId',subjectLineId) //here is the value of id
            component.set("v.selectedDiffSender",selectedUserId);
            component.set('v.signatureOptions',options)
            component.set('v.senderSelection',senderSelection)
            component.set('v.selectedUserId',selectedUserId)
            
            
        }
    },
    searchHelper : function(component,event,getInputkeyWord) {
       
	  // call the apex class method 
     var action = component.get("c.fetchUsersLookUp");
         console.log('Method Call');
      // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
          });
      // set a callBack  
      
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
         	console.log(state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue().userList;
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                console.log('storeResponse >>'+JSON.stringify(storeResponse));
                component.set("v.listOfSearchRecords", storeResponse);
            }else{
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
 
        });
        $A.enqueueAction(action);
    
    },
    setSelectedRec : function(component,event,helper){
        var selectedUser = component.get('v.selectedRecord')
        component.set('v.selectedRecord',selectedUser);
    },
    setSelectedDateToAll: function(component,event,helper){
        var recipientsList = component.get("v.recipientsList");
        var selectedDate = component.get('v.selectedDate');
        console.log('Recipient List '+JSON.stringify(recipientsList));
        console.log(recipientsList.length);
        if(recipientsList.recipients.length > 0){
            for(var i=0;i<recipientsList.recipients.length;i++){
                recipientsList.recipients[i].scheduledAt = selectedDate;
                console.log(recipientsList.recipients[i].scheduledAt);
            }
        }
        console.log('recipientsList'+JSON.stringify(recipientsList));
        component.set("v.recipientsList",recipientsList);
    }
    
   
})