@isTest
public class tst_leadTriggerHelper {
    @testSetup static void testsetup(){

        Account accountRecord = new Account(
            Name = 'Test Account'
        );
        upsert accountRecord;

        Contact contactRecord = new Contact(
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

        Opportunity opportunityRecord = new Opportunity(
            Name = 'Test Opportunity',
            CloseDate = date.parse(date.today().format()),
            StageName = 'Prospecting'
        );
        upsert opportunityRecord;

        Gift__c gift = new Gift__c(
            Lead_Id__c = leadRecord.Id
        );
        insert gift;

        System.assert(true, true);
        
    }
     @isTest static void test_checkLeadConversion(){
        Test.startTest();

            Lead leadRecord = [SELECT Id
                               FROM Lead
                               WHERE LastName = 'Test Lead'
                               LIMIT 1];

            Account accountRecord = [SELECT Id, Name 
                                     FROM Account 
                                     WHERE Name = 'Test Account' 
                                     LIMIT 1];

            Contact contactRecord = [SELECT Id, Email,LastName 
                                     FROM Contact 
                                     WHERE LastName = 'Test Contact' 
                                     LIMIT 1];

            Opportunity opportunityRecord = [SELECT Id, Name 
                                     FROM Opportunity 
                                     WHERE Name = 'Test Opportunity' 
                                     LIMIT 1];

            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadRecord.Id);
            lc.setAccountId(accountRecord.Id);
            lc.setOpportunityId(opportunityRecord.Id);
            lc.setContactId(contactRecord.Id);

            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);

            Database.LeadConvertResult lcr = Database.convertLead(lc);

            Gift__c giftRecord = [SELECT Id, Account_Id__c
                                  FROM Gift__c
                                  WHERE Lead_Id__c =:leadRecord.Id];

            System.assert(lcr.isSuccess());
            System.assertEquals(giftRecord.Account_Id__c, accountRecord.Id);
        Test.stopTest();
    }
        
}