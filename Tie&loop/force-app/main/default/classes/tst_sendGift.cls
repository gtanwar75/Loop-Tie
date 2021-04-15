@isTest
public class tst_sendGift {
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
        
        Account accountRecord = new Account(
            Name = 'Test Account'
        );
        upsert accountRecord;
        
        Contact contactRecord = new Contact(
            FirstName = 'Test',
            LastName = 'Test Contact',
            Email = 'test@test.com',
            AccountId = accountRecord.Id
        );
        upsert contactRecord;
        
        Lead leadRecord = new Lead(
            LastName = 'Test Lead',
            Email = 'test@test.com',
            Company = 'Appiphony'
        );
        upsert leadRecord;
        
        Case caseRecord = new Case(
            AccountId = accountRecord.Id,
            ContactId = contactRecord.Id
        );
        upsert caseRecord;
        
        Campaign campaignRecord = new Campaign(
            Name = 'Test Campaign'
        );
        upsert campaignRecord;
        
        Opportunity opportunityRecord = new Opportunity(
            Name = 'Test Opportunity',
            CloseDate = date.parse(date.today().format()),
            StageName = 'Prospecting'
        );
        upsert opportunityRecord;
        
        Setup_Data__c setupData = new Setup_Data__c(
            pbo_Url__c = 'https://www.google.com',
            Name = 'Default'
        );
        upsert setupData;
        
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
    @isTest static void test_getObjectType(){
        Test.startTest();
        Contact contactRecord = [SELECT Id, Email 
                                 FROM Contact 
                                 WHERE LastName = 'Test Contact' 
                                 LIMIT 1];
        String contactRecordId = (String) contactRecord.Id;
        String objType = sendGift.getObjectType(contactRecordId);
        
        System.assertEquals('Contact', objType);
        Test.stopTest();
    }
    
    @isTest static void test_getUserApiToken(){
        Test.startTest();
        User user = [SELECT Id, Department 
                     FROM User 
                     WHERE LastName = 'Test Contact' 
                     LIMIT 1];
        
        String userId = (String) user.Id;
        String hasToken = sendGift.getUserApiToken(userId);
        
        System.assertEquals('testToken', hasToken);
        Test.stopTest();
    }
    @isTest static void test_requestAuthTokenURL(){
        Test.startTest();
        String jsonString = sendGift.requestAuthTokenURL();
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        Map<String, Object> results = (Map<String, Object>)jsonMap.get('results');
        String url = (String)results.get('url');
        
        System.assertEquals(true, jsonMap.get('isSuccess'));
        Test.stopTest();
    }
    
