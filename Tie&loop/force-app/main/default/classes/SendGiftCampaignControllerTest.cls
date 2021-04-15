@isTest
public class SendGiftCampaignControllerTest {
    
    @isTest
    private static void sendGiftCampaignTestMethod(){
        
        List<sendGiftCampaignController.giftsToUser> gtuList = new List<sendGiftCampaignController.giftsToUser>();
        
        List<sendGiftCampaignController.responseClass> actutalGtuList = new List<sendGiftCampaignController.responseClass>();
        
        //List of contacts
        List<Contact> conList = new List<Contact>(); 
        
        Contact con = new Contact(FirstName = 'Test', LastName = 'Test1');
        conList.add(con);        
        Contact con1 = new Contact(FirstName = 'Testone', LastName = 'Testtwo');
        conList.add(con1);
        
        insert conList;
        
        Lead li = new Lead(FirstName = 'Kumar', LastName = 'prashant', Company = 'Dazeworks', Status = 'Open - Not Contacted');
        insert li;
        
        Campaign camp = new Campaign(Name = 'DM Campaign to Top Customers');
        insert camp;
        
        CampaignMember camMember = new CampaignMember(CampaignId = camp.Id, ContactId = con.Id, LeadId = li.Id);
        insert camMember;
        
        //List of gifts
        List<lnt__Gift__c> giftList = new List<lnt__Gift__c>();
        
        lnt__Gift__c gifts = new lnt__Gift__c(lnt__Email__c = 'prashant.kumar@dazeworks.com', lnt__Stage__c = 'scheduled', lnt__Contact_Id__c = con.id,
                                              lnt__Lead_Id__c = li.Id);        
        lnt__Gift__c gifts1 = new lnt__Gift__c(lnt__Email__c = 'prashant.kumar@dazeworks.com', lnt__Stage__c = 'opened', lnt__Contact_Id__c = con1.id,
                                               lnt__Lead_Id__c = li.Id);        
        lnt__Gift__c gifts2 = new lnt__Gift__c(lnt__Email__c = 'prashant.kumar@dazeworks.com', lnt__Stage__c = 'shipped', lnt__Contact_Id__c = con.id,
                                               lnt__Lead_Id__c = li.Id);        
        lnt__Gift__c gifts3 = new lnt__Gift__c(lnt__Email__c = 'prashant.kumar@dazeworks.com', lnt__Contact_Id__c = con.id, lnt__Lead_Id__c = li.Id);
        
        giftList.add(gifts);
        giftList.add(gifts1);
        giftList.add(gifts2);
        giftList.add(gifts3);
        insert giftList;
        
        List<lnt__Gift__c> giftss = [Select Id From lnt__Gift__c];
        System.assertEquals(4, giftss.size());
        
        sendGiftCampaignController.giftsToUser gtu = new sendGiftCampaignController.giftsToUser();
        gtu.id = conList[0].id;
        gtu.name =	conList[0].FirstName +' ' + conList[0].LastName;
        gtu.email =	gifts.lnt__Email__c;
        gtu.memberType = 'Contact';
        gtu.giftStatus = gifts.lnt__Stage__c;
        gtuList.add(gtu); 
        
        
        Test.startTest();
        
        sendGiftCampaignController.responseClass rc = sendGiftCampaignController.giftsToCampaignMembers(camp.id, 'scheduled', 'Contact');
        //System.assertEquals(gtuList, actutalGtuList);
        sendGiftCampaignController.giftsToCampaignMembers(camp.id, 'scheduled', 'Lead');
        sendGiftCampaignController.giftsToCampaignMembers(camp.id, 'scheduled', 'Both');
        sendGiftCampaignController.giftsToCampaignMembers(camp.id, 'none', 'Contact');
        sendGiftCampaignController.giftsToCampaignMembers(camp.id, 'none', 'Lead');
        sendGiftCampaignController.giftsToCampaignMembers(camp.id, 'none', 'Both');
        sendGiftCampaignController.giftsToCampaignMembers(camp.id, gifts3.lnt__Stage__c, null);
        
        Test.stopTest();
        
    }
    
}