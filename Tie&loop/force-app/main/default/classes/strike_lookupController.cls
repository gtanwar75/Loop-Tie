/* --------------------------------------------------
Strike by Appiphony

Version: 0.10.0
Website: http://www.lightningstrike.io
GitHub: https://github.com/appiphony/Strike-Components
License: BSD 3-Clause License
-------------------------------------------------- */
public with sharing class strike_lookupController {

    @AuraEnabled
    public static String getRecords(String jsonString, Boolean isSearch) {
        strike_responseData responseData = new strike_responseData();

        
        try {
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            responseData.results = strike_lookupController.getData(jsonMap, isSearch);
        } catch (Exception e) {
            responseData.addError(e.getMessage());
        }

        return responseData.getJsonString();
    }

    private static Map<String, Object> getData(Map<String, Object> jsonMap, Boolean isSearch) {
        List<Map<String, Object>> data = new List<Map<String, Object>>();
        String searchField = 'Name';
        String searchTerm = '';
        String subtitleField = 'Email';
        
        try{
            //checkAccess(standardObjectChecks, false);
            String objType = String.escapeSingleQuotes((String)jsonMap.get('object'));
            String objTypeCampaign = String.escapeSingleQuotes((String)jsonMap.get('objectCampaign'));
            if(objType == 'Contact'){ 
                checkAccess(contactObjChecks, false);
            }else if(objType == 'Lead'){
                checkAccess(leadObjChecks, false);
            }else if(objType == 'Campaign'){
                checkAccess(contactObjChecks, false);
                checkAccess(leadObjChecks, false);
            }
            
            List<String> queryList = new List<String>();
            
            if(objType == 'Campaign'){
                for(String objType1 : objTypeCampaign.split(',')){
                    queryList.add(strike_lookupController.getQuery(jsonMap, isSearch, objType1));
                }
            }
            else{
                queryList.add(strike_lookupController.getQuery(jsonMap, isSearch, objType));
            }
            system.debug(queryList);
            if (strike_lookupController.fieldNotEmpty(jsonMap, 'searchTerm')) {
                //still needs to be dynamic
                searchTerm = String.escapeSingleQuotes((String)jsonMap.get('searchTerm'));
            }
            
            if (String.isEmpty(subtitleField)) {
                for(String query : queryList){
                    for (sObject obj : Database.query(query)) {
                        String objType1 = String.valueOf(obj.Id.getSObjectType());
                        data.add(new Map<String, Object>{
                            'label' => strike_lookupController.getValue(obj, objType1, searchField),
                                'value' => obj.get('Id')
                                });
                    }
                }
            } else {
                for(String query : queryList){
                    for (sObject obj : Database.query(query)) {
                        String objType1 = String.valueOf(obj.Id.getSObjectType());
                        data.add(new Map<String, Object>{
                            'label' => strike_lookupController.getValue(obj, objType1, searchField),
                                'sublabel' => strike_lookupController.getValue(obj, objType1, subtitleField),
                                'value' => obj.get('Id')
                                });
                    } 
                }
            }
        }catch(Exception e){
            e.getMessage();
        }
        return new Map<String, Object>{
            'data' => data,
                'searchTerm' => searchTerm
                };
                    }

    private static String getQuery(Map<String, Object> jsonMap, Boolean isSearch, String objName) {
        Set<String> queryFields = new Set<String>{'Id'};
        List<String> filters = new List<String>();
        List<String> orders = new List<String>();

        String query;
        String emails = '';
        String obj = objName;//String.escapeSingleQuotes((String)jsonMap.get('object')); 

        String subtitleField;
        try{
            query = 'SELECT Id, Email, Name FROM ' + obj + ' WHERE Email != null';
            
            
            if(strike_lookupController.fieldNotEmpty(jsonMap, 'ids')){
                if(isSearch){
                    query += ' AND Id NOT IN (' + jsonMap.get('ids') + ')' ; System.debug('Line 113 query ' + query);
                    List<SObject> emailQuery = Database.query('SELECT Id, Email FROM ' + obj + ' WHERE Id != null AND Id IN (' + jsonMap.get('ids') + ')');
                    for(SObject email : emailQuery){
                        emails += '\'' + email.get('Email') + '\'' + ',';
                    }
                    emails = emails.removeEnd(',');
                    if(String.isNotBlank(emails)){
                        query += ' AND Email NOT IN (' + emails + ')' ;
                    }
                } else{
                    query += ' AND Id IN (' + jsonMap.get('ids') + ')';
                }
            }
            System.debug('jsonMap ' + jsonMap.get('emailopt'));
            if(jsonMap.get('emailopt') == true){
                query += ' AND hasoptedoutofemail=false';
            }
            
            if(strike_lookupController.fieldNotEmpty(jsonMap, 'searchTerm')){
                query += ' AND Name LIKE \'%' + jsonMap.get('searchTerm') + '%\'';
            }
            
            if (orders.size() > 0) {
                query += ' ORDER BY Name';
            }
            
            if (isSearch) {
                query += ' LIMIT 10';
            } else{
                query += ' LIMIT 1000';
            }
            system.debug('query '+query);
            //TODO: check access for id, name, email by obj type
        }catch(Exception e){
            e.getMessage();
        }
        return query;
    }
    
    private static Boolean fieldNotEmpty(Map<String, Object> jsonMap, String field) {
        return jsonMap.containsKey(field) && !String.isEmpty((String)jsonMap.get(field));
    }
    
    private static String getValue(SObject obj, String objectType, String field) {
        List<String> fieldPath = field.split('[.]');
        Object label = strike_utilities.convertObjectToMap(obj);
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectType).getDescribe().fields.getMap();
        try{
            for (String fieldName : fieldPath) {
                fieldName = fieldName.replaceAll('__r$', '__c');
                
                label = ((Map<String, Object>)label).get(fieldName);
                
                if (label == null) {
                    return '';
                }
                
                if (fieldMap.containsKey(fieldName + 'Id')) {
                    fieldName = fieldName + 'Id';
                }
                
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                String fieldType = String.valueOf(fieldDescribe.getType()).toUpperCase();
                
                if (fieldType == 'REFERENCE') {
                    fieldMap = Schema.getGlobalDescribe().get(String.valueOf(fieldDescribe.getReferenceTo().get(0))).getDescribe().fields.getMap();
                } else if (fieldType == 'ADDRESS') {
                    List<String> addressComponents = new List<String>();
                    Map<String, Object> addr = (Map<String, Object>)label;
                    
                    if (addr.containsKey('street') && addr.get('street') != null) {
                        addressComponents.add((String)addr.get('street'));
                    }
                    
                    if (addr.containsKey('city') && addr.get('city') != null) {
                        addressComponents.add((String)addr.get('city'));
                    }
                    
                    if (addr.containsKey('state') && addr.get('state') != null) {
                        addressComponents.add((String)addr.get('state'));
                    }
                    
                    if (addr.containsKey('country') && addr.get('country') != null) {
                        addressComponents.add((String)addr.get('country'));
                    }
                    
                    if (addr.containsKey('postalCode') &&addr.get('postalCode') != null) {
                        addressComponents.add((String)addr.get('postalCode'));
                    }
                    
                    // change later for user formatting?
                    label = String.join(addressComponents, ', ');
                }
            }
        }catch(Exception e){
            e.getMessage();
        }
        return String.valueOf(label);
    }
	@AuraEnabled
    public static List<Map<String, Object>> setEmailOpt(String jsonString,Boolean emailOpt){
        system.debug('jsonStringjsonStringjsonString'+jsonString);
        system.debug('emailOptemailOptemailOpt'+emailOpt);
        List<Map<String, Object>> responseList = new List<Map<String, Object>>();
        try{
            List<Object> recipientList = (List<Object>)JSON.deserializeUntyped(jsonString);
            Set<String> conIdSet = new Set<String>();
            Set<String> leadIdSet = new Set<String>();
            String emailCondition = '';
            for(object obj : recipientList){
                Map<String, Object> recipientMap = (Map<String, Object>)obj;
                String value = String.valueOf(recipientMap.get('value'));
                if(String.isNotBlank(value)){
                    if(value.startsWith('003')){
                        conIdSet.add(value);
                    }
                    if(value.startsWith('00Q')){
                        leadIdSet.add(value);
                    }
                }
            }
            
            if(emailOpt){
                emailCondition = ' and hasoptedoutofemail=false';
            }
            if(conIdSet.size() > 0){
                if(Schema.sObjectType.Contact.isAccessible()){
                    String conQuery = 'Select Id,Name,Email,hasoptedoutofemail from contact where Id IN:conIdSet '+emailCondition;
                    system.debug('conQuery  '+conQuery);
                    List<Contact> conList = Database.query(conQuery);
                    for(Contact con: conList){
                        Map<String, Object> recipientMap = new Map<String, Object>();
                        recipientMap.put('title',con.Name);
                        recipientMap.put('subtitle',con.Email);
                        recipientMap.put('value',con.Id);
                        responseList.add(recipientMap);
                    }
                }
            }
            if(leadIdSet.size() > 0){
                if(Schema.sObjectType.Lead.isAccessible()){
                    String leadQuery = 'Select Id,Name,Email,hasoptedoutofemail from Lead where Id IN:leadIdSet '+emailCondition;
                    system.debug('Lead Query >>'+leadQuery);
                    List<Lead> leadList = Database.query(leadQuery);
                    for(Lead led: leadList){
                        Map<String, Object> recipientMap = new Map<String, Object>();
                        recipientMap.put('title',led.Name);
                        recipientMap.put('subtitle',led.Email);
                        recipientMap.put('value',led.Id);
                        responseList.add(recipientMap);
                    }
                }
            }
        }catch(Exception e){
            e.getMessage();
        }
        return responseList;
    }
    
    private static Map<String, Map<String, Set<String>>> contactObjChecks = new Map<String, Map<String, Set<String>>> {
        'Contact' => new Map<String, Set<String>> {
            'Read' => new Set<String> {
                'Id', 'Name', 'Email'
                    }
        } 
    };
        
        private static Map<String, Map<String, Set<String>>> leadObjChecks = new Map<String, Map<String, Set<String>>> {
            'Lead' => new Map<String, Set<String>> {
                'Read' => new Set<String> {
                'Id', 'Name', 'Email'
            }
        }
    };

    private static void checkAccess(Map<String, Map<String, Set<String>>> accessMapByObjectName, Boolean appendNamespace){
        dmlManager.checkAccess(accessMapByObjectName, appendNamespace);
    }
    
}


/* --------------------------------------------------
Copyright 2017 Appiphony, LLC

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the 
following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following 
disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following 
disclaimer in the documentation and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote 
products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------- */