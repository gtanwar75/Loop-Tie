@isTest
public class tst_completeOauth2 {
    @isTest
    public static void testGetOrigin() {
        Test.startTest();
        completeOauth2 con = new completeOauth2();
        String origin = con.getOrigin();
        Test.stopTest();

        System.assertEquals(constants.SALESFORCE_INSTANCE_URI, origin);
    }

    @isTest static void test_getAuthURL(){
        Test.setMock(HttpCalloutMock.class, new tst_mockCalloutGenerator());
        Test.startTest();
            String response = completeOauth2.getAuthURL();
            Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
            System.debug('THISHERE: ' + responseBody);

            System.assertEquals(true, responseBody.get('isSuccess'));
        Test.stopTest();
    }
    @isTest
    public static void testSendAuthPayload() {
        Test.setMock(HttpCalloutMock.class, new inboundConnectorStepMock());

        Test.startTest();
        String response = completeOauth2.getToken('testcode');
        Test.stopTest();

        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.assert((Boolean)responseMap.get('isSuccess'), responseMap.get('error'));
    }

    private class inboundConnectorStepMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();

            res.setBody(JSON.serialize(new Map<String, Object> {
                'refresh_token' => 'testRefreshToken'
            }));
            res.setStatusCode(200);

            return res;
        }
    }
}