@isTest
public class tst_customizeMessage {
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
        System.assert(true, true);
    }
    
    @isTest static void test_getUserMessages(){
        
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
        String team = 'sandbox';
        User user = [SELECT Id, Department 
                     FROM User 
                     WHERE LastName = 'Test Contact' 
                     LIMIT 1];
        
        String response = customizeMessage.getUserMessages(team, user.Id);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        customizeMessage cm = new customizeMessage();
        String namespace = cm.namespace;
        //String response2 = customizeMessage.getUserMessages(null, null);
        System.assertEquals(true, responseBody.get('isSuccess'));
        Test.stopTest();
    }
    @isTest static void test_getUserMessagesNoUserId(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
        String team = 'sandbox';
        
        
        String response = customizeMessage.getUserMessages(team, null);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        
        Test.stopTest();
        System.assertEquals(true, responseBody.get('isSuccess'));
        
    }
    @isTest static void test_fetchUsersLookUp(){
        Test.startTest();
        customizeMessage.wrapUsers cm = new customizeMessage.wrapUsers();
        cm = customizeMessage.fetchUsersLookUp('a');
        Test.stopTest();
        System.assert(true);
    }
}