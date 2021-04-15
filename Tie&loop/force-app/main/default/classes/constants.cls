public with sharing class constants {
    public String ns {get; set;}
    public String memberType {get;set;}
    public constants() {
        ns = NAMESPACE;
        Id recordId = ApexPages.currentPage().getParameters().get('id');//current page recordId
        memberType = recordId.getSObjectType().getDescribe().getName();//give object name 
        //checkAccess(checkAccessForOrganization, true);
    }
    public static FINAL Boolean IS_SANDBOX = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandBox;
    private static Loop_And_Tie_Org_Default__mdt loopAndTieOrgDefaults = [SELECT Id, Client_Id_Prod__c, Client_Id_Sandbox__c, Client_Secret_Prod__c, Client_Secret_Sandbox__c
                                                                          FROM Loop_And_Tie_Org_Default__mdt
                                                                          LIMIT 1];

    public static Hub_Key__mdt pboOrgCredentials = [SELECT Id, Client_Id__c, Client_Secret__c
                                                    FROM Hub_Key__mdt 
                                                    LIMIT 1];
    public static FINAL String NAMESPACE = String.valueOf(constants.class).split('[.]').size() > 1 ? String.valueOf(constants.class).split('[.]')[0] : 'c';
    public static FINAL String NAMESPACE_API = NAMESPACE == 'c' ? '' : NAMESPACE + '__';
    public static FINAL String BASE_LOOPTIE_API = 'https://api.loopandtie.com/v1'; //'https://api.loopandtie-demo.info/v1'; 
    public static FINAL String BASE_AUTHORIZE_LOOPTIE_API = 'https://www.loopandtie.com/oauth2/authorize'; //'https://www.loopandtie-demo.info/oauth2/authorize';
    public static FINAL String BASE_AUTH_TOKEN_LOOPTIE_API = 'https://www.loopandtie.com/oauth2/token'; //'https://www.loopandtie-demo.info/oauth2/token'; 
    public static FINAL String SANDBOX_REDIRECT_URI = 'https://test.salesforce.com/apex/'+ NAMESPACE_API + 'completeOauth2';
    public static FINAL String PROD_REDIRECT_URI = 'https://login.salesforce.com/apex/'+ NAMESPACE_API + 'completeOauth2';

    public static FINAL String PBO_ORG_CLIENT_ID = pboOrgCredentials.Client_Id__c;
    public static FINAL String PBO_ORG_CLIENT_SECRET = pboOrgCredentials.Client_Secret__c;

    public static FINAL String CLIENT_ID_SANDBOX = loopAndTieOrgDefaults.Client_Id_Sandbox__c;
    public static FINAL String CLIENT_SECRET_SANDBOX = loopAndTieOrgDefaults.Client_Secret_Sandbox__c;
    public static FINAL String CLIENT_ID_PROD = loopAndTieOrgDefaults.Client_Id_Prod__c; //'d9daef1ad43dffa7b0b807d487e8207a5be2801933adbf362beca9dec0547a5a';
    public static FINAL String CLIENT_SECRET_PROD = loopAndTieOrgDefaults.Client_Secret_Prod__c; //'db4a9914723f7035a99094a8f81615f5af8b9afb14700529058fa32506b2383d'; 
    

    public static FINAL String SALESFORCE_INSTANCE_URI = System.URL.getSalesforceBaseURL().toExternalForm();
    public static FINAL String SALESFORCE_BASE_URI = 'https://' + (IS_SANDBOX ? 'test' : 'login') + '.salesforce.com';
    public static FINAL String SALESFORCE_OAUTH_URI = SALESFORCE_BASE_URI + '/services/oauth2';
    
    private static Map<String, Map<String, Set<String>>> checkAccessForOrganization = new Map<String, Map<String, Set<String>>> {
        'Organization' => new Map<String, Set<String>> {
            'Read' => new Set<String> {
                'IsSandbox'
                    }
        },
            'Loop_And_Tie_Org_Default__mdt' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                    'Id', 'Client_Id_Prod__c', 'Client_Id_Sandbox__c', 'Client_Secret_Prod__c', 'Client_Secret_Sandbox__c'
                        }
            },
                'Hub_Key__mdt' => new Map<String, Set<String>> {
                    'Read' => new Set<String> {
                        'Id', 'Client_Id__c', 'Client_Secret__c'
                            }
                }
    };
    private static void checkAccess(Map<String, Map<String, Set<String>>> accessMapByObjectName, Boolean appendNamespace){
        dmlManager.checkAccess(accessMapByObjectName, appendNamespace);
    }
}