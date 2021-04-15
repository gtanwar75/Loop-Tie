public with sharing class completeOauth2 {

    public static String redirectUri = 'https://loopandtie.secure.force.com/oauth';

    public String getOrigin() {
        return constants.SALESFORCE_INSTANCE_URI;
    }

    @AuraEnabled
    public static String getToken(String code){
        responseData rd = new responseData();

        try{
            checkAccess(customObjectChecks, true);
            String connectionEndpoint = '';

            if(constants.IS_SANDBOX){
                connectionEndpoint = 'https://test.salesforce.com/services/oauth2/token';

            }else{
                connectionEndpoint = 'https://login.salesforce.com/services/oauth2/token';
            }

            String body =
                'grant_type=authorization_code'+
                '&client_id=' + constants.PBO_ORG_CLIENT_ID +
                '&client_secret=' + constants.PBO_ORG_CLIENT_SECRET +
                '&code=' + code+
                '&redirect_uri=' + completeOauth2.redirectUri;

            HttpResponse res = utilities.makeCallout(connectionEndpoint, 'POST', body, null);
            Map<String, Object> returnedData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            system.debug('returnedData token>>'+JSON.serialize(returnedData.get('refresh_token')));
            if(res.getStatusCode() == 200) {
                //save down retreived token to user custom settings
                Map<String, Object> webHookRes = hubUtilities.createWebhook((String)returnedData.get('refresh_token'));
                system.debug('webHookRes >>'+webHookRes);
                //save pbo url to Setup_Data__c object pbo_Url__c field
                Setup_Data__c setupData = new Setup_Data__c();
                List<Setup_Data__c> setupDataList = [SELECT Id, Name
                                            FROM Setup_Data__c
                                            WHERE Name = 'Default'];
                if(setupDataList.size() > 0){
                    setupData = setupDataList[0];
                }
                setupData.pbo_Url__c = (String)webHookRes.get('url');
                setupData.Name = 'Default';
                upsert setupData;

            }else{
                //handle error message here
                System.debug('**********ERROR:' + returnedData);
                rd.addError(JSON.serialize(returnedData));
            }

        }catch(Exception e){
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static String getAuthURL() {
        responseData response = new responseData();
        String oauthEndpoint = '';

        try {
            checkAccess(customObjectChecks, true);

            if(constants.IS_SANDBOX){
                oauthEndpoint = 'https://test.salesforce.com/services/oauth2/authorize';
            }else{
                oauthEndpoint = 'https://login.salesforce.com/services/oauth2/authorize';
            }
            String oauthURL = oauthEndpoint +
                '?client_id=' + constants.PBO_ORG_CLIENT_ID +
                '&client_secret=' + constants.PBO_ORG_CLIENT_SECRET +
                '&response_type=code'+
                '&redirect_uri=' + completeOauth2.redirectUri;

            response.put('oauthURL', oauthURL);

        } catch (Exception e) {
            response.addError(e.getMessage());
        }
        return response.getJsonString();
    }

    private static Map<String, Map<String, Set<String>>> customObjectChecks = new Map<String, Map<String, Set<String>>> {
        'Setup_Data__c' => new Map<String, Set<String>> {
            'Read' => new Set<String> {
                'Id', 'pbo_Url__c', 'Name'
            },
            'Create' => new Set<String> {
               'pbo_Url__c', 'Name'
            },
            'Update' => new Set<String> {
                'pbo_Url__c', 'Name'
            }
        }
    };

    private static void checkAccess(Map<String, Map<String, Set<String>>> accessMapByObjectName, Boolean appendNamespace){
        dmlManager.checkAccess(accessMapByObjectName, appendNamespace);
    }
}