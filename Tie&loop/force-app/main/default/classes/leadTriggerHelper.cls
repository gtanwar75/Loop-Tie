public with sharing class leadTriggerHelper {
    public static void checkLeadConversion(Map<Id, Lead> oldTriggerObjs, List<Lead> newTriggerObjs){

        //checkAccess(standardObjectChecks, false);
        //checkAccess(customObjectChecks, true);
        List<Lead> convertedLeads = new List<Lead>();
        List<Map<String, String>> leadUpdateList = new List<Map<String, String>>();
        Map<String, String> leadUpdateMap = new Map<String, String>();
        List<String> leadUpdateIdsList = new List<String>();

        for(Lead newTrigObj : newTriggerObjs) {
            Lead oldTrigObj = oldTriggerObjs.get(newTrigObj.Id);
            if(oldTrigObj.IsConverted == false && newTrigObj.IsConverted == true) {
                convertedLeads.add(newTrigObj);
                leadUpdateMap.put('Id', newTrigObj.Id);
                leadUpdateMap.put('convertedAccountId', newTrigObj.ConvertedAccountId);
                leadUpdateMap.put('convertedContactId', newTrigObj.ConvertedContactId);
                leadUpdateMap.put('convertedOpportunityId', newTrigObj.ConvertedOpportunityId);
                leadUpdateList.add(leadUpdateMap);
                leadUpdateIdsList.add(newTrigObj.Id);
            }
        }
        List<Gift__c> giftRecordList = [SELECT Id, Lead_Id__c, Contact_Id__c, Account_Id__c, Opportunity_Id__c
                                        FROM Gift__c
                                        WHERE Lead_Id__c =:leadUpdateIdsList];
        
        List<Gift__c> giftRecordsToUpdateList = new List<Gift__c>();
        for(Gift__c gift : giftRecordList){
            for(Map<String, String> leadId : leadUpdateList){
                if(gift.Lead_Id__c == leadId.get('Id')){
                    if(Schema.sObjectType.Gift__c.fields.Contact_Id__c.isUpdateable() ||
                       Schema.sObjectType.Gift__c.fields.Contact_Id__c.isCreateable() ||
                       Schema.sObjectType.Gift__c.fields.Contact_Id__c.isAccessible() ||
                       Schema.sObjectType.Gift__c.fields.Account_Id__c.isUpdateable() ||
                       Schema.sObjectType.Gift__c.fields.Account_Id__c.isCreateable() ||
                       Schema.sObjectType.Gift__c.fields.Account_Id__c.isAccessible() ||
                       Schema.sObjectType.Gift__c.fields.Opportunity_Id__c.isUpdateable() ||
                       Schema.sObjectType.Gift__c.fields.Opportunity_Id__c.isCreateable() ||
                       Schema.sObjectType.Gift__c.fields.Opportunity_Id__c.isAccessible()) {
                            gift.Contact_Id__c = leadId.get('convertedContactId');
                            gift.Account_Id__c = leadId.get('convertedAccountId');
                            gift.Opportunity_Id__c = leadId.get('convertedOpportunityId');
                	}
                }
            }
            giftRecordsToUpdateList.add(gift);
        }
        upsert giftRecordsToUpdateList;
    }
    private static Map<String, Map<String, Set<String>>> standardObjectChecks = new Map<String, Map<String, Set<String>>> {
        'Lead' => new Map<String, Set<String>> {
            'Read' => new Set<String> {
                'IsConverted', 'Id', 'ConvertedAccountId', 'ConvertedContactId', 'ConvertedOpportunityId'
            }
        },
        'Opportunity' => new Map<String, Set<String>> {
            'Read' => new Set<String> {
                 'Id'
            },
            'Create' => new Set<String> {
                 'Id'
            }
        },
        'Contact' => new Map<String, Set<String>> {
            'Read' => new Set<String> {
                 'Id'
            },
            'Create' => new Set<String> {
                 'Id'
            }
        },
        'Account' => new Map<String, Set<String>> {
            'Read' => new Set<String> {
                 'Id'
            },
            'Create' => new Set<String> {
                 'Id'
            }
        }
    };
        
    private static Map<String, Map<String, Set<String>>> customObjectChecks = new Map<String, Map<String, Set<String>>> {
        'Gift__c' => new Map<String, Set<String>> {
            'Read' => new Set<String> {
                'Account_Id__c',  'Collection__c', 'Contact_Id__c', 'Email__c', 'Gift_Id__c', 'Id', 
                'Lead_Id__c', 'Message__c', 'Name', 'Opportunity_Id__c', 'OwnerId', 'Preview_Url__c', 'Recipient__c', 'Scheduled_At__c', 'Selected_Product__c', 'Sender_Name__c', 'Stage__c', 
                'Subject__c', 'Team__c', 'Thank_You_Note__c', 'User__c', 'Variant__c'
            },
            'Update' => new Set<String> {
               'Account_Id__c', 'Collection__c', 'Contact_Id__c', 'Email__c', 'Gift_Id__c', 
                'Lead_Id__c', 'Message__c', 'Opportunity_Id__c', 'Scheduled_At__c', 'Selected_Product__c','Stage__c', 
                'Subject__c', 'Team__c', 'Thank_You_Note__c', 'User__c', 'Variant__c'
            },
            'Create' => new Set<String> {
               'Account_Id__c', 'Collection__c', 'Contact_Id__c', 'Email__c', 'Gift_Id__c', 
                'Lead_Id__c', 'Message__c', 'Opportunity_Id__c', 'Scheduled_At__c', 'Selected_Product__c','Stage__c', 
                'Subject__c', 'Team__c', 'Thank_You_Note__c', 'User__c', 'Variant__c'
            }
        }
    };

    private static void checkAccess(Map<String, Map<String, Set<String>>> accessMapByObjectName, Boolean appendNamespace){
        dmlManager.checkAccess(accessMapByObjectName, appendNamespace);
    }
}