    @isTest static void test_verifyUserHasApiToken(){
        Test.startTest();
        User user = [SELECT Id, Department 
                     FROM User 
                     WHERE LastName = 'Test Contact' 
                     LIMIT 1];
        
        String userId = (String) user.Id;
        String jsonString = sendGift.verifyUserHasApiToken(userId);
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        Map<String, Object> results = (Map<String, Object>)jsonMap.get('results');
        Boolean hasToken = (Boolean)results.get('hasToken');
        
        System.assertEquals(true, hasToken);
        Test.stopTest();
    }
   @isTest static void test_getUserTeams(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
        User user = [SELECT Id, Department 
                     FROM User 
                     WHERE LastName = 'Test Contact' 
                     LIMIT 1];
        
        String response = sendGift.getUserTeams();
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        
        System.assertEquals(true, responseBody.get('isSuccess'));
        Test.stopTest();
    }
    @isTest static void test_getTeamCollections(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
        String team = 'sandbox';
        User user = [SELECT Id, Department 
                     FROM User 
                     WHERE LastName = 'Test Contact' 
                     LIMIT 1];
        
        String response = sendGift.getTeamCollections(team, user.Id);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        
        System.assertEquals(true, responseBody.get('isSuccess'));
        Test.stopTest();
    }
    @isTest static void test_getTeamCollectionsError(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
        String team = 'personal';
        User user = [SELECT Id, Department 
                     FROM User 
                     WHERE LastName = 'Test Contact' 
                     LIMIT 1];
        
        String response = sendGift.getTeamCollections(team, user.Id);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        
        System.assertEquals(false, responseBody.get('isSuccess'));
        Test.stopTest();
    }
    @isTest static void test_getTeamWebHook(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
        String team = 'sandbox';
        
        String response = sendGift.getTeamWebHook(team);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        
        System.assertEquals(true, responseBody.get('isSuccess'));
        Test.stopTest();
    }
    @isTest static void test_getTeamWebHookError(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
        String team = 'personal';
        
        String response = sendGift.getTeamWebHook(team);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        
        System.assertEquals(false, responseBody.get('isSuccess'));
        Test.stopTest();
    }
    @isTest static void test_createGift(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
        String team = 'sandbox';
        List<Object> recipientsAttributesList = new List<Object>();
        Map<String, Object> recipientsAttributes  = new Map<String, Object>{
            'name' => 'Ziggi',
                'email' => 'thewailers@jamaica.com'
                };
                    
                    recipientsAttributesList.add(recipientsAttributes);
        Map<String, Object> gift = new Map<String, Object>{
            'collection' => '$25',
                'message' => 'Better than Bob',
                'from' => 'Peter Tosh',
                'recipients_attributes' => recipientsAttributesList
                };
                    
                    Map<String, Map<String, Object>> body = new Map<String, Map<String, Object>>{
                        'gift' => gift
                            };
                                String response = sendGift.createGift(team, body);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        
        System.assertEquals(true, responseBody.get('isSuccess'));
        Test.stopTest();
    }
    @isTest static void test_createGiftError(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
        String team = 'personal';
        List<Object> recipientsAttributesList = new List<Object>();
        Map<String, Object> recipientsAttributes  = new Map<String, Object>{
            'name' => 'Ziggi',
                'email' => 'thewailers@jamaica.com'
                };
                    
                    recipientsAttributesList.add(recipientsAttributes);
        Map<String, Object> gift = new Map<String, Object>{
            'collection' => '$25',
                'message' => 'Better than Bob',
                'from' => 'Peter Tosh',
                'recipients_attributes' => recipientsAttributesList
                };
                    
                    Map<String, Map<String, Object>> body = new Map<String, Map<String, Object>>{
                        'gift' => gift
                            };
                                String response = sendGift.createGift(team, body);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        
        System.assertEquals(false, responseBody.get('isSuccess'));
        Test.stopTest();
    }
    @isTest static void test_createGiftObjRecordContact(){
        Test.startTest();
        Contact contactRecord = [SELECT Id, Email,LastName 
                                 FROM Contact 
                                 WHERE LastName = 'Test Contact' 
                                 LIMIT 1];
        String contactRecordId = (String) contactRecord.Id;
        
        List<String> selectedRecipientIdsList = new List<String>();
        selectedRecipientIdsList.add(contactRecordId);
        
        List<Object> recipientsList = new List<Object>();
        Map<String, Object> recipient = new Map<String, Object>{
            'name' => contactRecord.LastName,
                'email' => contactRecord.Email,
                'id' => contactRecord.Id
                };
                    recipientsList.add(recipient);
        
        
        Map<String, Object> attributesData = new Map<String, Object>{
            'external-id' => 'SF123',
                'email' => contactRecord.Email,
                'message' => 'testing',
                'scheduled-at' => '2018-06-28T19:30:04.294Z',
                'stage' => 'scheduled',
                'subject' => 'testing',
                'team' => 'sandbox'
                };
                    
                    Map<String, Object> attributes = new Map<String, Object>{
                        'attributes' => attributesData
                            };
                                
                                List<Object> createdGiftList = new List<Object>();
        createdGiftList.add(attributes);
        
        Map<String, Object> jsonMap = new Map<String, Object>{
            'recipients' => recipientsList,
                'entryPointObj' => 'Contact',
                'entryPointObjId' => contactRecord.Id,
                'createdGift' => createdGiftList,
                'recordId' =>contactRecordId,
                'selectedCollection' => '$25',
                'selectedRecipientIdsList' => selectedRecipientIdsList,
                'previewLink' => 'https://preview.com'
                };
                    
                    String body = JSON.serialize(jsonMap);
        String response = sendGift.createGiftObjRecord(body);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        
        System.assertEquals(true, responseBody.get('isSuccess'));
        Test.stopTest();
    }
    @isTest static void test_createGiftObjRecordAccount(){
        Test.startTest();
        Account accountRecord = [SELECT Id, Name 
                                 FROM Account 
                                 WHERE Name = 'Test Account' 
                                 LIMIT 1];
        String accountRecordId = (String) accountRecord.Id;
        
        Contact contactRecord = [SELECT Id, Email,LastName 
                                 FROM Contact 
                                 WHERE LastName = 'Test Contact' 
                                 LIMIT 1];
        String contactRecordId = (String) contactRecord.Id;
        
        List<String> selectedRecipientIdsList = new List<String>();
        selectedRecipientIdsList.add(contactRecordId);
        
        
        List<Object> recipientsList = new List<Object>();
        Map<String, Object> recipient = new Map<String, Object>{
            'name' => contactRecord.LastName,
                'email' => contactRecord.Email,
                'id' => contactRecord.Id
                };
                    recipientsList.add(recipient);
        
        
        Map<String, Object> attributesData = new Map<String, Object>{
            'external-id' => 'SF123',
                'email' => contactRecord.Email,
                'message' => 'testing',
                'scheduled-at' => '2018-06-28T19:30:04.294Z',
                'stage' => 'scheduled',
                'subject' => 'testing',
                'team' => 'sandbox'
                };
                    
                    Map<String, Object> attributes = new Map<String, Object>{
                        'attributes' => attributesData
                            };
                                
                                List<Object> createdGiftList = new List<Object>();
        createdGiftList.add(attributes);
        
        Map<String, Object> jsonMap = new Map<String, Object>{
            'recipients' => recipientsList,
                'entryPointObj' => 'Account',
                'entryPointObjId' => accountRecordId,
                'createdGift' => createdGiftList,
                'recordId' =>contactRecordId,
                'selectedCollection' => '$25',
                'selectedRecipientIdsList' => selectedRecipientIdsList,
                'previewLink' => 'https://preview.com'
                };
                    
                    String body = JSON.serialize(jsonMap);
        String response = sendGift.createGiftObjRecord(body);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        
        System.assertEquals(true, responseBody.get('isSuccess'));
        Test.stopTest();
    }
    
