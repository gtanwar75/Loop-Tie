({
    calculateProgressPercent: function(component, event, helper){
        var steps = component.get('v.steps');
        var totalSteps = steps.length;
        var activeStep = component.get('v.activeStep');
        var progressPercent = (100 / (totalSteps - 1)) * activeStep;
        component.set('v.progressPercent', progressPercent <= 100 ? progressPercent : 100);
    },
    getUserTeams: function(component, event, helper){
        var getTeams = component.get("c.getUserTeams");
        var teamsList = [];
        getTeams.setCallback(this, function(res){
            var response = JSON.parse(res.getReturnValue());
            if(response.isSuccess){
                var teams = response.results.body;
                teams.data.forEach(function(element){
                        teamsList.push(element.id);
                });
                component.set('v.teams', teamsList);
                component.set('v.isLoading', false);
                component.set('v.userLoggedIn', true);
            }else{
                if(response.statusCode === 401){
                    helper.getUserAuthTokenURL(component, event, helper);
                    component.set('v.userLoggedIn', false);
                    component.set('v.isLoading', false);
                }
                component.set('v.errorMessage', response.errMsg);
            }
        });
        $A.enqueueAction(getTeams);
    },
    verifyUserHasApiToken: function(component, event, helper){
        var userHasToken = component.get("c.verifyUserHasApiToken");
        userHasToken.setCallback(this, function(res){
            var response = JSON.parse(res.getReturnValue());
            if(response.isSuccess){
                var hastoken = response.results.hasToken;
                if(hastoken){
                    //user has token so get teams
                    helper.getUserTeams(component, event, helper);

                }else{
                    helper.getUserAuthTokenURL(component, event, helper);
                    component.set('v.userLoggedIn', false);
                    component.set('v.isLoading', false);
                }
            }else{
                component.set('v.errorMessage', response.errMsg);
            }
        });
        $A.enqueueAction(userHasToken);
    },
    getUserAuthTokenURL : function(component, event, helper){
        var requestAuthToken = component.get("c.requestAuthTokenURL");
        requestAuthToken.setCallback(this, function(res){
        var response = JSON.parse(res.getReturnValue());
            if(response.isSuccess){
                component.set('v.redirectURL', response.results.url);
            }else{
                component.set('v.errorMessage', response.errMsg);
            }
        });
        $A.enqueueAction(requestAuthToken);
    },
    getMultiLookupRecipientIds : function(component, event, helper, value){
        var recipientIdsList = value.split(";");
        var tempArray = [];
        //clean array
        recipientIdsList.forEach(function(element){
            if(element != ""){
                tempArray.push(element);
            }
        });
        recipientIdsList = tempArray;
        component.set('v.recipientIdsList', recipientIdsList);
        var multiLookupObjType = component.get('v.multiLookupObjType');
        var getRecipientIdsList = component.get('v.recipientIdsList');
        
        helper.getMultiLookupRecipientsInfo(component, event, helper, multiLookupObjType, recipientIdsList);
    },
    getMultiLookupRecipientsInfo : function(component, event, helper, obj, recipientIdsList){
        var getRecipientInfo = component.get("c.getMultiLookupRecipientInfo");
        var recordId = component.get('v.recordId');
        var oldRecipient = component.get('v.recipientsList');
        
        console.log(typeof oldRecipientList);
        var recipients = {};
        component.set("v.isLoading",true);
        getRecipientInfo.setParams({
                obj : obj,
                recipients : recipientIdsList,
                recordId : recordId
        }); 
        getRecipientInfo.setCallback(this, function(res){
            var response = JSON.parse(res.getReturnValue());
            component.set("v.isLoading",false);
            if(response.isSuccess){
                var recipients = response.results;
                if(oldRecipient){
                    oldRecipient.recipients.forEach(function(oldRec){
                        recipients.recipients.forEach(function(newRec){
                            if(oldRec.id == newRec.id && oldRec.scheduledAt != newRec.scheduledAt){
                                newRec.scheduledAt = oldRec.scheduledAt;
                            }
                        });
                    });
                }
                component.set('v.recipientsList', recipients);
                var dateFields = response.results.dateFields;
                console.log(JSON.stringify(component.get('v.recipientsList')));
                component.set('v.dateFields', dateFields.dateFields);
                component.set('v.visibleRecipients', recipients.recipients.slice(0, component.get('v.visibleTiles')));
                /*if(component.get('v.selectedDiffSender') && component.get('v.senderSelection') == 'different-sender'){
                    helper.getDifferentSender(component,event,helper);
                }else{
                }*/
                var activeStep = component.get('v.activeStep');
                    var steps = component.get('v.steps');
                    component.set('v.activeStep', ++activeStep);
                    component.set('v.stepHeader', steps[activeStep].label);
                    helper.calculateProgressPercent(component, helper);
                
            }else{
                component.set('v.errorMessage', response.errMsg);
            }
        });
        $A.enqueueAction(getRecipientInfo);
		
    },
    createGiftRequestObject : function(component, event, helper){
        var recipientsList = component.get('v.recipientsList');
        var multiLookupObjType = component.get('v.multiLookupObjType');
        var selectedDiffSender = component.get('v.selectedDiffSender');
        var selectedCollection = component.get('v.selectedCollection');
        var senderSelection = component.get("v.senderSelection");
        var senderName = component.get('v.senderName');
        var message = component.get('v.message');
        var subject = component.get('v.subjectLine');
        var logoId = component.get('v.selectedLogoId');
        var imageId = component.get('v.selectedImageId');
        var giftObj = {};
        if($A.util.isEmpty(recipientsList)){
            return;
        }else{
            var recipientsArray = [];
            recipientsList.recipients.forEach(function(element){
                var selectedDate = element.scheduledAt;
                var dateTime = helper.formatDate(component, event, helper, selectedDate);
                var tmpRecipientObj = {
                    'name' : element.name,
                    'email' : element.email,
                    'scheduled_at' : dateTime,
                    'from':element.from,
                    'subject':element.subject,
                    'cc_email':element.cc_email
                }
                recipientsArray.push(tmpRecipientObj);
            })
            
            
            if(senderSelection == 'different-sender'){
                giftObj.gift = {
                    'collection' : selectedCollection,
                    'message' : message,
                    'from' : senderName,
                    'logo_id': logoId,
                    'design_id' : imageId,
                    'recipients_attributes' : recipientsArray
                }
            }else{
                giftObj.gift = {
                    'collection' : selectedCollection,
                    'message' : message,
                    'from' : senderName,
                    'logo_id': logoId,
                    'subject':subject,
                    'design_id' : imageId,
                    'recipients_attributes' : recipientsArray
                }
                
            }
            component.set('v.giftRequestObj', giftObj);
            console.log('Gift Request Object >>'+JSON.stringify(component.get('v.giftRequestObj')));
        }
        return giftObj;
    },
    getDifferentSender: function(component,event,helper,activeStep){
            var recipientsList = component.get('v.recipientsList');
            var multiLookupObjType = component.get('v.multiLookupObjType');
            var getDifferent = component.get('c.getDifferent');
            var selectedDiffSender = component.get('v.selectedDiffSender');
        	component.set("v.isLoading",true);
        	console.log('Different Sender Called');
            getDifferent.setParams({
                obj : multiLookupObjType,
                recipientsList: JSON.stringify(recipientsList.recipients),
                selectedDiffSender : selectedDiffSender,
                subject: component.get("v.subjectLine"),
                signatureType : component.get('v.signatureType')
            });
            getDifferent.setCallback(this,function(res){
                component.set("v.isLoading",false);
                var response = res.getReturnValue();
                recipientsList.recipients = response;
                console.log('recipientsList >>'+JSON.stringify(recipientsList));
                component.set('v.recipientsList',recipientsList);
                var recipientList = new Array();
                recipientsList.recipients.forEach(function(element){
                    if(!element.from){
                        recipientList.push(element);
                    } 
                });
                if(recipientList.length == 0){
                    var activeStep = component.get('v.activeStep');
                    var steps = component.get('v.steps');
                    component.set('v.activeStep', ++activeStep);
                    component.set('v.stepHeader', steps[activeStep].label);
                    helper.calculateProgressPercent(component, helper);
                    component.set("v.buttonDisabled",false);
                }else{
                    component.set("v.buttonDisabled",true);
                    setTimeout(() => {  document.getElementsByClassName("slds-scrollable_y")[0].scrollTop += 5000; }, 1000);
                    
                }
                component.set("v.dataMissingRecipientList",recipientList);
                component.set('v.missingDataLength',recipientList.length)
            })
            $A.enqueueAction(getDifferent);
    },
    
    formatDate : function(component, event, helper, date){
        
        var isFutureDate = helper.checkIfDateSelectedInFuture(component, event, helper, date);
        if(isFutureDate === false){
            var str = date;
            var todaysDate = new Date();
            todaysDate.setMinutes(todaysDate.getMinutes() + 5);
            var localISOTime = new Date(todaysDate).toISOString();
            return localISOTime;
        }else{
            var str = date;
            var strArray = date.split("-");
            var dateStr = new Date(strArray[0], strArray[1]-1, strArray[2]);
            dateStr.setMinutes(dateStr.getMinutes() + 5);
            var localISOTime = new Date(dateStr).toISOString();
            return localISOTime;
        }
    },
    checkIfDateSelectedInFuture : function(component, event, helper, date){
        var str = date;
        var strArray = date.split("-");
        var dateStr = new Date(strArray[0], strArray[1]-1, strArray[2]);
        var todaysDate = new Date();
        todaysDate.setHours(0,0,0,0);

        if( dateStr > todaysDate){
            return true;
        }
        return false;
    },
    verifyTeamWebHook : function(component, event, helper){
        var team = component.get('v.selectedTeam');
        var getTeamWebHook = component.get("c.getTeamWebHook");

        getTeamWebHook.setParams({
            team: team
        });
        getTeamWebHook.setCallback(this, function(res){
            var response = JSON.parse(res.getReturnValue());
            if(response.isSuccess){
                var webHooks = response.results.body.data.attributes.url;
                var savedWebHooks = component.get('v.webhookURL');
                if(webHooks === null){ 
                    helper.createTeamWebHook(component, event, helper, team);
                }else if(webHooks != savedWebHooks){
                    helper.createTeamWebHook(component,event, helper, team);
                }else{
                    helper.createGift(component, event, helper);
                }
            }else{
                component.set('v.errorMessage', response.errMsg);
            }
        });
        $A.enqueueAction(getTeamWebHook);
    },
    createTeamWebHook : function(component, event, helper, url){
        var team = component.get('v.selectedTeam');
        var urlObj = {
            'url' : url
        }
        var createTeamWebHook = component.get("c.createTeamWebHook");
        createTeamWebHook.setParams({
                team: team,
                url: urlObj
        });

        createTeamWebHook.setCallback(this, function(res){
            var response = JSON.parse(res.getReturnValue());
            if(response.isSuccess){
                var webHooks = response.results.body.data.attributes.url;
                helper.createGift(component, event, helper);
            }else{
                component.set('v.errorMessage', response.errMsg);
            }
        });
        $A.enqueueAction(createTeamWebHook);
    },
    getPreviewLink : function(component, event, helper){
        var getGiftPreviewLink = component.get("c.getPreviewLink");
        var giftRequestObj = helper.createGiftRequestObject(component, event, helper);
        console.log('giftRequestObj>>' +giftRequestObj);
        var team = component.get('v.selectedTeam');
        var params = {
            giftData : giftRequestObj,
            team : team
        }
        getGiftPreviewLink.setParams({
            jsonString: JSON.stringify(params)
        });
        getGiftPreviewLink.setCallback(this, function(res){
            var response = JSON.parse(res.getReturnValue());
            if(response.isSuccess){
                component.set("v.buttonDisabled",false);
                component.set('v.previewLink', response.results.body.data.attributes['gift-preview-url']);
            }else{
                component.set('v.errorMessage', response.errMsg);
                component.set('v.previewDisabled', true);
            }
        });
        $A.enqueueAction(getGiftPreviewLink);

    },
    createGift : function(component, event, helper){
        var team = component.get('v.selectedTeam');//Select
        var giftRequestObj = component.get('v.giftRequestObj');
        console.log('team @@'+team);
        
        var createGift = component.get("c.createGift");
        createGift.setParams({
            team: team,
            body: giftRequestObj
        });
          
        createGift.setCallback(this, function(res){
            var response = JSON.parse(res.getReturnValue());
            if(response.isSuccess){
                var createdGiftsResponse = response.results.body.data;
                helper.buildExternalGiftIdsList(component, event, helper, createdGiftsResponse);
                helper.createGiftObjectRecord(component, event, helper, createdGiftsResponse);
            }else{
                var errorMap = response.results.errorMap;
                if(errorMap.title === 'BillingError'){
                    component.set('v.isBillingError', true);
                }
                component.set('v.errorMessage', response.errMsg);
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(createGift);
    },
    createGiftObjectRecord : function(component, event, helper, createdGiftsResponse ){
        // debugger;
        var createGiftObjRecord = component.get('c.createGiftObjRecord');
        var entryPointObj = component.get('v.entryPointObj');
        var entryPointObjId = component.get('v.recordId');
        var selectedRecipientIdsList =  component.get('v.selectedRecipientIdsList');
        var recipientsList = component.get('v.recipientsList');
        var selectedCollection = component.get('v.selectedCollection');
        var activeStep = component.get('v.activeStep');
        var recordId = component.get('v.recordId');
        var previewLink = component.get('v.previewLink');
        var selectedDiffSender = component.get('v.selectedDiffSender');
        
        var params = {
            recipients : recipientsList.recipients,
            entryPointObj : entryPointObj,
            entryPointObjId : entryPointObjId,
            createdGift : createdGiftsResponse,
            recordId :recordId,
            selectedCollection : selectedCollection,
            selectedRecipientIdsList : selectedRecipientIdsList,
            previewLink : previewLink,
            selectedDiffSender:selectedDiffSender
        }
        console.log('params@@'+JSON.stringify(params));
        createGiftObjRecord.setParams({
            jsonString: JSON.stringify(params)
        });
        createGiftObjRecord.setCallback(this, function(res){
            var response = JSON.parse(res.getReturnValue());
            if(response.isSuccess){
                helper.getcreatedGiftObjectRecords(component, event, helper);
            }else{
                component.set('v.errorMessage', response.errMsg);
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(createGiftObjRecord);
    },
    buildExternalGiftIdsList : function(component, event, helper, createdGiftsResponse){
        var externalGiftIdsList = [];
            createdGiftsResponse.forEach(function(element){
                externalGiftIdsList.push(element.attributes['external-id']);
                component.set('v.externalGiftIdsList', externalGiftIdsList);
            })
    },
    getcreatedGiftObjectRecords : function(component, event, helper){
        var externalGiftIdsList = component.get('v.externalGiftIdsList');
        var getCreatedGiftObjRecords = component.get('c.getCreatedGiftObjRecords');
        var activeStep = component.get('v.activeStep');

        getCreatedGiftObjRecords.setParams({
            externalIds : externalGiftIdsList 
        })

        getCreatedGiftObjRecords.setCallback(this, function(res){
            var response = JSON.parse(res.getReturnValue());
            if(response.isSuccess){
                var gifts = response.results.gifts
                gifts.forEach(function(element){
                    var formattedDate = helper.cleanDate(component, event, helper, element.Scheduled_At__c);
                    element.Scheduled_At__c = formattedDate;
                })
                component.set('v.giftRecords', gifts);
                component.set('v.isLoading', false);
                component.set('v.activeStep', ++activeStep);
            }else{
                component.set('v.errorMessage', response.errMsg);
            }
        });
        $A.enqueueAction(getCreatedGiftObjRecords);
    },
    checkFieldValidation : function(component, event, helper){
        var value = component.get('v.value');
        var selectedTeam = component.get('v.selectedTeam');
        var selectedCollection = component.get('v.selectedCollection');
        var senderName = component.get('v.senderName');
        var selectedDate = component.get('v.selectedDate');
        var subjectLine = component.get('v.subjectLine');
        var message = component.get('v.message');
        var activeStep = component.get('v.activeStep');
        var isValid = true;
        if(activeStep === 0){
            if(value === undefined || value === ''){
                component.set('v.buttonDisabled', true);
                isValid = false;
            }else{
                component.set('v.buttonDisabled', false);
            }
        }
        if(activeStep === 1){
            if(selectedTeam === '' || selectedCollection === ''){
                component.set('v.buttonDisabled', true);
                isValid = false;
            }else{
                component.set('v.buttonDisabled', false);
            }
        }
        if(activeStep === 2){
            var senderSelection = component.get('v.senderSelection')
            if(senderSelection === 'different-sender'){
                component.set('v.errorMsg','');
                isValid = helper.validateSubject(component, event, helper);
            }  
            if(senderName === '' || selectedDate === undefined || selectedDate === null || subjectLine === '' || message === ''){
                component.set('v.buttonDisabled', true);
                isValid= false;
            }else{
                component.set('v.buttonDisabled', false);
            }
        }
        return isValid;
    },
    cleanDate : function(component, event, helper, date){
        var str = date;
        var strArray = date.split("T");
        var dateStrArray = strArray[0].split("-");
        var dateStr = "" + dateStrArray[1] + "-" + dateStrArray[2] + "-" + dateStrArray[0];
        return dateStr;
    },
    validateSubject : function(component, event, helper){
        var selectedSenderField = component.get('v.selectedDiffSender');
        var errorMsg = 'Incorrect format for Dynamic Sender place holder. Correct format: {'+selectedSenderField+'}';
        var isValid = true;
        var subject = component.get('v.subjectLine');
        var selectedSenderField = component.get('v.selectedDiffSender');
        var field = '\\b'+component.get('v.selectedDiffSender')+'\\b';
        var fieldMatch = subject.match(new RegExp(field,'g'));
        var bracStartMatch = subject.match(/{/g);
        var braceEndMatch = subject.match(/}/g);
        
        var count = 0;
        console.log('Inside loop condition');
        if(!subject.includes(selectedSenderField)){
            isValid = false;
            component.set('v.errorMsg',errorMsg);
        }else{
            for(var i=0;i<subject.length;i++){
                
                if(subject.includes(selectedSenderField)){
                    var startString = subject.indexOf(selectedSenderField);
                    var curlyindex = parseInt(startString)+parseInt(selectedSenderField.length);
                    if(startString <= 0){
                        count +=  parseInt(count)+parseInt(1);
                        isValid = false;
                        component.set('v.errorMsg',errorMsg);
                        break;
                    }else if(startString > 0 && (subject[parseInt(startString)-parseInt(1)] != '{' || subject[parseInt(startString)+parseInt(selectedSenderField.length)] != '}')){
                        count = parseInt(count)+parseInt(1);
                        isValid = false;
                        component.set('v.errorMsg',errorMsg);
                        break;
                    }
                    subject = subject.substr(subject.indexOf(selectedSenderField)+selectedSenderField.length,subject.length);
                }
            }
        }
        console.log(count);
        if(count == 0){
            console.log('Success');
        }else{
            isValid = false;
            component.set('v.errorMsg',errorMsg);
        }
        
       
        return isValid;
    }
                                     })