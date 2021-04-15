/* --------------------------------------------------
Strike by Appiphony

Version: 0.9.0 
Website: http://www.lightningstrike.io
GitHub: https://github.com/appiphony/Strike-Components
License: BSD 3-Clause License
-------------------------------------------------- */
@isTest
private class test_strike_lookupController {
    
    @isTest static void test_getData() {
        Contact c = new Contact(LastName='Test Contact', Email='test@test.com');
        insert c;
        
        String jsonString = '{"searchField":"Name", "object": "Contact", "filter": "Name = \'Test Contact\'", "order": "Name", "limit": "5", "searchTerm": "Test" , "objectCampaign": ""}';
        String wrongJsonString = 'oops';
        
        Test.startTest();
        String responseString = strike_lookupController.getRecords(jsonString, true);
        
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        List<Object> data =(List<Object>)results.get('data');
        
        System.assertEquals(1, data.size());
        
        Map<String, Object> record = (Map<String, Object>)data.get(0);
        
        System.assertEquals(c.Id, record.get('value'));
        
        responseString = strike_lookupController.getRecords(wrongJsonString, true);
        Test.stopTest();
        
        response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        results = (Map<String, Object>)response.get('results');
        System.assertEquals(false, response.get('isSuccess'));
    }
    
    @isTest static void test_getData_subtitleField() {
        Contact c = new Contact(LastName='Test Contact', Email='test@test.com');
        insert c;
        
        String jsonString = '{"ids":"","searchField":"Name", "subtitleField": "Name", "object": "Contact", "filter": "Name = \'Test Contact\'", "searchTerm": "Test", "objectCampaign": ""}';
        
        Test.startTest();
        String responseString = strike_lookupController.getRecords(jsonString, true);
        Test.stopTest();
        
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        List<Object> data =(List<Object>)results.get('data');
        
        System.assertEquals(1, data.size());
        
        Map<String, Object> record = (Map<String, Object>)data.get(0);
        
        System.assertEquals(c.Id, record.get('value'));
    }
   
    @isTest static void test_getData_reference() {
        Account a = new Account(Name='Test Account');
        insert a;
        
        Contact c = new Contact(
            LastName='Contact',
            FirstName='Test',
            Email = 'test@test.com',
            AccountId = a.Id);
        insert c;
        
        String jsonString = '{"searchField":"FirstName", "subtitleField": "Account.Name", "object": "Contact", "filter": "Name = \'Test Contact\'", "searchTerm": "Test", "objectCampaign": ""}';
        
        Test.startTest();
        String responseString = strike_lookupController.getRecords(jsonString, true);
        Test.stopTest();
        
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        List<Object> data =(List<Object>)results.get('data'); 
        
        System.assertEquals(1, data.size());
        
        Map<String, Object> record = (Map<String, Object>)data.get(0);
        
        System.assertEquals(c.Id, record.get('value'));
    }
    
    @isTest static void test_getData_Lead() {
        Lead l = new Lead(LastName='Test Lead',Company= 'Test Company',Street = 'Street', City = 'City', State='State', PostalCode = '1234', Country = 'Country', Email='test@test.com');
        insert l;
        String jsonString = '{"searchField":"Name,street,city,state,Email", "object": "Lead", "filter": "Name = \'Test Lead\'", "order": "Name", "limit": "5", "searchTerm": "Test" , "objectCampaign": ""}';
        String wrongJsonString = 'oops';
        
        Test.startTest();
        String responseString = strike_lookupController.getRecords(jsonString, true);
        
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        List<Object> data =(List<Object>)results.get('data');
        
        System.assertEquals(1, data.size());
        
        Map<String, Object> record = (Map<String, Object>)data.get(0);
        
        System.assertEquals(l.Id, record.get('value'));
        
        responseString = strike_lookupController.getRecords(wrongJsonString, false);
        Test.stopTest();
        
        response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        results = (Map<String, Object>)response.get('results');
        System.assertEquals(false, response.get('isSuccess'));
    }
    