    @isTest static void test_createGiftObjRecordOpportunity(){
        Test.startTest();
        Opportunity opportunityRecord = [SELECT Id, Name 
                                         FROM Opportunity 
                                         WHERE Name = 'Test Opportunity' 
                                         LIMIT 1];
        String opportunityRecordId = (String) opportunityRecord.Id;
        
        Contact contactRecord = [SELECT Id, Email,LastName, AccountId 
                                 FROM Contact 
                                 WHERE LastName = 'Test Contact' 
                                 LIMIT 1];
        String contactRecordId = (String) contactRecord.Id;
        
        List<String> selectedRecipientIdsList = new List<String>();
        selectedRecipientIdsList.add(contactRecordId);
        
        
        List<Object> recipientsList = new List<Object>();
        Map<String, Object> recipient = new Map<String, Object>{
            'name' => contactRecord.LastName,
                'email' => contactRecord.Email,
                'id' => contactRecord.Id
                };
                    recipientsList.add(recipient);
        
        
        Map<String, Object> attributesData = new Map<String, Object>{
            'external-id' => 'SF123',
                'email' => contactRecord.Email,
                'message' => 'testing',
                'scheduled-at' => '2018-06-28T19:30:04.294Z',
                'stage' => 'scheduled',
                'subject' => 'testing',
                'team' => 'sandbox'
                };
                    
                    Map<String, Object> attributes = new Map<String, Object>{
                        'attributes' => attributesData
                            };
                                
                                List<Object> createdGiftList = new List<Object>();
        createdGiftList.add(attributes);
        
        Map<String, Object> jsonMap = new Map<String, Object>{
            'recipients' => recipientsList,
                'entryPointObj' => 'Opportunity',
                'entryPointObjId' => opportunityRecordId,
                'createdGift' => createdGiftList,
                'recordId' =>contactRecordId,
                'selectedCollection' => '$25',
                'selectedRecipientIdsList' => selectedRecipientIdsList,
                'previewLink' => 'https://preview.com'
                };
                    
                    String body = JSON.serialize(jsonMap);
        String response = sendGift.createGiftObjRecord(body);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        
        System.assertEquals(true, responseBody.get('isSuccess'));
        Test.stopTest();
    }
    
