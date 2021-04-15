public with sharing class cancelGift {
    public String namespace { get; set; }

    public cancelGift(ApexPages.StandardController sc) {
        namespace = constants.NAMESPACE;
    }

    public static String getUserApiToken(String userId){     
        LoopAndTieToken__c customSetting = LoopAndTieToken__c.getInstance(userId);
        String apiToken = customSetting.Access_Token__c;
        
        return apiToken;
        
    }
    @AuraEnabled
    public static String cancelGiftById(String recordId) {
        responseData rd = new responseData();
        try{
            //checkAccess(standardObjectChecks, false);
            checkAccess(customObjectChecks, true);
            String accessToken = getUserAPIToken(UserInfo.getUserId());
            Map<String, String> headers = new Map<String, String>();
            headers.put('Authorization', 'Bearer ' + accessToken);
            headers.put('Content-Type', 'application/json');

            Gift__c gift = [SELECT Id, Team__c, Gift_Id__c
                            FROM Gift__c
                            WHERE Id =:recordId];

            String team = gift.Team__c;
            String giftId = gift.Gift_Id__c;

            String endpoint = constants.BASE_LOOPTIE_API + '/teams/' + team + '/gifts/' + giftId;
            System.debug('ENDPOINT '+endpoint);


            HttpResponse res = utilities.makeCallout(endpoint, 'DELETE', null, headers);
            Map<String, Object> returnedData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            if(res.getStatusCode() == 200) {
                
                System.debug('********************** ' + returnedData);
                Map<String, Object> data = (Map<String, Object>)returnedData.get('data');
                Map<String, Object> attributes = (Map<String, Object>)data.get('attributes');
                String stage = (String)attributes.get('stage');

                Gift__c giftRecord = [SELECT Id, Team__c, Gift_Id__c, Stage__c
                                FROM Gift__c
                                WHERE Id =:recordId];

                giftRecord.Stage__c = stage;
                upsert giftRecord;

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

    private static Map<String, Map<String, Set<String>>> standardObjectChecks = new Map<String, Map<String, Set<String>>> {
        'Task' => new Map<String, Set<String>> {
            'Create' => new Set<String> {
                'WhatId', 'Subject', 'Priority', 'Status'
            }
        }
    };

    private static Map<String, Map<String, Set<String>>> customObjectChecks = new Map<String, Map<String, Set<String>>> {
        'Gift__c' => new Map<String, Set<String>> {
            'Read' => new Set<String> {
                'Collection__c', 'Email__c', 'Gift_Id__c', 'Id', 
                'Message__c', 'Name', 'OwnerId', 'Preview_Url__c', 'Recipient__c', 'Scheduled_At__c', 'Selected_Product__c', 'Sender_Name__c', 'Stage__c', 
                'Subject__c', 'Team__c', 'Thank_You_Note__c', 'User__c', 'Variant__c'
            },
            'Update' => new Set<String> {
                'Collection__c', 'Email__c', 'Gift_Id__c', 
                'Message__c', 'Scheduled_At__c', 'Selected_Product__c','Stage__c', 
                'Subject__c', 'Team__c', 'Thank_You_Note__c', 'User__c', 'Variant__c'
            }
        }
    };

    private static void checkAccess(Map<String, Map<String, Set<String>>> accessMapByObjectName, Boolean appendNamespace){
        dmlManager.checkAccess(accessMapByObjectName, appendNamespace);
    }
}