    @isTest static void test_getData_Campaign() {
        Campaign c = new Campaign(Name='Test Campaign',Status ='Planned');
        insert c;
        Lead l = new Lead(LastName='Test Lead',Company= 'Test Company',Street = 'Street', City = 'City', State='State', PostalCode = '1234', Country = 'Country', Email='test@test.com');
        insert l;
        CampaignMember campMem = new CampaignMember(leadId=l.Id,CampaignId=c.Id);
        insert CampMem;
        
        String jsonString = '{"ids":"","searchField":"Id,Name,leadId,Lead.Id", "object": "Campaign", "filter": "Name = \'Test Lead\'", "order": "Name", "limit": "15", "searchTerm": "Test" , "objectCampaign": "CampaignMember"}';
        String wrongJsonString = 'oops';
        
        Test.startTest();
        String responseString = strike_lookupController.getRecords(jsonString, false);
        
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        List<Object> data =(List<Object>)results.get('data');
        
        System.assertEquals(1, data.size());
        
        Map<String, Object> record = (Map<String, Object>)data.get(0);
        
        System.assertEquals(CampMem.Id, record.get('value'));
        
        responseString = strike_lookupController.getRecords(wrongJsonString, true);
        Test.stopTest();
        
        response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        results = (Map<String, Object>)response.get('results');
        System.assertEquals(false, response.get('isSuccess'));
    }
    
    @isTest static void test_getData_Campaign2() {
        Campaign c = new Campaign(Name='Test Campaign',Status ='Planned');
        insert c;
        Lead l = new Lead(LastName='Test Lead',Company= 'Test Company',Street = 'Street', City = 'City', State='State', PostalCode = '1234', Country = 'Country', Email='test@test.com');
        insert l;
        Lead l2 = new Lead(LastName='Test Lead2',Company= 'Test Company',Street = 'Street', City = 'City', State='State', PostalCode = '1234', Country = 'Country', Email='test2@test.com');
        insert l2;

        CampaignMember campMem = new CampaignMember(leadId=l.Id,CampaignId=c.Id);
        insert campMem;
        CampaignMember campMem2 = new CampaignMember(leadId=l2.Id,CampaignId=c.Id);
        insert campMem2;
        List<Id> idsList = new List<Id>{campMem.Id};
            
        String jsonString = '{"ids":"\''+campMem.Id+'\'","searchField":"Id,Name,leadId,Lead.Id", "object": "Campaign", "filter": "Name = \'Test Lead\'", "order": "Name", "limit": "15", "searchTerm": "Test" , "objectCampaign": "CampaignMember","results": {"Data": [{"Name": "test","Id": "","LeadId": ""}]}}';
        String wrongJsonString = 'oops';
        
        Test.startTest();
        String responseString = strike_lookupController.getRecords(jsonString, true);
        Test.stopTest();
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        List<Object> data =(List<Object>)results.get('data'); 
        
        System.assertEquals(1, data.size());
        
    }    
    @isTest static void test_getData_setEmailOptContact(){
        Contact conObj = new Contact();
        conObj.firstName = 'Test Contact';
        conObj.LastName ='Test';
        conobj.Email = 'test@test.com';
        conObj.HasOptedOutOfEmail = false;
        insert conObj;
        String jsonInput =  '[{"value":'+' "'  + conObj.Id +'" ' +' ,"subtitle": ' +' "'+ conObj.Email + '" '+ ',"title":' + ' "' + conObj.firstName + '" ' + '}]';  
        
        List<Map<String, Object>> responseString = strike_lookupController.setEmailOpt(jsonInput, true);
        System.assertEquals(responseString[0].get('title') , [Select Id,Name From Contact Where Id = :conObj.Id].Name);
    }
    
    @isTest static void test_getData_setEmailOptLead(){
        Lead lObj = new Lead();
        lObj.firstName = 'Test Lead';
        lObj.LastName ='Test';
        lObj.Email = 'test@test.com';
        lObj.Company ='testComp';
        lObj.HasOptedOutOfEmail = false ;
        insert lObj;
        String jsonInput =  '[{"value":'+' "'  + lObj.Id +'" ' +' ,"subtitle": ' +' "'+ lObj.Email + '" '+ ',"title":' + ' "' + lObj.firstName + '" ' + '}]';  
        
        List<Map<String, Object>> responseString = strike_lookupController.setEmailOpt(jsonInput, true);
        System.assertEquals(responseString[0].get('title') , [Select Id,Name From Lead Where Id = :lObj.Id].Name);
    }

}
/* --------------------------------------------------
Copyright 2017 Appiphony, LLC

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the 
following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following 
disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following 
disclaimer in the documentation and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote 
products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------- */