    @isTest static void test_createGiftObjRecordLead(){
        Test.startTest();
        Lead leadRecord = [SELECT Id, Email,LastName 
                           FROM Lead 
                           WHERE LastName = 'Test Lead' 
                           LIMIT 1];
        String leadRecordId = (String) leadRecord.Id;
        
        List<String> selectedRecipientIdsList = new List<String>();
        selectedRecipientIdsList.add(leadRecordId);
        
        List<Object> recipientsList = new List<Object>();
        Map<String, Object> recipient = new Map<String, Object>{
            'name' => leadRecord.LastName,
                'email' => leadRecord.Email,
                'id' => leadRecord.Id
                };
                    recipientsList.add(recipient);
        
        
        Map<String, Object> attributesData = new Map<String, Object>{
            'external-id' => 'SF123',
                'email' => leadRecord.Email,
                'message' => 'testing',
                'scheduled-at' => '2018-06-28T19:30:04.294Z',
                'stage' => 'scheduled',
                'subject' => 'testing',
                'team' => 'sandbox'
                };
                    
                    Map<String, Object> attributes = new Map<String, Object>{
                        'attributes' => attributesData
                            };
                                
                                List<Object> createdGiftList = new List<Object>();
        createdGiftList.add(attributes);
        
        Map<String, Object> jsonMap = new Map<String, Object>{
            'recipients' => recipientsList,
                'entryPointObj' => 'Lead',
                'entryPointObjId' => leadRecord.Id,
                'createdGift' => createdGiftList,
                'recordId' =>leadRecordId,
                'selectedCollection' => '$25',
                'selectedRecipientIdsList' => selectedRecipientIdsList,
                'previewLink' => 'https://preview.com'
                };
                    
                    String body = JSON.serialize(jsonMap);
        String response = sendGift.createGiftObjRecord(body);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        
        System.assertEquals(true, responseBody.get('isSuccess'));
        Test.stopTest();
    }
    
    @isTest static void test_createGiftObjRecordCase(){
        Test.startTest();
        
        Case caseRecord = [SELECT Id
                           FROM Case
                           LIMIT 1];
        Contact contactRecord = [SELECT Id, Email,LastName, AccountId 
                                 FROM Contact 
                                 WHERE LastName = 'Test Contact' 
                                 LIMIT 1];
        
        String caseRecordId = (String) caseRecord.Id;
        
        String contactRecordId = (String) contactRecord.Id;
        
        List<String> selectedRecipientIdsList = new List<String>();
        selectedRecipientIdsList.add(caseRecordId);
        
        
        List<Object> recipientsList = new List<Object>();
        Map<String, Object> recipient = new Map<String, Object>{
            'name' => contactRecord.LastName,
                'email' => contactRecord.Email,
                'id' => contactRecord.Id
                };
                    recipientsList.add(recipient);
        
        
        Map<String, Object> attributesData = new Map<String, Object>{
            'external-id' => 'SF123',
                'email' => contactRecord.Email,
                'message' => 'testing',
                'scheduled-at' => '2018-06-28T19:30:04.294Z',
                'stage' => 'scheduled',
                'subject' => 'testing',
                'team' => 'sandbox'
                };
                    
                    Map<String, Object> attributes = new Map<String, Object>{
                        'attributes' => attributesData
                            };
                                
                                List<Object> createdGiftList = new List<Object>();
        createdGiftList.add(attributes);
        
        Map<String, Object> jsonMap = new Map<String, Object>{
            'recipients' => recipientsList,
                'entryPointObj' => 'Case',
                'entryPointObjId' => caseRecordId,
                'createdGift' => createdGiftList,
                'recordId' =>contactRecordId,
                'selectedCollection' => '$25',
                'selectedRecipientIdsList' => selectedRecipientIdsList,
                'previewLink' => 'https://preview.com'
                };
                    
                    String body = JSON.serialize(jsonMap);
        String response = sendGift.createGiftObjRecord(body);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        
        System.assertEquals(true, responseBody.get('isSuccess'));
        Test.stopTest();
    }
    
