@isTest
public class tst_hubhook {
    @testSetup static void testsetup(){
        Gift__c gift = new Gift__c( 
            Team__c = 'Sandbox',
            Email__c = 'test@test.com',
            Gift_Id__c = 'LT1234',
            Stage__c = 'scheduled'
        );
        insert gift;
    }
    @isTest static void test_doPost(){
        Test.startTest();
         Gift__c gift = [SELECT Id, Team__c, Email__c, Gift_Id__c, Stage__c from Gift__c Limit 1];
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/hubhook/';
        
        
        Map<String,String> selectedProductDataAttr = new Map<String,String>{
            'name' => 'Ringtool',
            'image-url' =>'https://d17ndm7sr3bpx3.cloudfront.net/uploads/products/1632/1542298175/images/1/standard.jpg?1542298175'
        };
        
        Map<String,Object> selectedProductData = new Map<String,Object>{
            'attributes' => selectedProductDataAttr
        };
        Map<String,Object> selectedProduct = new Map<String,Object>{
            'data' => selectedProductData
            
        };
        Map<String,Object> includedAttributes = new Map<String,Object>{
            'selected-product' => selectedProduct,
            'variant' => null
        };
        
        Map<String,Object> listMap = new Map<String,Object>{
            'id' => gift.Gift_Id__c ,
            'type' =>'gifts'  ,
            'attributes' => includedAttributes
               
        }; 
            
      
        List<Object> includedList = new List<Object>(); 
        includedList.add(listMap);
        
        Map<String, Object> attributes = new Map<String, Object>{
                'created-at' => '2018-06-28T05:05:10.000Z',
                'event' => 'redeemed',
                'message' => 'test'       
        };
           
           Map<String, Object> data = new Map<String, Object>{
            'attributes' => attributes,
            'id' => gift.Gift_Id__c
        };
           //main Map containing All Data 
        Map<String, Object> dataMap = new Map<String, Object> {
            'data' => data,
            'included' => includedList
        };

       req.requestBody = blob.valueOf(JSON.serialize(dataMap));
       req.httpMethod = 'POST';  
       RestContext.request = req;
       RestContext.response = res;
        hubhook.doPost();

        Test.stopTest();
        System.assert(true, true);
    }
    @isTest static void test_doPost1(){
        Test.startTest();
    //    String variant = null;
         Gift__c gift = [SELECT Id, Team__c, Email__c, Gift_Id__c, Stage__c from Gift__c Limit 1];
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/hubhook/';
        
        
         Map<String,String> selectedProductDataAttr = new Map<String,String>{
            'name' => 'Ringtool',
            'image-url' =>'https://d17ndm7sr3bpx3.cloudfront.net/uploads/products/1632/1542298175/images/1/standard.jpg?1542298175'
        };
        
        Map<String,Object> selectedProductData = new Map<String,Object>{
            'attributes' => selectedProductDataAttr
        };
        Map<String,Object> selectedProduct = new Map<String,Object>{
            'data' => selectedProductData
            
        };
            
       Map<String,Object> variantMap = new Map<String,Object>{
                'data' => selectedProductData
            };
            
        Map<String,Object> includedAttributes = new Map<String,Object>{
            'selected-product' => selectedProduct,
            'variant' => variantMap //here I have to put a MAP
        };
        
        Map<String,Object> listMap = new Map<String,Object>{
            'id' => gift.Gift_Id__c ,
            'type' =>'gifts'  ,
            'attributes' => includedAttributes
               
        }; 
        List<Object> includedList = new List<Object>(); 
        includedList.add(listMap);
        
        Map<String, Object> attributes = new Map<String, Object>{
                'created-at' => '2018-06-28T05:05:10.000Z',
                'event' => 'redeemed',
                'message' => 'test'       
        };
           
           Map<String, Object> data = new Map<String, Object>{
            'attributes' => attributes,
            'id' => gift.Gift_Id__c
        };
           //main Map containing All Data 
        Map<String, Object> dataMap = new Map<String, Object> {
            'data' => data,
            'included' => includedList
        };

       req.requestBody = blob.valueOf(JSON.serialize(dataMap));
       req.httpMethod = 'POST';  
       RestContext.request = req;
       RestContext.response = res;
       hubhook.doPost();

        Test.stopTest();
        System.assert(true, true);
    }
      @isTest static void test_doPost2(){
        Test.startTest();
         Gift__c gift = [SELECT Id, Team__c, Email__c, Gift_Id__c, Stage__c from Gift__c Limit 1];
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/hubhook/';
        
        List<Object> includedList = new List<Object>(); 
        
        Map<String, Object> attributes = new Map<String, Object>{
                'created-at' => '2018-06-28T05:05:10.000Z',
                'event' => 'sent',
                'message' => 'test'       
        };
           
           Map<String, Object> data = new Map<String, Object>{
            'attributes' => attributes,
            'id' => gift.Gift_Id__c
        };
           //main Map containing All Data 
        Map<String, Object> dataMap = new Map<String, Object> {
            'data' => data,
            'included' => includedList
        };

       req.requestBody = blob.valueOf(JSON.serialize(dataMap));
       req.httpMethod = 'POST';  
       RestContext.request = req;
       RestContext.response = res;
        hubhook.doPost();

        Test.stopTest();
        System.assert(true, true);
    }
          @isTest static void test_doPost3(){
        Test.startTest();
         Gift__c gift = [SELECT Id, Team__c, Email__c, Gift_Id__c, Stage__c from Gift__c Limit 1];
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/hubhook/';
        
        List<Object> includedList = new List<Object>(); 
        
        Map<String, Object> attributes = new Map<String, Object>{
                'created-at' => '2018-06-28T05:05:10.000Z',
                'event' => 'thanked',
                'message' => 'test'       
        };
           
           Map<String, Object> data = new Map<String, Object>{
            'attributes' => attributes,
            'id' => gift.Gift_Id__c
        };
           //main Map containing All Data 
        Map<String, Object> dataMap = new Map<String, Object> {
            'data' => data,
            'included' => includedList
        };

       req.requestBody = blob.valueOf(JSON.serialize(dataMap));
       req.httpMethod = 'POST';  
       RestContext.request = req;
       RestContext.response = res;
        hubhook.doPost();

        Test.stopTest();
        System.assert(true, true);
    }
 
}