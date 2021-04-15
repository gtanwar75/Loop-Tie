@RestResource(urlMapping='/hubhook')
global without sharing class hubhook {
    @HttpPost
    global static void doPost() {
        /*** CUSTOM CODE ***/
        //this is were I process the push notifications from the pbo org
        //checkAccess(standardObjectChecks, false);
        //checkAccess(customObjectChecks, true);
        Map<String, Object> requestBody = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
        Map<String, Object> dataMap = (Map<String, Object>)requestBody.get('data');
        List<Object> includedList = (List<Object>)requestBody.get('included');//List
        Map<String, Object> attributes = (Map<String, Object>)dataMap.get('attributes');

        String giftId = (String)dataMap.get('id');
        String createdAt = '"' + (String)attributes.get('created-at') + '"';
        Date createdDate = ((DateTime)JSON.deserialize(createdAt, DateTime.class)).date();
        String event = (String)attributes.get('event');
        String message = (String)attributes.get('message');

        Map<String, Object> includedData = new Map<String, Object>();
        Map<String, Object> includedAttributes = new Map<String, Object>();
        String variant = '';
        Map<String, Object> variantMap = new Map<String, Object>();
        Map<String, Object> selectedProductData = new Map<String, Object> ();
        Map<String, Object> selectedProductAttributes = new Map<String, Object>();
        String name = '';
        Map<String, Object> selectedProduct =  new Map<String, Object>();
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>'+event);
        System.debug('Here is the List '+ includedList);

        if(event != 'messaged' && event != 'thanked'){
            if(event == 'redeemed'){
                //if the event is redeemed update stage, Variant, selected_product, Thank_you_note on gift record
                for(Object included : includedList){
                    System.debug('>>>>>>>>>>>>> '+included);
                    includedData = (Map<String, Object>)included;
            
                    includedAttributes = (Map<String, Object>)includedData.get('attributes');
                    if(includedAttributes.get('variant') == null){
                        variant = (String)includedAttributes.get('variant');
                    }else{
                        variantMap = (Map<String, Object>)includedAttributes.get('variant');
                        Map<String, Object> variantMapData = (Map<String, Object>)variantMap.get('data');
                        Map<String, Object> variantMapAttributes = (Map<String, Object>)variantMapData.get('attributes');
                        variant = (String)variantMapAttributes.get('name');
                    }
                    selectedProduct = (Map<String, Object>)includedAttributes.get('selected-product');
                    selectedProductData = ( Map<String, Object>)selectedProduct.get('data');
                    selectedProductAttributes = ( Map<String, Object>)selectedProductData.get('attributes');
                    name = (String)selectedProductAttributes.get('name');
                }

                Gift__c giftRecord = [SELECT Id, Lead_Id__c, Contact_Id__c, Gift_Id__c, Stage__c, Thank_you_note__c, Variant__c, Selected_Product__c
                                  FROM Gift__c
                                  WHERE Gift_Id__c =:giftId];
                giftRecord.Variant__c = String.isEmpty(variant) ? null : variant;
                giftRecord.Selected_Product__c = String.isEmpty(name) ? null : name;
                giftRecord.Stage__c = event;
                upsert giftRecord;

                /*String newSubject = 'Stage Updated to ' + event.capitalize();
                Task task = new Task (
                    WhoId = giftRecord.Contact_Id__c != null ? giftRecord.Contact_Id__c : null,
                    WhatId = giftRecord.Id,
                    Subject = newSubject,
                    Priority = 'Low',
                    Status = 'completed',
                    ActivityDate = createdDate
                );         
                insert task;*/

            }else{
                Gift__c giftRecord = [SELECT Id, Lead_Id__c, Contact_Id__c, Gift_Id__c, Stage__c, Thank_you_note__c, Variant__c, Selected_Product__c
                                      FROM Gift__c
                                      WHERE Gift_Id__c =:giftId];
                giftRecord.Stage__c = event;
                upsert giftRecord;

                //create completed task on gift giftRecord
                String newSubject = 'Stage Updated to ' + event.capitalize();
                /*Task task = new Task (
                    WhoId = giftRecord.Contact_Id__c != null ? giftRecord.Contact_Id__c : null,
                    WhatId = giftRecord.Id,
                    Subject = newSubject,
                    Priority = 'Low',
                    Status = 'completed',
                    ActivityDate = createdDate
                );         
                insert task;*/
            }

        }else if(event == 'thanked'){
            Gift__c giftRecord = [SELECT Id, Lead_Id__c, Contact_Id__c, Gift_Id__c, Stage__c, Thank_you_note__c, Variant__c, Selected_Product__c
                                  FROM Gift__c
                                  WHERE Gift_Id__c =:giftId];
            giftRecord.Thank_you_note__c = message;
            upsert giftRecord;

            /*Task task = new Task (
                WhoId = giftRecord.Contact_Id__c != null ? giftRecord.Contact_Id__c : null,
                WhatId = giftRecord.Id,
                Subject = 'Thank You Sent',
                Priority = 'Low',
                Status = 'completed',
                ActivityDate = createdDate
            );         
            insert task;*/
        }
    }

    private static Map<String, Map<String, Set<String>>> standardObjectChecks = new Map<String, Map<String, Set<String>>> {
        'Task' => new Map<String, Set<String>> {
            'Create' => new Set<String> {
                'WhatId', 'Subject', 'Priority', 'Status', 'ActivityDate'
            }
        }
    };

    private static Map<String, Map<String, Set<String>>> customObjectChecks = new Map<String, Map<String, Set<String>>> {
        'Gift__c' => new Map<String, Set<String>> {
            'Read' => new Set<String> {
                'Account_Id__c', 'Case_Id__c', 'Collection__c', 'Contact_Id__c', 'Email__c', 'Gift_Id__c', 'Id', 
                'Lead_Id__c', 'Message__c', 'Name', 'Opportunity_Id__c', 'OwnerId', 'Preview_Url__c', 'Recipient__c', 'Scheduled_At__c', 'Selected_Product__c', 'Sender_Name__c', 'Stage__c', 
                'Subject__c', 'Team__c', 'Thank_You_Note__c', 'User__c', 'Variant__c'
            },
            'Update' => new Set<String> {
               'Account_Id__c', 'Case_Id__c', 'Collection__c', 'Contact_Id__c', 'Email__c', 'Gift_Id__c', 
                'Lead_Id__c', 'Message__c', 'Opportunity_Id__c', 'Scheduled_At__c', 'Selected_Product__c','Stage__c', 
                'Subject__c', 'Team__c', 'Thank_You_Note__c', 'User__c', 'Variant__c'
            },
            'Create' => new Set<String> {
               'Account_Id__c', 'Case_Id__c', 'Collection__c', 'Contact_Id__c', 'Email__c', 'Gift_Id__c', 
                'Lead_Id__c', 'Message__c', 'Opportunity_Id__c', 'Scheduled_At__c', 'Selected_Product__c','Stage__c', 
                'Subject__c', 'Team__c', 'Thank_You_Note__c', 'User__c', 'Variant__c'
            }
        }
    };

    private static void checkAccess(Map<String, Map<String, Set<String>>> accessMapByObjectName, Boolean appendNamespace){
        dmlManager.checkAccess(accessMapByObjectName, appendNamespace);
    }
}