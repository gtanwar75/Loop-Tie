@isTest
public class tst_cancelGift {
    @testSetup static void testsetup(){
        User u1 = new User(
            LastName = 'Test Contact',
            Email = 'test@test.com',
            Alias = 'test',
            Username = 'test' + (Math.Random() * 100000) + '@test.com',
            CommunityNickname = 'test',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'GMT',
            ProfileID = [SELECT Id FROM Profile WHERE Name='Standard User'].Id,
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8'
        );
        insert u1;
        
        LoopAndTieToken__c customSetting = LoopAndTieToken__c.getInstance(u1.Id);
        customSetting.Access_Token__c = 'testToken';
        upsert customSetting;
        
        Gift__c gift = new Gift__c( 
            Team__c = 'Sandbox',
            Email__c = 'test@test.com',
            Gift_Id__c = 'LT1234',
            Stage__c = 'scheduled'
        );
        insert gift;
        System.assert(true, true);
    }
    @isTest static void test_getUserApiToken(){
        Test.startTest();
        User user = [SELECT Id, Department 
                     FROM User 
                     WHERE LastName = 'Test Contact' 
                     LIMIT 1];
        
        String userId = (String) user.Id;
        String hasToken = cancelGift.getUserApiToken(userId);
        
        System.assertEquals('testToken', hasToken);
        Test.stopTest();
    }
    
    @isTest static void test_cancelGiftById(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
        Gift__c giftId = [SELECT Id, Gift_Id__c
                          FROM Gift__c
                          WHERE Email__c = 'test@test.com'];
        
        String response = cancelGift.cancelGiftById(giftId.Id);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        Map<String, Object> results = (Map<String, Object>)responseBody.get('results');
        System.debug('***********body' + results);
        Map<String, Object> body = (Map<String, Object>)results.get('body');
        System.debug('***********data' + body);
        if(body != null && body.containskey('data')){
            Map<String, Object> data = (Map<String, Object>)body.get('data');
            if(data.containskey('attributes')){
                Map<String, Object> attributes = (Map<String, Object>)data.get('attributes');
                String stage = (String)attributes.get('stage');
                
                System.assertEquals(responseBody.get('isSuccess'), true);
                System.assertEquals('canceled', stage);
            }
        }
        Test.stopTest();
        
    }
    
}