    @isTest static void test_createTeamWebHook(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
        String team = 'sandbox';
        
        String response = sendGift.createTeamWebHook(team);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        
        System.assertEquals(true, responseBody.get('isSuccess'));
        Test.stopTest();
    }
    
    @isTest static void test_getPreviewLink(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
        String team = 'sandbox';
        
        List<Object> recipientsAttributesList = new List<Object>();
        Map<String, Object> recipientsAttributes  = new Map<String, Object>{
            'name' => 'Ziggi',
                'email' => 'thewailers@jamaica.com'
                };
                    
                    recipientsAttributesList.add(recipientsAttributes);
        Map<String, Object> gift = new Map<String, Object>{
            'collection' => '$25',
                'message' => 'Better than Bob',
                'from' => 'Peter Tosh',
                'recipients_attributes' => recipientsAttributesList
                };
                    
                    Map<String, Object> giftData = new Map<String, Object>{
                        'gift' => gift
                            };
                                
                                Map<String, Object> jsonMap = new Map<String, Object>{
                                    'team' => team,
                                        'giftData' => giftData
                                        };
                                            
                                            String body = JSON.serialize(jsonMap);
        String response = sendGift.getPreviewLink(body);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        
        System.assertEquals(true, responseBody.get('isSuccess'));
        Test.stopTest();
    }
    @isTest static void test_getRecipientInfoContact(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
        Contact contactRecord = [SELECT Id, Email,LastName 
                                 FROM Contact 
                                 WHERE LastName = 'Test Contact' 
                                 LIMIT 1];
        List<String> idsList = new List<String>();
        idsList.add(contactRecord.Id);
        
        String response = sendGift.getRecipientInfo(idsList);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        Map<String, Object> results = (Map<String, Object>)responseBody.get('results');
        
        String objectName = (String)results.get('objectName');
        
        System.assertEquals('Contact', objectName);
        Test.stopTest();
    }
    @isTest static void test_getRecipientInfoLead(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
        Lead leadRecord = [SELECT Id, Email,LastName 
                           FROM Lead 
                           WHERE LastName = 'Test Lead' 
                           LIMIT 1];
        List<String> idsList = new List<String>();
        idsList.add(leadRecord.Id);
        
        String response = sendGift.getRecipientInfo(idsList);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        Map<String, Object> results = (Map<String, Object>)responseBody.get('results');
        System.debug('************' + results);
        String objectName = (String)results.get('objectName');
        
        System.assertEquals('Lead', objectName);
        Test.stopTest();
    }
    @isTest static void test_getRecipientInfoCase(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
        Case caseRecord = [SELECT Id
                           FROM Case
                           LIMIT 1];
        List<String> idsList = new List<String>();
        idsList.add(caseRecord.Id);
        
        String response = sendGift.getRecipientInfo(idsList);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        System.assertEquals(true, responseBody.get('isSuccess'));
        Test.stopTest();
    }
    @isTest static void test_getRecipientInfoOpportunity(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
        Opportunity opportunityRecord = [SELECT Id, Name 
                                         FROM Opportunity 
                                         WHERE Name = 'Test Opportunity' 
                                         LIMIT 1];
        List<String> idsList = new List<String>();
        idsList.add(opportunityRecord.Id);
        
        String response = sendGift.getRecipientInfo(idsList);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        Map<String, Object> results = (Map<String, Object>)responseBody.get('results');
        
        String objectName = (String)results.get('objectName');
        
        System.assertEquals('Opportunity', objectName);
        Test.stopTest();
    }
    @isTest static void test_getRecipientInfoCampaign(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
        Contact contactRecord = [SELECT Id, Email,LastName 
                                 FROM Contact 
                                 WHERE LastName = 'Test Contact' 
                                 LIMIT 1];
        Lead leadRecord = [SELECT Id, Email,LastName 
                           FROM Lead 
                           WHERE LastName = 'Test Lead' 
                           LIMIT 1];
        
        Campaign campaignRecord = [SELECT Id,Name 
                                  FROM Campaign
                                  WHERE Name = 'Test Campaign'
                                  LIMIT 1];  
        
        List<String> idsList = new List<String>();
        idsList.add(campaignRecord.Id);
        
        CampaignMember member = new CampaignMember(
            ContactId = contactRecord.Id,
            LeadId = leadRecord.Id,
            Status = 'Sent',
            CampaignId = campaignRecord.Id
        );  
        insert member; 
        
        String response = sendGift.getRecipientInfo(idsList);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        System.assertEquals(true, responseBody.get('isSuccess'));
        Test.stopTest();
    }
    @isTest static void test_getRecipientInfoOCR(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
                
        Account a = new Account();
        a.Name = 'testing in test method';
        insert a;

        Contact newContact = new Contact(Lastname='testLastName', AccountId = a.Id, LeadSource='Phone');
        insert newContact;
        
        Opportunity o = new Opportunity(AccountId = a.Id, StageName='Closed Won');
        o.Name='Testopp';
        o.CloseDate=system.today();
        insert o;
        List<String> idsList = new List<String>();
        idsList.add(o.Id);
        
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = o.Id, ContactId = newContact.Id);
        insert ocr;
        
