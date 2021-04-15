public class customizeMessage {
    public String namespace {
        get { return constants.NAMESPACE; }
    }

    public static String getUserApiToken(String userId){     
        LoopAndTieToken__c customSetting = LoopAndTieToken__c.getInstance(userId);
        String apiToken = customSetting.Access_Token__c;
        system.debug('apiToken >>'+apiToken);
        return apiToken;
    }

    @AuraEnabled
    public static String getUserMessages(String team, String userId){
        
        responseData rd = new responseData();
        try{
            String accessToken = '';
            if(userId == null){
                accessToken = getUserAPIToken(UserInfo.getUserId());
            }else{
                accessToken = getUserAPIToken(userId);
            }
            system.debug('inApex '+team + 'userId '+ userId );
            Map<String, String> headers = new Map<String, String>();
            headers.put('Authorization', 'Bearer ' + accessToken);
            headers.put('Content-Type', 'application/json');
            String endpoint = constants.BASE_LOOPTIE_API + '/teams/' + team + '/messages';
            HttpResponse res = utilities.makeCallout(endpoint, 'GET', null, headers);
            Map<String, Object> returnedData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

            if(res.getStatusCode() == 200) {
                system.debug('success'+returnedData);
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
    public static wrapUsers fetchUsersLookUp(String searchKeyWord) {
        wrapUsers users = new wrapUsers();
        try{
            String searchKey = '%'+ searchKeyWord + '%';
            List < sObject > returnList = new List < sObject > ();
            if(Schema.sObjectType.User.isAccessible()){
                String sQuery =  'SELECT id,FirstName, Name FROM User'  + ' WHERE Name LIKE: searchKey AND isActive = true';
                List < sObject > lstOfRecords = Database.query(sQuery);
                users.userList = lstOfRecords;
            }
            
        }catch(Exception e){
            e.getMessage();
        }
        system.debug('users >>'+users);
        return users;
    }
  
    public class wrapUsers{
        @AuraEnabled public  List<User> userList{get;set;}
    }
   

}