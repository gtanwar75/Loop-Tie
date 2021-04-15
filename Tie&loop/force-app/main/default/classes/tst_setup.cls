@isTest
public with sharing class tst_setup {
    @isTest
    static public void testSetup() {
        Test.startTest();
        setup con = new setup();
        Test.stopTest();

        System.assertEquals(constants.NAMESPACE, con.namespace);
    }

    @isTest
    static public void testSetup_saveData() {
        Setup_Data__c settings = new Setup_Data__c(
            Steps_Completed__c = 0
        );

        Test.startTest();
        String response = setup.saveData(JSON.serialize(settings));
        System.debug('**************' + response);
        Test.stopTest();

        List<Setup_Data__c> newSettings = [SELECT Id, Name, Steps_Completed__c FROM Setup_Data__c];
        System.assert(0 < newSettings.size(), '`settings` not found');
        System.assert(2 > newSettings.size(), 'multiple `settings` found');

        System.assertEquals('Default', newSettings.get(0).Name);
        System.assertEquals(settings.Steps_Completed__c, newSettings.get(0).Steps_Completed__c);
    }

    @isTest
    static public void testSetup_getData() {
        Setup_Data__c settings = new Setup_Data__c(
            Steps_Completed__c = 0
        );
        setup.saveData(JSON.serialize(settings));

        Test.startTest();
        String response = setup.getData();
        Test.stopTest();

        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.assert((Boolean)responseMap.get('isSuccess'), responseMap.get('error'));

        Map<String, Object> resultsMap = (Map<String, Object>)responseMap.get('results');
        System.assert(resultsMap.containsKey('data'), '`data` not found');
        Map<String, Object> dataMap = (Map<String, Object>)resultsMap.get('data');

        System.assert(dataMap.containsKey('Steps_Completed__c'), '`Steps_Completed__c` not found');
        System.assertEquals(settings.Steps_Completed__c, (Decimal)dataMap.get('Steps_Completed__c'));
    }
}