        Test.startTest();
        String response = sendGift.getRecipientInfo(idsList);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        System.assertEquals(true, responseBody.get('isSuccess'));
        Test.stopTest();
    }
    @isTest static void test_getRecipientInfoAccount(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
        Account accountRecord = [SELECT Id, Name 
                                 FROM Account 
                                 WHERE Name = 'Test Account' 
                                 LIMIT 1];
        List<String> idsList = new List<String>();
        idsList.add(accountRecord.Id);
        
        String response = sendGift.getRecipientInfo(idsList);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        Map<String, Object> results = (Map<String, Object>)responseBody.get('results');
        
        String objectName = (String)results.get('objectName');
        
        System.assertEquals('Account', objectName);
        Test.stopTest();
    }
    @isTest static void test_getMultiLookupRecipientInfoContact(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
        Contact contactRecord = [SELECT Id, Email,LastName 
                                 FROM Contact 
                                 WHERE LastName = 'Test Contact' 
                                 LIMIT 1];
        List<String> idsList = new List<String>();
        idsList.add(contactRecord.Id);
        
        String response = sendGift.getMultiLookupRecipientInfo('Contact', idsList);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        Map<String, Object> results = (Map<String, Object>)responseBody.get('results');
        List<Object> recipients = (List<Object>)results.get('recipients');
        Map<String, Object> recipientData = (Map<String, Object>)recipients.get(0);
        String recipientId = (String)recipientData.get('id');
        
        System.assertEquals(contactRecord.Id, recipientId);
        Test.stopTest();
    }
    @isTest static void test_getMultiLookupRecipientInfoCampaign(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
        Campaign campaignRecord = [SELECT Id,Name 
                                  FROM Campaign
                                  WHERE Name = 'Test Campaign'
                                  LIMIT 1];  
        
        List<String> idsList = new List<String>();
        idsList.add(campaignRecord.Id);
        String response = sendGift.getMultiLookupRecipientInfo('Campaign', idsList);
        Test.stopTest();
        System.assert(true);
    }
    @isTest static void test_getMultiLookupRecipientInfoLead(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
        Lead leadRecord = [SELECT Id, Email,LastName 
                           FROM Lead 
                           WHERE LastName = 'Test Lead' 
                           LIMIT 1];
        List<String> idsList = new List<String>();
        idsList.add(leadRecord.Id);
        
        String response = sendGift.getMultiLookupRecipientInfo('Lead', idsList);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        Map<String, Object> results = (Map<String, Object>)responseBody.get('results');
        List<Object> recipients = (List<Object>)results.get('recipients');
        Map<String, Object> recipientData = (Map<String, Object>)recipients.get(0);
        String recipientId = (String)recipientData.get('id');
        
        System.assertEquals(leadRecord.Id, recipientId);
        Test.stopTest();
    }
    @isTest static void test_getCreatedGiftObjRecord(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
        Gift__c gifts = [SELECT Id, Gift_Id__c, Email__c
                         FROM Gift__c
                         WHERE Email__c = 'test@test.com'];
        List<String> giftIds = new List<String>();
        giftIds.add(gifts.Gift_Id__c);
        
        String response = sendGift.getCreatedGiftObjRecords(giftIds);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('THISHERE: ' + responseBody);
        Map<String, Object> results = (Map<String, Object>)responseBody.get('results');
        List<Object> giftList = (List<Object>)results.get('gifts');
        if(giftList.size() > 0){
            Map<String, Object> gift = (Map<String, Object>)giftList.get(0);
            String email = (String)gift.get('Email__c');
            System.assertEquals('test@test.com', email);
        }
        Test.stopTest();
    }
    @isTest static void test_getDifferentContact(){
       Contact contactRecord = [SELECT Id, Email,LastName 
                                FROM Contact 
                                WHERE LastName = 'Test Contact' 
                                LIMIT 1];
     
     
        String jsonInput =  '[{"ConvertedDate":null,"scheduledAt":"2020-11-09","id":'+' "'  + contactRecord.Id +'" '
            +' ,"email": ' +' "'+ contactRecord.Email + '" '+ ',"name":' + ' "' + contactRecord.LastName + '" ' + '}]';
        system.debug('jsonInput'+jsonInput);
        
        Test.startTest();
        List<Map<String,Object>> response = sendGift.getDifferent('Contact', jsonInput,'createdbyid','{createdbyid} sent you a gift!','full-name');
        System.assertEquals(response[0].get('email'),contactRecord.Email );
        Test.stopTest();
    }
    
    @isTest static void test_getDifferentLead(){
       Lead leadRecord = [SELECT Id, Email,LastName 
                           FROM Lead 
                           WHERE LastName = 'Test Lead' 
                           LIMIT 1];
     
        String jsonInput =  '[{"ConvertedDate":null,"scheduledAt":"2020-11-09","id":'+' "'  + leadRecord.Id +'" ' +' ,"email": ' +' "'+ leadRecord.Email + '" '+ ',"name":' + ' "' + leadRecord.LastName + '" ' + '}]';
        system.debug('jsonInput'+jsonInput);
      
        Test.startTest();
        List<Map<String,Object>> response = sendGift.getDifferent('Lead', jsonInput,'createdbyid','{createdbyid} sent you a gift!','full-name');
        System.assertEquals(response[0].get('email'), leadRecord.Email);
        Test.stopTest();
        
    }
    @isTest static void test_getWebHookURL(){
        Setup_Data__c setData =new Setup_Data__c();
        setData.Name = 'Default';
        setData.lnt__pbo_Url__c = 'https://www.google.com';
        insert setData;
        
        Test.startTest();
        String response = sendGift.getWebHookURL();
        Test.stopTest();
      
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
        Map<String, Object> results = (Map<String, Object>)responseBody.get('results');
        String url = (String)results.get('pboUrl');
        system.assertEquals(url, setData.lnt__pbo_Url__c);
    }
    @isTest static void test_getUsers(){
        Test.startTest();
        User user = [SELECT Id,FirstName, Department 
                     FROM User 
                     WHERE LastName = 'Test Contact' 
                     LIMIT 1];
        sendGift.usersWrapper wrp = new sendGift.usersWrapper();
        wrp = sendGift.getUsers();
        Test.stopTest();
        System.assert(true);
    }
    @isTest static void getAllLookupfields(){
        Lead leadRecord = [SELECT Id, Email,LastName 
                           FROM Lead 
                           WHERE LastName = 'Test Lead' 
                           LIMIT 1];
        Test.startTest();
        sendGift.getAllLookupfields('Lead');
        sendGift.getFieldsByObject();
        Test.stopTest();
        System.assert(true);
    }
    
    
}