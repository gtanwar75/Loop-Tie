@isTest
global class tst_mockCalloutGenerator implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();

        String apiBaseUrl = constants.BASE_LOOPTIE_API;
        String endpoint = req.getEndpoint();

        System.debug('ENDPOINT: ' + req.getEndpoint());
        System.debug('BUILT ENDPOINT: ' + apiBaseUrl );

        Organization orgInfo = [SELECT Id, InstanceName, IsSandbox FROM Organization LIMIT 1];

        if(endpoint == apiBaseUrl + '/teams/sandbox/gifts/LT1234'){
            res = cancelGiftById(req);
        }else if(endpoint == apiBaseUrl + '/teams'){
            res = getUserTeams(req);
        }else if(endpoint == apiBaseUrl + '/teams/sandbox/collections'){
            res = getTeamCollections(req);
        }else if(endpoint == apiBaseUrl + '/teams/sandbox/hooks'){
            res = getTeamWebHook(req);
        }else if(endpoint == apiBaseUrl + '/teams/sandbox/bulk/gifts'){
            res = createGift(req);
        }else if(endpoint == apiBaseUrl + '/teams/sandbox/hooks'){
            res = createTeamWebHook(req);
        }else if(endpoint == apiBaseUrl + '/teams/sandbox/previews'){
            res = getPreviewLink(req);
        }else if(endpoint == 'https://www.loopandtie.com/oauth2/token') {
            res = getToken(req);
        }else if(endpoint == 'https://loopandtie.secure.force.com/services/apexrest/callback/create'){
             res = createWebhook(req);
        }else if(endpoint == 'https://'+ orgInfo.InstanceName+'.salesforce.com/services/apexrest/hubhook'){
            res = doPost(req);
        }else if(endpoint == apiBaseUrl + '/teams/sandbox/messages'){
            res = getUserMessages(req);
        }else if(endpoint == apiBaseUrl + '/teams/sandbox/designs'){
            res = getUserDesigns(req);
        }else if(endpoint == apiBaseUrl + '/teams/sandbox/logos'){
            res = getUserLogos(req);
        }

        System.assert(true, true);
        return res;
    }

    global HttpResponse cancelGiftById(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        Map<String, Object> attributes = new Map<String, Object>{
            'stage' => 'canceled'
        };
        
        Map<String, Object> data = new Map<String, Object> {
            'attributes' => attributes
        };

        Map<String, Object> bodyMap = new Map<String, Object>();
        bodyMap.put('data', data);

        res.setBody(JSON.serialize(bodyMap));
        return res;
    }

    global HttpResponse getUserTeams(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        Map<String, Object> team = new Map<String, Object>{
           'id' => 'loop-tie',
           'type' => 'teams'
        };

        List<Object> teamList = new List<Object>();
        teamList.add(team);
        
        Map<String, Object> data = new Map<String, Object> {
            'data' => teamList
        };

        Map<String, Object> bodyMap = new Map<String, Object>();
        bodyMap.put('data', data);

        res.setBody(JSON.serialize(bodyMap));
        return res;
    }

    global HttpResponse getTeamCollections(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        Map<String, Object> collection = new Map<String, Object>{
           'id' => '4',
           'type' => 'collections'
        };

        List<Object> colectionList = new List<Object>();
        colectionList.add(collection);
        
        Map<String, Object> data = new Map<String, Object> {
            'data' => colectionList
        };

        Map<String, Object> bodyMap = new Map<String, Object>();
        bodyMap.put('data', data);

        res.setBody(JSON.serialize(bodyMap));
        return res;
    }

    global HttpResponse getTeamWebHook(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        Map<String, Object> webhooks = new Map<String, Object>{
           'id' => 'sandbox',
           'type' => 'webhooks'
        };

        
        Map<String, Object> data = new Map<String, Object> {
            'data' => webhooks
        };

        Map<String, Object> bodyMap = new Map<String, Object>();
        bodyMap.put('data', data);

        res.setBody(JSON.serialize(bodyMap));
        return res;
    }

    global HttpResponse createGift(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        Map<String, Object> gift = new Map<String, Object>{
           'id' => 'SF123',
           'type' => 'gifts'
        };

        List<Object> giftList = new List<Object>();
        giftList.add(gift);
        
        Map<String, Object> data = new Map<String, Object> {
            'data' => giftList
        };

        Map<String, Object> bodyMap = new Map<String, Object>();
        bodyMap.put('data', data);

        res.setBody(JSON.serialize(bodyMap));
        return res;
    }

    global HttpResponse createTeamWebHook(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        Map<String, Object> webhooks = new Map<String, Object>{
           'id' => 'sandbox',
           'type' => 'webhooks'
        };

        
        Map<String, Object> data = new Map<String, Object> {
            'data' => webhooks
        };

        Map<String, Object> bodyMap = new Map<String, Object>();
        bodyMap.put('data', data);

        res.setBody(JSON.serialize(bodyMap));
        return res;
    }

    global HttpResponse getPreviewLink(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        Map<String, Object> preview = new Map<String, Object>{
           'id' => '1234',
           'type' => 'preview'
        };
        List<Object> previewList = new List<Object>();
        previewList.add(preview);

        
        Map<String, Object> data = new Map<String, Object> {
            'data' => previewList
        };

        Map<String, Object> bodyMap = new Map<String, Object>();
        bodyMap.put('data', data);

        res.setBody(JSON.serialize(bodyMap));
        return res;
    }
    global HttpResponse getToken(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        Map<String, String> bodyMap = new Map<String, String>();
        bodyMap.put('access_token', '123456789');

        res.setBody(JSON.serialize(bodyMap));
        return res;
    }
    global HttpResponse createWebhook(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
    }
    global HttpResponse doPost(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
    }

    global HttpResponse getUserMessages(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        Map<String, Object> message = new Map<String, Object>{
           'id' => '0',
           'type' => 'message'
        };

        List<Object> messageList = new List<Object>();
        messageList.add(message);
        
        Map<String, Object> data = new Map<String, Object> {
            'data' => messageList
        };

        Map<String, Object> bodyMap = new Map<String, Object>();
        bodyMap.put('data', data);

        res.setBody(JSON.serialize(bodyMap));
        return res;
    }
    global HttpResponse getUserDesigns(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        Map<String, Object> design = new Map<String, Object>{
           'id' => '0',
           'type' => 'designs'
        };

        List<Object> designList = new List<Object>();
        designList.add(design);
        
        Map<String, Object> data = new Map<String, Object> {
            'data' => designList
        };

        Map<String, Object> bodyMap = new Map<String, Object>();
        bodyMap.put('data', data);

        res.setBody(JSON.serialize(bodyMap));
        return res;
    }
    global HttpResponse getUserLogos(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        Map<String, Object> logo = new Map<String, Object>{
           'id' => '0',
           'type' => 'logos'
        };

        List<Object> logoList = new List<Object>();
        logoList.add(logo);
        
        Map<String, Object> data = new Map<String, Object> {
            'data' => logoList
        };

        Map<String, Object> bodyMap = new Map<String, Object>();
        bodyMap.put('data', data);

        res.setBody(JSON.serialize(bodyMap));
        return res;
    }
}