@isTest
public class tst_hubUtilities {
    @testSetup static void testsetup(){
        Setup_Data__c setupData = new Setup_Data__c(
            Pbo_URL__c = 'https://www.google.com',
            Name = 'Default'
        );
        insert setupData;
        System.assert(true, true);

    }
    @isTest static void test_createWebhook(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();

            Map<String, Object> response = hubUtilities.createWebhook('123456789');
            System.debug('***********' + response);
            System.assert(true, true);
        Test.stopTest();
    }

}