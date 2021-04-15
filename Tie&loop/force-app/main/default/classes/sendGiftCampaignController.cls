public class sendGiftCampaignController{
    
    @AuraEnabled 
    public static responseClass giftsToCampaignMembers(String campaignId,String giftStatus, String fMember){
        Set<Id> setOfContacts = new Set<Id>();
        Set<Id> setOfLeads = new Set<Id>();
        
        responseClass rc = new responseClass();
        List<giftsToUser> userList = new List<giftsToUser>();
        try{
            checkAccess(campaignMemberObjectAccess, true);
            if (Schema.sObjectType.CampaignMember.isAccessible()) {
                for(CampaignMember cmp : [SELECT id,Name,CampaignId,ContactId,LeadId FROM CampaignMember WHERE CampaignId =:campaignId]){
                    if(!String.isBlank(cmp.ContactId)) setOfContacts.add(cmp.ContactId);
                    if(!String.isBlank(cmp.LeadId)) setOfLeads.add(cmp.LeadId);
                }
            }
            
            if(giftStatus != null || fMember != null){
                if(giftStatus != 'none'){
                    if(setOfContacts.size() > 0 && fMember == 'Contact'){
                        if (Schema.sObjectType.Contact.isAccessible()) {
                            for(Contact con : [SELECT Id,Name, (SELECT Id,Name,lnt__Email__c,lnt__Stage__c,lnt__Contact_Id__c,lnt__Lead_Id__c FROM lnt__Gifts__r WHERE lnt__Stage__c =: giftStatus ORDER BY CreatedDate DESC LIMIT 1) FROM Contact WHERE Id IN :setOfContacts]){
                                if(con.lnt__Gifts__r.size() > 0){
                                    giftsToUser gtu = new giftsToUser();
                                    gtu.id = con.id;
                                    gtu.name =	con.Name;
                                    gtu.email =	con.lnt__Gifts__r[0].lnt__Email__c;
                                    gtu.memberType = 'Contact';
                                    if(String.isNotBlank(con.lnt__Gifts__r[0].lnt__Stage__c)){
                                        gtu.giftStatus = con.lnt__Gifts__r[0].lnt__Stage__c;
                                    }else{
                                        gtu.giftStatus = '';
                                    }
                                    
                                    userList.add(gtu); 
                                }                   
                            }
                        }
                    }
                    else if(setOfLeads.size() > 0 && fMember == 'Lead'){
                        if(Schema.sObjectType.Lead.isAccessible()){
                            for(Lead ld : [SELECT Id,Name, (SELECT Id,Name,lnt__Email__c,lnt__Stage__c,lnt__Contact_Id__c,lnt__Lead_Id__c FROM lnt__Gifts__r WHERE lnt__Stage__c =: giftStatus ORDER BY CreatedDate DESC LIMIT 1) FROM Lead WHERE Id IN :setOfLeads]){
                                if(ld.lnt__Gifts__r.size() > 0){
                                    giftsToUser gtu = new giftsToUser();
                                    gtu.id = ld.id;
                                    gtu.name =	ld.Name;
                                    gtu.email =	ld.lnt__Gifts__r[0].lnt__Email__c;
                                    gtu.memberType = 'Lead';
                                    gtu.giftStatus = ld.lnt__Gifts__r[0].lnt__Stage__c;
                                    userList.add(gtu); 
                                }                  
                            }
                        }
                    }
                    else if(fMember == 'Both'){
                        if(setOfContacts.size() > 0){
                            if(Schema.sObjectType.Contact.isAccessible()){
                                for(Contact con : [SELECT Id,Name, (SELECT Id,Name,lnt__Email__c,lnt__Stage__c,lnt__Contact_Id__c,lnt__Lead_Id__c FROM lnt__Gifts__r WHERE lnt__Stage__c =: giftStatus ORDER BY CreatedDate DESC LIMIT 1) FROM Contact WHERE Id IN :setOfContacts]){
                                    if(con.lnt__Gifts__r.size() > 0){
                                        giftsToUser gtu = new giftsToUser();
                                        gtu.id = con.id;
                                        gtu.name =	con.Name;
                                        gtu.email =	con.lnt__Gifts__r[0].lnt__Email__c;
                                        gtu.memberType = 'Contact';
                                        gtu.giftStatus = con.lnt__Gifts__r[0].lnt__Stage__c;
                                        userList.add(gtu); 
                                    }                  
                                }
                            }
                        }
                        if(setOfLeads.size() > 0){
                            if(Schema.sObjectType.Lead.isAccessible()){
                                for(Lead ld : [SELECT Id,Name, (SELECT Id,Name,lnt__Email__c,lnt__Stage__c,lnt__Contact_Id__c,lnt__Lead_Id__c FROM lnt__Gifts__r WHERE lnt__Stage__c =: giftStatus ORDER BY CreatedDate DESC LIMIT 1) FROM Lead WHERE Id IN :setOfLeads]){
                                    if(ld.lnt__Gifts__r.size() > 0){
                                        giftsToUser gtu = new giftsToUser();
                                        gtu.id = ld.id;
                                        gtu.name =	ld.Name;
                                        gtu.email =	ld.lnt__Gifts__r[0].lnt__Email__c;
                                        gtu.memberType = 'Lead';
                                        gtu.giftStatus = ld.lnt__Gifts__r[0].lnt__Stage__c;
                                        userList.add(gtu); 
                                    }                   
                                }
                            }
                        }
                    } 
                }
                else{
                    if(setOfContacts.size() > 0 && fMember == 'Contact'){
                        if(Schema.sObjectType.Contact.isAccessible()){
                            for(Contact con : [SELECT Id,Name, (SELECT Id,Name,lnt__Email__c,lnt__Stage__c,lnt__Contact_Id__c,lnt__Lead_Id__c FROM lnt__Gifts__r ORDER BY CreatedDate DESC LIMIT 1) FROM Contact WHERE Id IN :setOfContacts]){
                                if(con.lnt__Gifts__r.size() > 0){
                                    giftsToUser gtu = new giftsToUser();
                                    gtu.id = con.id;
                                    gtu.name =	con.Name;
                                    gtu.email =	con.lnt__Gifts__r[0].lnt__Email__c;
                                    gtu.memberType = 'Contact';
                                    gtu.giftStatus = con.lnt__Gifts__r[0].lnt__Stage__c;
                                    userList.add(gtu); 
                                }                   
                            }
                        }
                    }
                    else if(setOfLeads.size() > 0 && fMember == 'Lead'){
                        if(Schema.sObjectType.Lead.isAccessible()){
                            for(Lead ld : [SELECT Id,Name, (SELECT Id,Name,lnt__Email__c,lnt__Stage__c,lnt__Contact_Id__c,lnt__Lead_Id__c FROM lnt__Gifts__r ORDER BY CreatedDate DESC LIMIT 1) FROM Lead WHERE Id IN :setOfLeads]){
                                if(ld.lnt__Gifts__r.size() > 0){
                                    giftsToUser gtu = new giftsToUser();
                                    gtu.id = ld.id;
                                    gtu.name =	ld.Name;
                                    gtu.email =	ld.lnt__Gifts__r[0].lnt__Email__c;
                                    gtu.memberType = 'Lead';
                                    gtu.giftStatus = ld.lnt__Gifts__r[0].lnt__Stage__c;
                                    userList.add(gtu); 
                                }                   
                            }
                        }
                    }
                    else if(fMember == 'Both'){
                        if(setOfContacts.size() > 0){
                            if(Schema.sObjectType.Contact.isAccessible()){
                                for(Contact con : [SELECT Id,Name, (SELECT Id,Name,lnt__Email__c,lnt__Stage__c,lnt__Contact_Id__c,lnt__Lead_Id__c FROM lnt__Gifts__r ORDER BY CreatedDate DESC LIMIT 1) FROM Contact WHERE Id IN :setOfContacts]){
                                    if(con.lnt__Gifts__r.size() > 0){
                                        giftsToUser gtu = new giftsToUser();
                                        gtu.id = con.id;
                                        gtu.name =	con.Name;
                                        gtu.email =	con.lnt__Gifts__r[0].lnt__Email__c;
                                        gtu.memberType = 'Contact';
                                        gtu.giftStatus = con.lnt__Gifts__r[0].lnt__Stage__c;
                                        userList.add(gtu); 
                                    }                  
                                }
                            }
                        }
                        if(setOfLeads.size() > 0){
                            if(Schema.sObjectType.Lead.isAccessible()){
                                for(Lead ld : [SELECT Id,Name, (SELECT Id,Name,lnt__Email__c,lnt__Stage__c,lnt__Contact_Id__c,lnt__Lead_Id__c FROM lnt__Gifts__r ORDER BY CreatedDate DESC LIMIT 1) FROM Lead WHERE Id IN :setOfLeads]){
                                    if(ld.lnt__Gifts__r.size() > 0){
                                        giftsToUser gtu = new giftsToUser();
                                        gtu.id = ld.id;
                                        gtu.name =	ld.Name;
                                        gtu.email =	ld.lnt__Gifts__r[0].lnt__Email__c;
                                        gtu.memberType = 'Lead';
                                        gtu.giftStatus = ld.lnt__Gifts__r[0].lnt__Stage__c;
                                        userList.add(gtu); 
                                    } 
                                }
                            }
                        }
                    }
                }
            }
            else{
                if(setOfContacts.size() > 0){
                    if(Schema.sObjectType.Contact.isAccessible()){
                        for(Contact con : [SELECT Id,Name, (SELECT Id,Name,lnt__Email__c,lnt__Stage__c,lnt__Contact_Id__c,lnt__Lead_Id__c FROM lnt__Gifts__r ORDER BY CreatedDate DESC LIMIT 1) FROM Contact WHERE Id IN :setOfContacts]){
                            if(con.lnt__Gifts__r.size() > 0){
                                giftsToUser gtu = new giftsToUser();
                                gtu.id = con.id;
                                gtu.name =	con.Name;
                                gtu.email =	con.lnt__Gifts__r[0].lnt__Email__c;
                                gtu.memberType = 'Contact';
                                gtu.giftStatus = con.lnt__Gifts__r[0].lnt__Stage__c;
                                userList.add(gtu); 
                            }
                        }
                    }
                } 
                if(setOfLeads.size() > 0){
                    if(Schema.sObjectType.Lead.isAccessible()){
                        for(Lead ld : [SELECT Id,Name, (SELECT Id,Name,lnt__Email__c,lnt__Stage__c,lnt__Contact_Id__c,lnt__Lead_Id__c FROM lnt__Gifts__r ORDER BY CreatedDate DESC LIMIT 1) FROM Lead WHERE Id IN :setOfLeads]){
                            if(ld.lnt__Gifts__r.size() > 0){
                                giftsToUser gtu = new giftsToUser();
                                gtu.id = ld.id;
                                gtu.name =	ld.Name;
                                gtu.email =	ld.lnt__Gifts__r[0].lnt__Email__c;
                                gtu.memberType = 'Lead';
                                gtu.giftStatus = ld.lnt__Gifts__r[0].lnt__Stage__c;
                                userList.add(gtu);
                            }
                        }
                    }
                }
            }
            rc.userList = userList;
            rc.isSuccess = true;
            rc.message = 'Success';
        }catch(Exception e){
            e.getMessage();
            rc.userList = userList;
            rc.isSuccess = false;
            rc.message = e.getMessage();
        }
        return rc;  
    }
    
    public class giftsToUser{
        @AuraEnabled
        public String id{get; set;}
        @AuraEnabled
        public String name{get; set;}
        @AuraEnabled
        public String email{get; set;}
        @AuraEnabled
        public String memberType{get; set;}
        @AuraEnabled
        public String giftStatus{get; set;}
    }
    
    private static Map<String, Map<String, Set<String>>> campaignMemberObjectAccess = new Map<String, Map<String, Set<String>>> {
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
                    }
        
    };
        private static void checkAccess(Map<String, Map<String, Set<String>>> accessMapByObjectName, Boolean appendNamespace){
            dmlManager.checkAccess(accessMapByObjectName, appendNamespace);
        }
    
    
    public class responseClass{
        @AuraEnabled public List<giftsToUser> userList {get;set;}
        @AuraEnabled public String message {get;set;}
        @AuraEnabled public Boolean isSuccess {get;set;}
    }
}