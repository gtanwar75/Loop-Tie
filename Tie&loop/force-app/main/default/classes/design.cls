public class design {
    public String namespace {
        get { return constants.NAMESPACE; }
    }

    public static String getUserApiToken(String userId){     
        LoopAndTieToken__c customSetting = LoopAndTieToken__c.getInstance(userId);
        String apiToken = customSetting.Access_Token__c;
        return apiToken;
    }

    @AuraEnabled
    public static String getUserDesigns(String team, String userId){
        responseData rd = new responseData();
        try{
            String accessToken = '';
            if(userId == null){
                accessToken = getUserAPIToken(UserInfo.getUserId());
            }else{
                accessToken = getUserAPIToken(userId);
            }

            Map<String, String> headers = new Map<String, String>();
            headers.put('Authorization', 'Bearer ' + accessToken);
            headers.put('Content-Type', 'application/json');
            String endpoint = constants.BASE_LOOPTIE_API + '/teams/' + team + '/designs';
            HttpResponse res = utilities.makeCallout(endpoint, 'GET', null, headers);
            Map<String, Object> returnedData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

            if(res.getStatusCode() == 200) {
                rd.results.put('body', returnedData);
            }else{
                System.debug('**********ERROR:' + returnedData);
                List<Object> errorList = (List<Object>)returnedData.get('errors');
                Map<String, Object> errorMap = (Map<String, Object>)errorList.get(0);
                rd.addError((String)errorMap.get('detail'));
            }
        }catch (Exception e){
            rd.addError(e.getMessage());
        }
        return rd.getJsonString();
    }

    @AuraEnabled
    public static String getUserLogos(String team, String userId){
        responseData rd = new responseData();
        try{
            String accessToken = '';
            if(userId == null){
                accessToken = getUserAPIToken(UserInfo.getUserId());
            }else{
                accessToken = getUserAPIToken(userId);
            }
            Map<String, String> headers = new Map<String, String>();
            headers.put('Authorization', 'Bearer ' + accessToken);
            headers.put('Content-Type', 'application/json');
            String endpoint = constants.BASE_LOOPTIE_API + '/teams/' + team + '/logos';
            HttpResponse res = utilities.makeCallout(endpoint, 'GET', null, headers);
            Map<String, Object> returnedData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

            if(res.getStatusCode() == 200) {
                rd.results.put('body', returnedData);
            }else{
                System.debug('**********ERROR:' + returnedData);
                List<Object> errorList = (List<Object>)returnedData.get('errors');
                Map<String, Object> errorMap = (Map<String, Object>)errorList.get(0);
                rd.addError((String)errorMap.get('detail'));
            }
        }catch (Exception e){
            rd.addError(e.getMessage());
        }
        return rd.getJsonString();
    }
}