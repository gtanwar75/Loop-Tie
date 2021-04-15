public with sharing class setup {
    public String namespace { get; set; }

    public setup() {
        namespace = constants.NAMESPACE;
    }

    @AuraEnabled
    public static String getData() {
        responseData response = new responseData();

        try {
            if (!setup.checkAccess()) {
                response.addError('Access Check failed');

                return response.getJsonString();
            }

            List<String> fields = new List<String>();

            for (Schema.SObjectField field : Setup_Data__c.sObjectType.getDescribe().fields.getMap().values()) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

                if (fieldDescribe.isCustom()) {
                    fields.add(fieldDescribe.getName());
                }
            }

            List<SObject> data = Database.query('SELECT ' + String.join(fields, ',') + ' FROM ' + constants.NAMESPACE_API + 'Setup_Data__c WHERE Name = \'Default\'');

            if (data.isEmpty()) {
                response.put('data', new Setup_Data__c(
                    Steps_Completed__c = 0,
                    Name = 'Default'
                ));
            } else {
                response.put('data', data[0]);
            }
        } catch (Exception e) {
            response.addError(e.getMessage());
        }
        return response.getJsonString();
    }

    @AuraEnabled
    public static String saveData(String data) {
        responseData response = new responseData();

        try {
            if (!setup.checkAccess()) {
                response.addError('Access Check failed');

                return response.getJsonString();
            }

            Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(data);

            List<Setup_Data__c> setupData = [SELECT Id 
                                            FROM Setup_Data__c
                                            WHERE Name = 'Default'];
            Setup_Data__c dataObj = (Setup_Data__c)utilities.getSobjectByMap(dataMap, constants.NAMESPACE_API + 'Setup_Data__c');
            dataObj.Name = 'Default';
            if(setupData.size() > 0){
                dataObj.Id=setupData[0].Id;
            }
            upsert dataObj;
            response.put('data', dataObj);
            
        } catch (Exception e) {
            response.addError(e.getMessage());
        }

        return response.getJsonString();
    }

    private static Boolean checkAccess() {
        Set<String> fields = new Set<String>();

        for (Schema.SObjectField field : Setup_Data__c.sObjectType.getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

            if (fieldDescribe.isCustom()) {
                fields.add(fieldDescribe.getName());
            }
        }

        fields.add('Name');

        return dmlManager.checkAccess(new Map<String, Map<String, Set<String>>> {
            'Setup_Data__c' => new Map<String, Set<String>> {
                'Read' => fields,
                'Create' => fields,
                'Update' => fields
            }
        });
    }
}