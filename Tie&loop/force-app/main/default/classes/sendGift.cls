public with sharing class sendGift {
    public String namespace {
        get { return constants.NAMESPACE; } //Int =?
    }
    
    public static String getObjectType(String queryRecordId){//on basis of list view get recipitent/ recordId
        Id recordId = queryRecordId;
        String objType = recordId.getSObjectType().getDescribe().getName();//getting obj name
        return objType;
    }
    
    public static String getUserAPIToken(String userId){
        LoopAndTieToken__c customSetting = LoopAndTieToken__c.getInstance(userId);
        String apiToken = customSetting.Access_Token__c;
        System.debug('apiToken:>>>'+apiToken);
        return apiToken;
    }
    @AuraEnabled
    public static String getWebHookURL(){
        responseData rd = new responseData();//error,status,msg -->responseData
        system.debug('responseData'+rd);
        try{
            List<Setup_Data__c> setupDataList = [SELECT Id, pbo_Url__c, Name
                                                 FROM Setup_Data__c
                                                 WHERE Name = 'Default'];
            if(setupDataList.size() > 0){
                rd.results.put('pboUrl', setupDataList[0].pbo_Url__c);
            }else{
                rd.addError('The Loop & Tie app has not been configured for your Salesforce org. Please contact your Salesforce administrator for assistance.');
            }
            
        }catch (Exception e){
            rd.addError(e.getMessage());
        }
        return rd.getJsonString();
    }
    
    @AuraEnabled
    public static String requestAuthTokenURL(){
        responseData rd = new responseData();
        try{
            String endpoint = '';
            if(constants.IS_SANDBOX){
                endpoint = constants.BASE_AUTHORIZE_LOOPTIE_API + '?client_id=' + constants.CLIENT_ID_SANDBOX +
                    '&redirect_uri=https://loopandtie.secure.force.com/oauth&response_type=code';
            }else{
                endpoint = constants.BASE_AUTHORIZE_LOOPTIE_API + '?client_id=' + constants.CLIENT_ID_PROD +
                    '&redirect_uri=https://loopandtie.secure.force.com/oauth&response_type=code';
            }
            rd.results.put('url', endpoint);
            //system.debug('responseData@@'+rd);
        }catch (Exception e){
            rd.addError(e.getMessage());
        }
        return rd.getJsonString();
    }
    
    @AuraEnabled
    public static String verifyUserHasApiToken(String userId){
        responseData rd = new responseData();
        try{
            String apiToken = '';
            if(userId == null){
                LoopAndTieToken__c customSetting = LoopAndTieToken__c.getInstance(UserInfo.getUserId());
                apiToken = customSetting.Access_Token__c;
            }else{
                LoopAndTieToken__c customSetting = LoopAndTieToken__c.getInstance(userId);
                apiToken = customSetting.Access_Token__c;
            }
            
            if(apiToken == null){
                rd.results.put('hasToken', false);
            }else{
                rd.results.put('hasToken', true);
            }
        }catch (Exception e){
            rd.addError(e.getMessage());
        }
        return rd.getJsonString();
    }
    
    @AuraEnabled
    public static String getUserTeams(){
        responseData rd = new responseData();
        String userId = UserInfo.getUserId();
        try{
            String accessToken = '';
            if(userId == null){
                accessToken = getUserAPIToken(UserInfo.getUserId());
            }else{
                accessToken = getUserAPIToken(userId);
            }
            system.debug('accessToken >>'+accessToken);
            Map<String, String> headers = new Map<String, String>();
            headers.put('Authorization', 'Bearer ' + accessToken);
            headers.put('Content-Type', 'application/json');
            String endpoint = constants.BASE_LOOPTIE_API + '/teams';
            system.debug('endpoint  >>'+endpoint);
            HttpResponse res = utilities.makeCallout(endpoint, 'GET', null, headers);
            Map<String, Object> returnedData = new Map<String, Object>();
            if(res.getStatusCode() == 200) {
                returnedData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                rd.results.put('body', returnedData);
            }else if(res.getStatusCode() == 401){
                rd.addError('Unauthorized. Please log in to continue.');
                rd.setStatusCode(401);
            }else{
                if(String.isNotBlank(res.getBody())){
                    returnedData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                    System.debug('**********ERROR:' + returnedData);
                    List<Object> errorList = (List<Object>)returnedData.get('errors');
                    Map<String, Object> errorMap = (Map<String, Object>)errorList.get(0);
                    rd.addError((String)errorMap.get('detail'));
                }
            }
        }catch (Exception e){
            rd.addError(e.getMessage());
        }
        return rd.getJsonString();
    }
    
    
    @AuraEnabled
    public static String getTeamCollections(String team, String userId){
        responseData rd = new responseData();
        try{
            String accessToken = '';
            if(userId == null){
                accessToken = getUserAPIToken(UserInfo.getUserId());
            }else{
                accessToken = getUserAPIToken(userId);
            }
            Map<String, String> headers = new Map<String, String>();
            headers.put('Authorization', 'Bearer ' + accessToken);
            headers.put('Content-Type', 'application/json');
            String endpoint = constants.BASE_LOOPTIE_API + '/teams/' + team + '/collections';
            
            HttpResponse res = utilities.makeCallout(endpoint, 'GET', null, headers);
            Map<String, Object> returnedData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            
            if(res.getStatusCode() == 200) {
                rd.results.put('body', returnedData);
            }else{
                System.debug('**********ERROR:' + returnedData);
                List<Object> errorList = (List<Object>)returnedData.get('errors');
                Map<String, Object> errorMap = (Map<String, Object>)errorList.get(0);
                rd.addError((String)errorMap.get('detail'));
            }
        }catch (Exception e){
            rd.addError(e.getMessage());
        }
        return rd.getJsonString();
    }
    
    @AuraEnabled
    public static String getTeamWebHook(String team){
        responseData rd = new responseData();
        try{
            String accessToken = getUserAPIToken(UserInfo.getUserId());
            Map<String, String> headers = new Map<String, String>();
            headers.put('Authorization', 'Bearer ' + accessToken);
            headers.put('Content-Type', 'application/json');
            String endpoint = constants.BASE_LOOPTIE_API + '/teams/' + team + '/hooks';
            
            HttpResponse res = utilities.makeCallout(endpoint, 'GET', null, headers);
            Map<String, Object> returnedData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            
            if(res.getStatusCode() == 200) {
                rd.results.put('body', returnedData);
            }else{
                System.debug('**********ERROR:' + returnedData);
                List<Object> errorList = (List<Object>)returnedData.get('errors');
                Map<String, Object> errorMap = (Map<String, Object>)errorList.get(0);
                rd.addError((String)errorMap.get('detail'));
            }
        }catch(Exception e){
            rd.addError(e.getMessage());
        }
        return rd.getJsonString();
    }
    
    @AuraEnabled
    public static String createGift(String team, Map<String, Map<String, Object>> body){
        responseData rd = new responseData();
        try{
            String accessToken = getUserAPIToken(UserInfo.getUserId());
            Map<String, String> headers = new Map<String, String>();
            headers.put('Authorization', 'Bearer ' + accessToken);
            headers.put('Content-Type', 'application/json');
            
            String endpoint = '';
            endpoint = constants.BASE_LOOPTIE_API + '/teams/' + team + '/bulk/gifts';
            
            HttpResponse res = utilities.makeCallout(endpoint, 'POST', JSON.serialize(body), headers);
            Map<String, Object> returnedData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            
            if(res.getStatusCode() == 200) {
                rd.results.put('body', returnedData);
            }else{
                System.debug('**********ERROR:' + returnedData);
                List<Object> errorList = (List<Object>)returnedData.get('errors');
                Map<String, Object> errorMap = (Map<String, Object>)errorList.get(0);
                rd.results.put('errorMap', errorMap);
                rd.addError((String)errorMap.get('detail'));
            }
        }catch(Exception e){
            rd.addError(e.getMessage());
        }
        return rd.getJsonString();
    }
    
    @AuraEnabled
    public static String createGiftObjRecord(String jsonString){
        responseData rd = new responseData();
        try{
            //checkAccess(standardObjectChecks, false);
            checkAccess(customObjectChecks, true);
            
            Map<String, Object> parsedJson = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            String selectedCollection = (String)parsedJson.get('selectedCollection');
            //entry point
            String entryPointObjId = (String)parsedJson.get('entryPointObjId');
            String entryPointObj = (String)parsedJson.get('entryPointObj');
            String previewLink = (String)parsedJson.get('previewLink');
            
            List<Object> recipients = (List<Object>)parsedJson.get('recipients');
            List<Object> createdGiftsList = (List<Object>)parsedJson.get('createdGift');
            List<Gift__c> giftsList = new List<Gift__c>();
            
            List<Case> queryCaseIdsList = new List<Case>();
            List<Contact> queryContactIdsList = new List<Contact>();
            List<Object> selectedRecipientIdsList = new List<Object>();
            String recordId = '';
            
            if(entryPointObj == 'Opportunity'){
                checkAccess(opportunitycontactObjectChecks, false);
                List<String> recipientIdsList = new List<String>();
                
                for(Object recipient : recipients){
                    Map<String, Object> recipientMap = (Map<String, Object>)recipient;
                    String recipientId = (String)recipientMap.get('id');
                    recipientIdsList.add(recipientId);
                }
                
                queryContactIdsList = [SELECT Id, AccountId
                                       FROM Contact
                                       WHERE Id IN:recipientIdsList];
                
            } else if(entryPointObj == 'Case'){
                checkAccess(caseObjectChecks, false);
                List<String> caseIdsList = new List<String>();
                selectedRecipientIdsList = (List<Object>)parsedJson.get('selectedRecipientIdsList');
                recordId = (String)parsedJson.get('recordId');
                if(!selectedRecipientIdsList.isEmpty()){
                    for(Object ca : selectedRecipientIdsList){
                        caseIdsList.add((String)ca);
                    }
                    queryCaseIdsList = [SELECT Id, AccountId
                                        FROM Case
                                        WHERE Id IN:caseIdsList];
                } else{
                    queryCaseIdsList = [SELECT Id, AccountId
                                        FROM Case
                                        WHERE Id =:recordId];
                }
            }
            Integer index = 0;
            for(Object recipient : recipients){
                Map<String, Object> recipientMap = (Map<String, Object>)recipient;
                String recipientId = (String) recipientMap.get('id');
                String recipientEmail = (String) recipientMap.get('email');
                
                system.debug('recipientMap '+recipientMap);
                system.debug('createdGiftsList '+createdGiftsList);
                Integer giftIndex = 0;
                for(Object createdGift : createdGiftsList){
                    String subject = '';
                    Map<String, Object> createdGiftsMap = (Map<String, Object>)createdGift;
                    Map<String, Object> createdGiftsMapData = (Map<String, Object>)createdGiftsMap.get('attributes');
                    System.debug('DATA: ' + createdGiftsMapData.containsKey('to'));
                    String email = (String)createdGiftsMapData.get('email');
                    if(recipientEmail == email){
                        String externalId = (String)createdGiftsMapData.get('external-id');
                        String message = (String)createdGiftsMapData.get('message');
                        String scheduledAt = (String)createdGiftsMapData.get('scheduled-at');
                        Datetime formattedScheduledAt = Datetime.ValueofGmt(scheduledAt.replace('T', ' '));
                        
                        String stage = (String)createdGiftsMapData.get('stage');
                        
                        String team = (String)createdGiftsMapData.get('team');
                        String untieUrl = (String)createdGiftsMapData.get('untie-url');
                        String userId = UserInfo.getUserId();
                        
                        if(String.isNotBlank((String)recipientMap.get('subject'))){
                            subject = (String)recipientMap.get('subject');
                        }else{
                            subject = (String)createdGiftsMapData.get('subject');
                        }
                        
                        Gift__c newGift = new Gift__c(
                            Collection__c = selectedCollection,
                            Email__c = email,
                            Gift_Id__c = externalId,
                            Message__c = message,
                            Preview_Url__c = previewLink,
                            Untie_Url__c = untieUrl,
                            Scheduled_At__c = formattedScheduledAt,
                            Stage__c = stage,
                            Subject__c = subject,
                            Team__c = team,
                            User__c = userId);
                        if(entryPointObj == 'Account'){
                            newGift.Account_Id__c = entryPointObjId;
                            newGift.Contact_Id__c = recipientId;
                            
                        } else if(entryPointObj == 'Opportunity'){
                            newGift.Opportunity_Id__c = entryPointObjId;
                            newGift.Account_Id__c = queryContactIdsList[index].AccountId;
                            newGift.Contact_Id__c = recipientId;
                            
                        } else if(entryPointObj == 'Contact'){
                            newGift.Contact_Id__c = recipientId;
                            
                        } else if(entryPointObj == 'Lead'){
                            newGift.Lead_Id__c = recipientId;
                            
                        } else if(entryPointObj == 'Case'){
                            String caseId = '';
                            if(!selectedRecipientIdsList.isEmpty()){
                                caseId = (String)selectedRecipientIdsList.get(index);
                            }else{
                                caseId = recordId;
                            }
                            
                            newGift.Case_Id__c = caseId;
                            newGift.Account_Id__c = queryCaseIdsList[index].AccountId;
                            newGift.Contact_Id__c = recipientId;
                            
                        } else if(entryPointObj == 'Campaign'){
                            if(recipientId.substring(0,3) == '003')
                                newGift.Contact_Id__c = recipientId;
                            else
                                newGift.Lead_Id__c = recipientId;
                        }
                        
                        giftsList.add(newGift);
                        break;
                    } else{
                        giftIndex++;
                    }
                }
                createdGiftsList.remove(giftIndex);
                index++;
            }
            insert giftsList;
            
        }catch(Exception e){
            rd.addError(e.getMessage());
        }
        return rd.getJsonString();
    }
    
    @AuraEnabled
    public static String createTeamWebHook(String team){
        responseData rd = new responseData();
        try{
            checkAccess(customObjectChecks, true);
            String accessToken = getUserAPIToken(UserInfo.getUserId());
            Map<String, String> headers = new Map<String, String>();
            headers.put('Authorization', 'Bearer ' + accessToken);
            headers.put('Content-Type', 'application/json');
            String endpoint = constants.BASE_LOOPTIE_API + '/teams/' + team + '/hooks';
            
            Setup_Data__c setupData = [SELECT Id, pbo_Url__c, Name
                                       FROM Setup_Data__c
                                       WHERE Name = 'Default'];
            String url = (String)setupData.pbo_Url__c;
            Map<String, String> link = new Map<String, String>{'url'=> url};
                Map<String, Map<String, String>> body = new Map<String, Map<String, String>>{
                    'hook' => link
                        };
                            
                            HttpResponse res = utilities.makeCallout(endpoint, 'POST', JSON.serialize(body), headers);
            Map<String, Object> returnedData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            
            if(res.getStatusCode() == 200) {
                rd.results.put('body', returnedData);
            }else{
                //handle error message here
                System.debug('**********ERROR:' + returnedData);
                List<Object> errorList = (List<Object>)returnedData.get('errors');
                Map<String, Object> errorMap = (Map<String, Object>)errorList.get(0);
                rd.addError((String)errorMap.get('detail'));
            }
        }catch(Exception e){
            rd.addError(e.getMessage());
        }
        return rd.getJsonString();
    }
    
    @AuraEnabled
    public static String getPreviewLink(String jsonString){
        responseData rd = new responseData();
        try{
            String accessToken = getUserAPIToken(UserInfo.getUserId());
            Map<String, String> headers = new Map<String, String>();
            headers.put('Authorization', 'Bearer ' + accessToken);
            headers.put('Content-Type', 'application/json');
            
            Map<String, Object> parsedJson = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            String team = (String)parsedJson.get('team');
            Map<String, Object> giftData = (Map<String, Object>)parsedJson.get('giftData');
            Map<String, Object> gift = (Map<String, Object>)giftData.get('gift');
            
            String endpoint = constants.BASE_LOOPTIE_API + '/teams/' + team + '/previews';
            System.debug('Request Gift >>'+gift);
            Map<String, Object> body = new Map<String, Object>{
                'gift' => gift
                    };
                        
                        HttpResponse res = utilities.makeCallout(endpoint, 'POST', JSON.serialize(body), headers);
            Map<String, Object> returnedData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            system.debug('returnedData'+returnedData);
            system.debug('res >'+res);
            if(res.getStatusCode() == 200) {
                rd.results.put('body', returnedData);
            }else{
                //handle error message here
                System.debug('**********ERROR:' + returnedData);
                List<Object> errorList = (List<Object>)returnedData.get('errors');
                Map<String, Object> errorMap = (Map<String, Object>)errorList.get(0);
                rd.addError((String)errorMap.get('detail'));
            }
        }catch(Exception e){
            rd.addError(e.getMessage());
        }
        return rd.getJsonString();
    }
    
    @AuraEnabled
    public static String getRecipientInfo(List<String> queryRecordIds){
        
        responseData rd = new responseData();
        
        try{
            
            Id recordId = queryRecordIds[0];
            String objectName = getObjectType(recordId);
        	system.debug('objectName ::'+objectName);
            List<String> queryRecordIdsList = queryRecordIds;
            List<Map<String,Object>> selectedRecipientList = new List<Map<String,Object>>();
            //1:1 Recipient Selection/listview
            //Contact
            if(objectName == 'Contact'){
                checkAccess(contactObjectChecks, false);
                List<Contact> contacts = [SELECT Id, Name, Email, HasOptedOutOfEmail
                                          FROM Contact
                                          WHERE Id IN:queryRecordIdsList ]; //  AND HasOptedOutOfEmail != false
                for(Contact contact : contacts){
                    Map<String,Object> recipient = new Map<String,Object>();
                    recipient.put('name', contact.Name);
                    recipient.put('email', contact.Email);
                    recipient.put('id', contact.Id);
                    selectedRecipientList.add(recipient);
                }
            }
            ////Lead
            if(objectName == 'Lead'){
                system.debug('leadObjectChecks ::'+leadObjectChecks);
                checkAccess(leadObjectChecks, false);
                List<Lead> leads = [SELECT Id, Name, Email
                                    FROM Lead
                                    WHERE Id IN:queryRecordIdsList];
                for(Lead lead : leads){
                    Map<String,Object> recipient = new Map<String,Object>();
                    recipient.put('name', lead.Name );
                    recipient.put('email', lead.Email);
                    recipient.put('id', lead.Id);
                    selectedRecipientList.add(recipient);
                }
            }
            ////Case
            if(objectName == 'Case'){
                checkAccess(caseObjectChecks, false);
                List<Case> cases = [SELECT Id, ContactId
                                    FROM Case
                                    WHERE Id IN:queryRecordIdsList];
                List<String> contactIdList = new List<String>();
                for(Case c : cases){
                    if(c.ContactId != null){
                        contactIdList.add(c.ContactId);
                    }
                }
                List<Contact> contacts = [SELECT Id, Name, Email
                                          FROM Contact
                                          WHERE Id IN:contactIdList];
                for(Contact contact : contacts){
                    Map<String,Object> recipient = new Map<String,Object>();
                    recipient.put('name', contact.Name);
                    recipient.put('email', contact.Email);
                    recipient.put('id', contact.Id);
                    selectedRecipientList.add(recipient);
                }
            }
            //Select Recipient(s)/Contact(s)
            //Opportunity
            if(objectName == 'Opportunity'){
                checkAccess(opportunitycontactObjectChecks, false);
                List<OpportunityContactRole> opportunityContactRolesList = [SELECT Id, Contact.Name, Contact.Email, Contact.Id
                                                                            FROM OpportunityContactRole
                                                                            WHERE OpportunityId =:recordId
                                                                            ORDER BY LastModifiedDate DESC
                                                                            LIMIT 5];
                for(OpportunityContactRole opp : opportunityContactRolesList){
                    Map<String,Object> recipient = new Map<String,Object>();
                    recipient.put('name', opp.Contact.Name);
                    recipient.put('email', opp.Contact.Email);
                    recipient.put('id', opp.Contact.Id);
                    selectedRecipientList.add(recipient);
                }
            }
            //Account
            if(objectName == 'Account'){
                checkAccess(accountObjectChecks, false);
                List<Contact> contactsList = [SELECT Id, Name, Email
                                              FROM Contact
                                              WHERE AccountId =:recordId
                                              ORDER BY LastModifiedDate DESC
                                              LIMIT 5];
                for(Contact contact : contactsList){
                    Map<String,Object> recipient = new Map<String,Object>();
                    recipient.put('name', contact.Name);
                    recipient.put('email', contact.Email);
                    recipient.put('id', contact.Id);
                    selectedRecipientList.add(recipient);
                }
            }
            //Campaign
            if(objectName == 'Campaign'){
                checkAccess(campaignObjectChecks, false);
                //Set of contactIds and leadIds
                Set<Id> contactIds = new Set<Id>();
                Set<Id> leadIds = new Set<Id>();
                
                for(CampaignMember cMember : [SELECT Id,CampaignId,ContactId,LeadId,Lead.IsConverted FROM CampaignMember
                                              WHERE CampaignId IN: queryRecordIdsList]){
                                                  if(!string.isBlank(cMember.ContactId)){
                                                      contactIds.add(cMember.ContactId);
                                                  }
                                                  if(!string.isBlank(cMember.LeadId) && cMember.Lead.IsConverted == False){
                                                      leadIds.add(cMember.LeadId);
                                                  }
                                              }
                System.debug('contactIds:>>>>>'+contactIds);
                System.debug('leadIds:>>>>>'+leadIds);
                
                if(contactIds.size() > 0){
                    for(Contact contact : [SELECT Id, Name, Email FROM Contact WHERE Id IN:contactIds]){
                        Map<String,Object> recipient = new Map<String,Object>();
                        recipient.put('name', contact.Name);
                        recipient.put('email', contact.Email);
                        recipient.put('id', contact.Id);
                        selectedRecipientList.add(recipient);
                    }
                }
                if(leadIds.size() > 0){
                    for(Lead lead : [SELECT Id, Name, Email FROM Lead WHERE Id IN:leadIds]){
                        Map<String,Object> recipient = new Map<String,Object>();
                        recipient.put('name', lead.Name);
                        recipient.put('email', lead.Email);
                        recipient.put('id', lead.Id);
                        selectedRecipientList.add(recipient);
                    }
                }
            }
            System.debug('selectedRecipientList:>>>>>'+selectedRecipientList.size());
            
            rd.results.put('senderName', UserInfo.getFirstName() + ' ' + UserInfo.getLastName());
            rd.results.put('objectName', objectName);
            rd.results.put('recipients', selectedRecipientList);
        }catch (Exception e){
            rd.addError(e.getMessage());
        }
        return rd.getJsonString();
    }
    @AuraEnabled
    public static String getListViewObjType(String listViewId){
        responseData rd = new responseData();
        try{
            //checkAccess(standardObjectChecks, false);
            
            List<ListView> listViewObj = [SELECT Id, SobjectType
                                          FROM ListView
                                          WHERE Id =:listViewId
                                          LIMIT 1];
            String objectName = listViewObj[0].SobjectType;
            if(objectName == 'Contact'){
                checkAccess(contactObjectChecks, false);
            }
            if(objectName == 'Account'){
                checkAccess(accountObjectChecks, false);
            }
            if(objectName == 'Lead'){
                checkAccess(leadObjectChecks, false);
            }
            if(objectName == 'Opportunity'){
                checkAccess(opportunitycontactObjectChecks, false);
            }
            for(ListView view : listViewObj){
                rd.results.put('objectName', view.SobjectType);
            }
            rd.results.put('senderName', UserInfo.getFirstName() + ' ' + UserInfo.getLastName());
            
        }catch (Exception e){
            rd.addError(e.getMessage());
        }
        return rd.getJsonString();
    }
    
    @AuraEnabled
    public static List<Map<String,Object>> getDifferent(String obj,String recipientsList,String selectedDiffSender,String subject,String signatureType){
        system.debug('recipientsListrecipientsList'+recipientsList);
        Set<String> conIds = new Set<String>();
        Set<String> leadIds = new Set<String>();
        List<Contact> contacts = new List<Contact>();
        List<Lead> leads = new List<Lead>();
        Set<Id> userIdSet = new Set<Id>();
        String Query ;
        List<Map<String,Object>> recipientNewList = new List<Map<String,Object>>();
        
        try{
            String subjectField = getSubjectField(subject);
            List<Object> recipients = (List<Object>)JSON.deserializeUntyped(recipientsList);
            Map<Id,String> conScheduleMap = new Map<Id,String>();
            for(Object recipient : recipients){
                Map<String, Object> recipientMap = (Map<String, Object>)recipient;
                String recipientId = (String)recipientMap.get('id');
                conScheduleMap.put(recipientId,(String)recipientMap.get('scheduledAt'));
                if(recipientId.startsWith('003')){
                    conIds.add(recipientId);
                }
                if(recipientId.startsWith('00Q')){
                    leadIds.add(recipientId);
                }
            }
            if(conIds.size() > 0){
                if(Schema.sObjectType.Contact.isAccessible()){
                    Query = 'Select Id , Email , Name , ' + selectedDiffSender +' FROM Contact ' + 'WHERE Id IN :conIds';
                    contacts =  Database.query(Query);
                    for(Contact con : contacts){
                        userIdSet.add(String.valueOf(con.get(selectedDiffSender)) );
                    }
                }
            }
            if(leadIds.size() > 0){
                if(Schema.sObjectType.Lead.isAccessible()){
                    Query = 'Select Id , Email , Name , ' + selectedDiffSender +' FROM Lead ' + 'WHERE Id IN :leadIds';
                    leads =  Database.query(Query);
                    for(Lead l : leads){
                        userIdSet.add(String.valueOf(l.get(selectedDiffSender)));
                    }
                }
            }
            Map<Id,User> userMap = new Map<Id,User>([Select Id,FirstName,Name,Email From User Where ID In:userIdSet]);
            for(Contact con : contacts){ 
                Map<String,Object> recipient = new Map<String,Object>();
                recipient.put('name', con.Name);
                recipient.put('email', con.Email);
                recipient.put('id', con.Id);
                if(conScheduleMap.containskey(con.Id)){
                    recipient.put('scheduledAt',conScheduleMap.get(con.Id));
                }
                
                if(userMap.containskey(String.valueOf(con.get(selectedDiffSender)))){
                    String UserName = '';
                    if(signatureType == 'full-name'){
                        UserName = userMap.get(String.valueOf(con.get(selectedDiffSender))).Name;
                    }else{
                        UserName = userMap.get(String.valueOf(con.get(selectedDiffSender))).FirstName;
                    }
                    system.debug('subjectField'+subjectField);
                    system.debug('selectedDiffSender'+selectedDiffSender);
                    if(subjectField == selectedDiffSender){
                        String recipientSubject = subject.replace('{'+subjectField+'}',UserName);
                        recipient.put('subject',recipientSubject);
                    }
                    
                    recipient.put('from',UserName);
                    recipient.put('cc_email',userMap.get(String.valueOf(con.get(selectedDiffSender))).Email);
                }else{
                    recipient.put('from','');
                    recipient.put('cc_email','');
                }
                recipientNewList.add(recipient);
            }
            for(Lead l : leads){ 
                Map<String,Object> recipient = new Map<String,Object>();
                recipient.put('name', l.Name);
                recipient.put('email', l.Email);
                recipient.put('id', l.Id);
                if(conScheduleMap.containskey(l.Id)){
                    recipient.put('scheduledAt',conScheduleMap.get(l.Id));
                }
                if(userMap.containskey(String.valueOf(l.get(selectedDiffSender)))){
                    String UserName = '';
                    if(signatureType == 'full-name'){
                        UserName = userMap.get(String.valueOf(l.get(selectedDiffSender))).Name;
                    }else{
                        UserName = userMap.get(String.valueOf(l.get(selectedDiffSender))).FirstName;
                    }
                    system.debug('subjectField'+subjectField);
                    system.debug('selectedDiffSender'+selectedDiffSender);
                    if(subjectField == selectedDiffSender){
                        String recipientSubject = subject.replace('{'+subjectField+'}',UserName);
                        recipient.put('subject',recipientSubject);
                    }
                    
                    recipient.put('from',UserName);
                    recipient.put('cc_email',userMap.get(String.valueOf(l.get(selectedDiffSender))).Email);
                }else{
                    recipient.put('from','');
                    recipient.put('cc_email','');
                }
                recipientNewList.add(recipient);    
            }
        }catch(Exception e){
            e.getMessage();
        }
        system.debug('recipientNewList >>'+recipientNewList);
        return recipientNewList;
    }
    private static String getSubjectField(String subject){
        Integer firstIndex = subject.indexOf('{');
        Integer secondIndex = subject.indexOf('}');
        String recipientSubject = subject.subString(firstIndex+1,secondIndex);
        return recipientSubject;
    }
    @AuraEnabled
    public static String getMultiLookupRecipientInfo(String obj, List<String> recipients){
        responseData rd = new responseData();
        
        try{
            
            List<String> recipientsIdsList = recipients;
            List<Map<String,Object>> selectedRecipientList = new List<Map<String,Object>>();
            List<Map<String, String>> dateFields = new List<Map<String, String>>();
            Set<String> contactFields = new Set<String>{'Id', 'Name', 'Email'};
                Set<String> leadFields = new Set<String>{'Id', 'Name', 'Email'};
                    
                    if(obj == 'Contact'){
                        checkAccess(contactObjectChecks, false);
                        List<Map<String, String>> contactDateFields = new List<Map<String, String>>();
                        for(Schema.SObjectField sobjfield : Contact.SobjectType.getDescribe().fields.getMap().values()){
                            Schema.DescribeFieldResult describedField = sobjfield.getDescribe();
                            
                            Map<String, String> dateFieldsDetailMap = new Map<String, String>();
                            if(String.valueOf(describedField.getType()) == 'Date'){
                                if(describedField.getName() != 'LastActivityDate'){
                                    dateFieldsDetailMap.put('label', describedField.getLabel());
                                    dateFieldsDetailMap.put('name', describedField.getName());
                                    contactDateFields.add(dateFieldsDetailMap);
                                    contactFields.add(describedField.getName());
                                }
                            }
                        }
                        
                        //standardObjectChecks.get('Contact').get('Read').addAll(contactFields);
                        //checkAccess(standardObjectChecks, false);
                        
                        String soqlQuery = 'SELECT ' + String.join(new List<String>(contactFields), ', ') +
                            ' FROM Contact' +
                            ' WHERE Id IN :recipientsIdsList';
                        List<Contact> contacts =  Database.query(soqlQuery);
                        for(Contact contact : contacts){
                            Map<String,Object> recipient = new Map<String,Object>();
                            recipient.put('name', contact.Name);
                            recipient.put('email', contact.Email);
                            recipient.put('id', contact.Id);
                            recipient.put('scheduledAt', date.today());
                            for(Map<String, String> field : contactDateFields){
                                String name = (String)field.get('name');
                                recipient.put(name, contact.get(name));
                            }
                            
                            selectedRecipientList.add(recipient);
                        }
                    }else if(obj == 'Lead'){
                        checkAccess(leadObjectChecks, false);
                        List<Map<String, String>> leadDateFields = new List<Map<String, String>>();
                        for(Schema.SObjectField sobjfield : Lead.SobjectType.getDescribe().fields.getMap().values()){
                            Schema.DescribeFieldResult describedField = sobjfield.getDescribe();
                            Map<String, String> dateFieldsDetailMap = new Map<String, String>();
                            if(String.valueOf(describedField.getType()) == 'Date'){
                                if(describedField.getName() != 'LastActivityDate' && describedField.getName() != 'LastTransferDate'){
                                    dateFieldsDetailMap.put('label', describedField.getLabel());
                                    dateFieldsDetailMap.put('name', describedField.getName());
                                    leadFields.add(describedField.getName());
                                    leadDateFields.add(dateFieldsDetailMap);
                                }
                            }
                        }
                        
                        //standardObjectChecks.get('Lead').get('Read').addAll(leadFields);
                        //checkAccess(standardObjectChecks, false);
                        
                        String soqlQuery = 'SELECT ' + String.join(new List<String>(leadFields), ', ') +
                            ' FROM Lead' +
                            ' WHERE Id IN :recipientsIdsList';
                        List<Lead> leads =  Database.query(soqlQuery);
                        for(Lead lead : leads){
                            Map<String,Object> recipient = new Map<String,Object>();
                            recipient.put('name', lead.Name);
                            recipient.put('email', lead.Email);
                            recipient.put('id', lead.Id);
                            recipient.put('scheduledAt', date.today());
                            for(Map<String, String> field : leadDateFields){
                                String name = (String)field.get('name');
                                recipient.put(name, lead.get(name));
                            }
                            
                            selectedRecipientList.add(recipient);
                        }
                        
                    }else if(obj == 'Campaign'){
                        checkAccess(campaignObjectChecks, false);
                        checkAccess(campaignObjectChecks, false);
                        List<Map<String, String>> contact2DateFields = new List<Map<String, String>>();
                        //for contact
                        for(Schema.SObjectField sobjfield : Contact.SobjectType.getDescribe().fields.getMap().values()){
                            Schema.DescribeFieldResult describedField = sobjfield.getDescribe();
                            
                            Map<String, String> dateFieldsDetailMap = new Map<String, String>();
                            if(String.valueOf(describedField.getType()) == 'Date'){
                                if(describedField.getName() != 'LastActivityDate'){
                                    dateFieldsDetailMap.put('label', describedField.getLabel());
                                    dateFieldsDetailMap.put('name', describedField.getName());
                                    contact2DateFields.add(dateFieldsDetailMap);
                                    contactFields.add(describedField.getName());
                                }
                            }
                        }
                        //standardObjectChecks.get('Contact').get('Read').addAll(contactFields);
                        //checkAccess(standardObjectChecks, false);
                        
                        
                        String soqlQuery = 'SELECT ' + String.join(new List<String>(contactFields), ', ') +
                            ' FROM Contact' +
                            ' WHERE Id IN :recipientsIdsList';
                        List<Contact> contacts =  Database.query(soqlQuery);
                        for(Contact contact : contacts){
                            Map<String,Object> recipient = new Map<String,Object>();
                            recipient.put('name', contact.Name);
                            recipient.put('email', contact.Email);
                            recipient.put('id', contact.Id);
                            recipient.put('scheduledAt', date.today());
                            for(Map<String, String> field : contact2DateFields){
                                String name = (String)field.get('name');
                                recipient.put(name, contact.get(name));
                            }
                            
                            selectedRecipientList.add(recipient);
                        }
                        List<Map<String, String>> lead2DateFields = new List<Map<String, String>>();
                        //for lead
                        for(Schema.SObjectField sobjfield : Lead.SobjectType.getDescribe().fields.getMap().values()){
                            Schema.DescribeFieldResult describedField = sobjfield.getDescribe();
                            Map<String, String> dateFieldsDetailMap = new Map<String, String>();
                            if(String.valueOf(describedField.getType()) == 'Date'){
                                if(describedField.getName() != 'LastActivityDate' && describedField.getName() != 'LastTransferDate'){
                                    dateFieldsDetailMap.put('label', describedField.getLabel());
                                    dateFieldsDetailMap.put('name', describedField.getName());
                                    leadFields.add(describedField.getName());
                                    lead2DateFields.add(dateFieldsDetailMap);
                                }
                            }
                        }
                        //standardObjectChecks.get('Lead').get('Read').addAll(leadFields);
                        //checkAccess(standardObjectChecks, false);
                        
                        String soqlQuery1 = 'SELECT ' + String.join(new List<String>(leadFields), ', ') +
                            ' FROM Lead' +
                            ' WHERE Id IN :recipientsIdsList';
                        List<Lead> leads =  Database.query(soqlQuery1);
                        for(Lead lead : leads){
                            Map<String,Object> recipient = new Map<String,Object>();
                            recipient.put('name', lead.Name);
                            recipient.put('email', lead.Email);
                            recipient.put('id', lead.Id);
                            recipient.put('scheduledAt', date.today());
                            for(Map<String, String> field : dateFields){
                                String name = (String)field.get('name');
                                recipient.put(name, lead.get(name));
                            }
                            
                            selectedRecipientList.add(recipient);
                        }
                    }
            
            Map<String, Object> dateFieldsMap = new Map<String, Object>{
                'dateFields' => dateFields
                    };
                        rd.results.put('recipients', selectedRecipientList);
            rd.results.put('dateFields', dateFieldsMap);
        }catch (Exception e){
            rd.addError(e.getMessage());
        }
        return rd.getJsonString();
    }
    
    @AuraEnabled
    public static String getCreatedGiftObjRecords(List<String> externalIds){
        responseData rd = new responseData();
        try{
            
            checkAccess(customObjectChecks, true);
            
            List<Gift__c> gifts = [SELECT Id, Gift_Id__c, Name, Contact_Id__c, Lead_Id__c, Recipient__c, Email__c, Collection__c, Scheduled_At__c
                                   FROM Gift__c
                                   WHERE Gift_Id__c IN:externalIds];
            rd.results.put('gifts', gifts);
        }catch (Exception e){
            rd.addError(e.getMessage());
        }
        return rd.getJsonString();
    }
    
    @AuraEnabled
    public static String getToken(String code){
        responseData rd = new responseData();
        
        try{
            checkAccess(customObjectChecks, true);
            String connectionEndpoint = '';
            
            connectionEndpoint = constants.BASE_AUTH_TOKEN_LOOPTIE_API;
            Map<String, String> body = new Map<String, String>();
            if(constants.IS_SANDBOX){
                body = new Map<String, String>{
                    'client_id' => constants.CLIENT_ID_SANDBOX ,
                        'client_secret' => constants.CLIENT_SECRET_SANDBOX,
                        'code' => code,
                        'grant_type' => 'authorization_code',
                        'redirect_uri' => 'https://loopandtie.secure.force.com/oauth'
                        };
                            }else{
                                body = new Map<String, String>{
                                    'client_id' => constants.CLIENT_ID_PROD ,
                                        'client_secret' => constants.CLIENT_SECRET_PROD,
                                        'code' => code,
                                        'grant_type' => 'authorization_code',
                                        'redirect_uri' => 'https://loopandtie.secure.force.com/oauth'
                                        };
                                            }
            
            Map<String, String> headers = new Map<String, String>();
            headers.put('Content-Type', 'application/json');
            system.debug('connectionEndpoint >>'+connectionEndpoint);
            HttpResponse res = utilities.makeCallout(connectionEndpoint, 'POST', JSON.serialize(body), headers);
            Map<String, Object> returnedData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            if(res.getStatusCode() == 200) {
                //save down retreived token to user custom settings
                /*if (Schema.sObjectType.LoopAndTieToken__c.isUpdateable() || Schema.sObjectType.LoopAndTieToken__c.isCreateable()) {
LoopAndTieToken__c customSetting = LoopAndTieToken__c.getInstance(UserInfo.getUserId());
if(Schema.sObjectType.LoopAndTieToken__c.fields.Access_Token__c.isUpdateable() ||Schema.sObjectType.LoopAndTieToken__c.fields.Access_Token__c.isCreateable()){
customSetting.Access_Token__c = (String)returnedData.get('access_token');
upsert customSetting;
}
}*/
                LoopAndTieToken__c customSetting = LoopAndTieToken__c.getInstance(UserInfo.getUserId());
                customSetting.Access_Token__c = (String)returnedData.get('access_token');
                upsert customSetting;
                
            }else{
                //handle error message here
                rd.addError(JSON.serialize(returnedData));
            }
        }catch(Exception e){
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
        }
        
        return rd.getJsonString();
    }
    
    /* private static Map<String, Map<String, Set<String>>> standardObjectChecks = new Map<String, Map<String, Set<String>>> {
        'Contact' => new Map<String, Set<String>> {
            'Read' => new Set<String> {}
        },
            'Case' => new Map<String, Set<String>> {
                'Create' => new Set<String> {
                    'Id', 'Name', 'Email', 'AccountId', 'ContactId'
                        }
            },
                'Lead' => new Map<String, Set<String>> {
                    'Read' => new Set<String> {}
                },
                    'OpportunityContactRole' => new Map<String, Set<String>> {
                        'Read' => new Set<String> {
                            'Id', 'ContactId'
                                }
                    },
                        'ListView' => new Map<String, Set<String>> {
                            'Read' => new Set<String> {
                                'Id', 'SobjectType'
                                    }
                        }
    }; */
        private static Map<String, Map<String, Set<String>>> contactObjectChecks = new Map<String, Map<String, Set<String>>> {
            'Contact' => new Map<String, Set<String>> {
                'Read' => new Set<String> {}
            },
                'ListView' => new Map<String, Set<String>> {
                    'Read' => new Set<String> {
                        'Id', 'SobjectType'
                            }
                }
        }; 
            private static Map<String, Map<String, Set<String>>> accountObjectChecks = new Map<String, Map<String, Set<String>>> {
                'Account' => new Map<String, Set<String>> {
                    'Read' => new Set<String> {}
                },
                    'Contact' => new Map<String, Set<String>> {
                        'Read' => new Set<String> {}
                    },
                        'ListView' => new Map<String, Set<String>> {
                            'Read' => new Set<String> {
                                'Id', 'SobjectType'
                                    }
                        }
            }; 
                
            private static Map<String, Map<String, Set<String>>> campaignObjectChecks = new Map<String, Map<String, Set<String>>> {
                'Campaign' => new Map<String, Set<String>> {
                    'Read' => new Set<String> {}
                },
                    'CampaignMember' => new Map<String, Set<String>> {
                        'Read' => new Set<String> {}
                    },
                        'Contact' => new Map<String, Set<String>> {
                            'Read' => new Set<String> {}
                        },
                            'Lead' => new Map<String, Set<String>> {
                            'Read' => new Set<String> {}
                        },
                            'ListView' => new Map<String, Set<String>> {
                                'Read' => new Set<String> {
                                    'Id', 'SobjectType'
                                        }
                            }
            }; 
            private static Map<String, Map<String, Set<String>>> caseObjectChecks = new Map<String, Map<String, Set<String>>> {
                'Case' => new Map<String, Set<String>> {
                        'Create' => new Set<String> {
                            'Id', 'Name', 'Email', 'AccountId', 'ContactId'
                                }
                    },
                        'Contact' => new Map<String, Set<String>> {
                            'Read' => new Set<String> {}
                        },
                        
                        'ListView' => new Map<String, Set<String>> {
                            'Read' => new Set<String> {
                                'Id', 'SobjectType'
                                    }
                        }
            };
                private static Map<String, Map<String, Set<String>>> leadObjectChecks = new Map<String, Map<String, Set<String>>> {
                    'Lead' => new Map<String, Set<String>> {
                        'Read' => new Set<String> {}
                    }
                };
                    private static Map<String, Map<String, Set<String>>> opportunityContactObjectChecks = new Map<String, Map<String, Set<String>>> {
                        'Opportunity' => new Map<String, Set<String>> {
                            'Read' => new Set<String> {}
                        },
                            'Contact' => new Map<String, Set<String>> {
                                'Read' => new Set<String> {}
                            },
                        'OpportunityContactRole' => new Map<String, Set<String>> {
                                        'Read' => new Set<String> {
                                            'Id', 'ContactId'
                                                }
                                    },
                                        'ListView' => new Map<String, Set<String>> {
                                            'Read' => new Set<String> {
                                                'Id', 'SobjectType'
                                                    }
                                        }
                    };
            private static Map<String, Map<String, Set<String>>> customObjectChecks = new Map<String, Map<String, Set<String>>> {
                'Gift__c' => new Map<String, Set<String>> {
                    'Read' => new Set<String> {
                            'Email__c', 'Gift_Id__c', 'Id',
                            'Message__c', 'Name',  'OwnerId', 'Preview_Url__c', 'Recipient__c', 'Scheduled_At__c', 'Selected_Product__c', 'Sender_Name__c', 'Stage__c',
                            'Subject__c', 'Team__c', 'Thank_You_Note__c', 'User__c', 'Variant__c'
                            },
                                'Update' => new Set<String> {
                                    'Collection__c',  'Email__c', 'Gift_Id__c',
                                        'Message__c', 'Scheduled_At__c', 'Selected_Product__c','Stage__c',
                                        'Subject__c', 'Team__c', 'Thank_You_Note__c', 'User__c', 'Variant__c'
                                        },
                                            'Create' => new Set<String> {
                                                'Collection__c', 'Email__c', 'Gift_Id__c',
                                                     'Message__c', 'Scheduled_At__c', 'Selected_Product__c','Stage__c',
                                                    'Subject__c', 'Team__c', 'Thank_You_Note__c', 'User__c', 'Variant__c'
                                                    }
                },
                    'Setup_Data__c' => new Map<String, Set<String>> {
                        'Read' => new Set<String> {
                            'Id', 'pbo_Url__c', 'Name'
                                }
                    }
            };
                
                private static void checkAccess(Map<String, Map<String, Set<String>>> accessMapByObjectName, Boolean appendNamespace){
                    dmlManager.checkAccess(accessMapByObjectName, appendNamespace);
                }
    
    @Auraenabled 
    public static usersWrapper getUsers(){
        usersWrapper users = new usersWrapper();
        try{
            users.currentLoggedUser = userinfo.getName();
            users.currUserId = userInfo.getUserId();
            if(Schema.sObjectType.User.isAccessible()){
                users.UserList = [SELECT Id, Name,FirstName FROM User WHERE IsActive = true ];
            }
        }catch(Exception e){
            e.getMessage();
        }
        return users;
    }
    public class usersWrapper {
        @auraEnabled public List<User> UserList {get;set;}
        @auraenabled public String currentLoggedUser {get;set;} 
        @auraenabled public String currUserId {get;set;}
    }
    
    @AuraEnabled
    public static Map<String,String> getFieldsByObject(){
        Map<String,String> conLookupFields  = getAllLookupfields('Contact');
        Map<String,String> leadLookupFields = getAllLookupfields('Lead');   
        return leadLookupFields;
    }
    
    //main Method to get Fields
    public static Map<String,String> getAllLookupfields(String objectName){
        SObjectType objType = Schema.getGlobalDescribe().get(objectName); 
        Map<String,String> allLookupFields = new  Map<String,String>();
        try{
            Set<String> remove_keys = new Set<String>{'createdbyid','lastmodifiedbyid'};
                Map<String,Schema.SObjectField> mfields = objType.getDescribe().fields.getMap(); 
            for (String fieldName: mfields.keySet()) {
                //get all the fields label for Lead Object
                String fieldLabel = mfields.get(fieldName).getDescribe().getLabel(); 
                //get data types for each fields and fetch only Lookup
                Schema.DisplayType fielddataType = mfields.get(fieldName).getDescribe().getType(); 
                Schema.DescribeFieldResult f = mfields.get(fieldName).getDescribe();
                if(fielddataType == Schema.DisplayType.Reference){
                    for(Schema.SObjectType reference : f.getReferenceTo()) {
                        if(reference.getDescribe().getName() == 'User'){
                            allLookupFields.put(fieldName,fieldLabel);
                            
                        } 
                    } 
                }
            }
            allLookupFields.keySet().removeAll(remove_keys);
            System.debug('map'+allLookupFields);
        }catch(Exception e){
            e.getMessage();
        }
        return allLookupFields;
    }
}