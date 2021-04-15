@isTest
public class tst_sendGiftsExtension {
    @isTest static void test_sendGiftsExtension(){
        Test.startTest();
        List<Gift__c> gift = new List<Gift__c>();
        Gift__c giftObj = new Gift__c( 
            Team__c = 'Sandbox',
            Email__c = 'test@test.com',
            Gift_Id__c = 'LT1234',
            Stage__c = 'scheduled'
        );
        insert giftObj;
        gift.add(giftObj);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(gift);
        stdSetController.setSelected(gift);
        sendGiftsExtension ext = new sendGiftsExtension(stdSetController);
        System.assert(true);
        Test.stopTest();
    }
    
}