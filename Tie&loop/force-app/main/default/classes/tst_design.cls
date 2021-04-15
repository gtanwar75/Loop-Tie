@isTest
public class tst_design {
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

    @isTest static void test_getUserDesigns(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
            String team = 'sandbox';
            User user = [SELECT Id, Department 
                         FROM User 
                         WHERE LastName = 'Test Contact' 
                         LIMIT 1];

            String response = design.getUserDesigns(team, user.Id);
            Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
            System.debug('THISHERE: ' + responseBody);

            System.assertEquals(true, responseBody.get('isSuccess'));
        Test.stopTest();
    }
    @isTest static void test_getUserDesignsNoUserId(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
            String team = 'sandbox';
           

            String response = design.getUserDesigns(team, null);
            Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
            System.debug('THISHERE: ' + responseBody);

            System.assertEquals(true, responseBody.get('isSuccess'));
        Test.stopTest();
    }

    @isTest static void test_getUserLogos(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
            String team = 'sandbox';
            User user = [SELECT Id, Department 
                         FROM User 
                         WHERE LastName = 'Test Contact' 
                         LIMIT 1];

            String response = design.getUserLogos(team, user.Id);
            Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
            System.debug('THISHERE: ' + responseBody);

            System.assertEquals(true, responseBody.get('isSuccess'));
        Test.stopTest();
    }
    
    @isTest static void test_getUserLogosNoUserId(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
            String team = 'sandbox';
           
            String response = design.getUserLogos(team, null);
            Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
            System.debug('THISHERE: ' + responseBody);

            System.assertEquals(true, responseBody.get('isSuccess'));
        Test.stopTest();
    }


}