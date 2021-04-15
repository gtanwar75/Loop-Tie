public class hubUtilities {
    private static Hub_Key__mdt hubKey = [SELECT URL__c
                                          FROM Hub_Key__mdt LIMIT 1];

    private static Organization orgInfo = [SELECT Id, InstanceName, IsSandbox FROM Organization LIMIT 1];

    public static Map<String, Object> createWebhook(String refreshToken) {
        HttpRequest req = new HttpRequest();
        Map<String, Object> responseMap = new Map<String, Object>();
        system.debug('Create Webhook Call');
        //try {
            //checkAccess(checkAccessForOrganization, true);
            checkAccess(customObjectChecks, true);
            req.setEndpoint(hubKey.URL__c);
            req.setMethod('POST');
            req.setHeader('Content-Type','application/json');
            
            req.setBody(JSON.serialize(new Map<String, Object> {
                'instance' => orgInfo.InstanceName.toLowerCase(),
                'namespace' => String.valueOf(hubUtilities.class).split('[.]').size() > 1 ? String.valueOf(hubUtilities.class).split('[.]')[0] : 'c',
                'orgId' => (String) hubUtilities.orgInfo.Id,
                'isSandbox' => hubUtilities.orgInfo.IsSandbox,
                'token' => refreshToken
            }));
            
            HttpResponse res = (new Http()).send(req);
            system.debug('res >>'+(res.getBody()));
            if (201 == res.getStatusCode()) {
                responseMap.put('isSuccess', true);
                responseMap.put('url', res.getBody());
            } else {
                hubUtilities.createErrorLog(req, res);

                responseMap.put('isSuccess', false);
                responseMap.put('error', res.getStatusCode() + ':' + res.getStatus());
            }
        /*} catch (Exception e) {
            Error_Log__c errorLog = hubUtilities.createErrorLog(e, req);

            responseMap.put('isSuccess', false);
            responseMap.put('error', e.getMessage());
        }*/

        return responseMap;
    }

    private static Error_Log__c createErrorLog(Exception e) {
        return hubUtilities.createErrorLog(e.getLineNumber() + ':' + e.getMessage() + '\n\n' +
                                           e.getStackTraceString());
    }

    public static Error_Log__c createErrorLog(HttpRequest req, HttpResponse res) {
        return hubUtilities.createErrorLog(req.getMethod() + ':' + req.getEndpoint() + '\n\n' +
                                           req.getBody() + '\n\n' +
                                           res.getStatusCode() + ':' + res.getStatus() + '\n\n' +
                                           res.getBody());
    }

    private static Error_Log__c createErrorLog(Exception e, HttpRequest req) {
        return hubUtilities.createErrorLog(e.getLineNumber() + ':' + e.getMessage() + '\n\n' +
                                           e.getStackTraceString() + '\n\n' +
                                           req.getMethod() + ':' + req.getEndpoint() + '\n\n' +
                                           req.getBody());
    }

    private static Error_Log__c createErrorLog(String message) {
        Error_Log__c errorLog = new Error_Log__c(Message__c = message);
        insert errorLog;

        return errorLog;
    }

    private static Map<String, Map<String, Set<String>>> checkAccessForOrganization = new Map<String, Map<String, Set<String>>> {
        'Organization' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Id', 'InstanceName', 'IsSandbox'
                }
            },
            'Loop_And_Tie_Org_Default__mdt' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Id', 'Client_Id_Prod__c', 'Client_Id_Sandbox__c', 'Client_Secret_Prod__c', 'Client_Secret_Sandbox__c'
                }
            },
            'Hub_Key__mdt' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'URL__c'
                }
            }
    };
        
    private static Map<String, Map<String, Set<String>>> customObjectChecks = new Map<String, Map<String, Set<String>>> {
        'Error_Log__c' => new Map<String, Set<String>> {
            'Create' => new Set<String> {
                'Message__c '
            }
        }
    };

    private static void checkAccess(Map<String, Map<String, Set<String>>> accessMapByObjectName, Boolean appendNamespace){
        dmlManager.checkAccess(accessMapByObjectName, appendNamespace);
    }
}