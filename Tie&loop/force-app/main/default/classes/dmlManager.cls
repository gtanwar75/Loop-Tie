public with sharing class dmlManager {
    public static Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
    private static Boolean appendOurNamespace;
    // checkAccess example param
    //
    // Map<String, Map<String, Set<String>>> accessMapByObjectName = new Map<String, Map<String, Set<String>>> {
    //     'Account' => new Map<String, Set<String>> {
    //         'Create' => new Set<String> {
    //             'Name'
    //         },
    //         'Read' => new Set<String> {
    //             'Id', 'Name'
    //         },
    //         'Update' => new Set<String> {
    //             'Name'
    //         },
    //         'Delete' => new Set<String>()
    //     },
    //     'Contact' => new Map<String, Set<String>> {
    //         'Read' => new Set<String> {
    //             'Id', 'Name'
    //         }
    //     }
    // }

    public static Boolean checkAccess(Map<String, Map<String, Set<String>>> accessMapByObjectName) {
        return checkAccess(accessMapByObjectName, true);
    }

    public static Boolean checkAccess(Map<String, Map<String, Set<String>>> accessMapByObjectName, Boolean appendNamespace) {
        appendOurNamespace = appendNamespace;
        Set<String> objectNameSet = accessMapByObjectName.keySet();

        for (String objectName : objectNameSet) {
            if (!checkAccess(accessMapByObjectName, objectName)) {
                return false;
            }
        }

        return true;
    }

    public static Boolean checkAccess(Map<String, Map<String, Set<String>>> accessMapByObjectName, String objectName) {
        if (String.isBlank(objectName) || !accessMapByObjectName.containsKey(objectName)) {
            return false;
        }

        Map<String, Set<String>> fieldNameListByAccess = accessMapByObjectName.get(objectName);
        Set<String> accessSet = fieldNameListByAccess.keySet();

        for (String access : accessSet) {
            Set<String> fieldNameList = fieldNameListByAccess.get(access);

            if (access == 'Create') {
                checkCreate(objectName);
            } else if (access == 'Read') {
                checkRead(objectName, fieldNameList);
            } else if (access == 'Update') {
                checkUpdate(objectName, fieldNameList);
            } else if (access == 'Delete') {
                checkDelete(objectName);
            } else {
                throw new DmlException(String.format('Unknown access {0}', new List<String>{access}));
            }
        }

        return true;
    }

    private static void checkCreate(String objectName) {
        SObjectType mSObjectType = getSObjectTypeByObjectName(objectName);
        if (!mSObjectType.getDescribe().isCreateable()) {
            throw new DmlException(String.format('Insufficient {0} access on object {1}', new List<String>{'Create', objectName}));
        }
    }

    private static void checkRead(String objectName, Set<String> fieldNameList) {
        SObjectType mSObjectType = getSObjectTypeByObjectName(objectName);

        if (!mSObjectType.getDescribe().isAccessible()) {
            throw new DmlException(String.format('Insufficient {0} access on object {1}', new List<String>{'Read', objectName}));
        }

        for (String fieldName : fieldNameList) {
            List<String> fieldNameParts = fieldName.split('[.]', 2);
            String isolatedFieldName = fieldNameParts[0].replaceFirst('__r$', '__c');

            Schema.DescribeFieldResult mSObjectFieldDescribe;
            try {
                mSObjectFieldDescribe = getSObjectFieldByFieldNameAndSObjectType(isolatedFieldName, mSObjectType);
            } catch (DmlException e) {
                mSObjectFieldDescribe = getSObjectFieldByFieldNameAndSObjectType(isolatedFieldName + 'Id', mSObjectType);
            }

            if (!mSObjectFieldDescribe.isAccessible()) {
                throw new DmlException(String.format('Insufficient {0} access on field {1} on object {2}', new List<String>{'Read', isolatedFieldName, objectName}));
            }

            if (fieldNameParts.size() > 1) {
                if (mSObjectFieldDescribe.getType() == Schema.DisplayType.Reference) {
                    for (Schema.sObjectType sObjType : mSObjectFieldDescribe.getReferenceTo()) {
                        checkRead(sObjType.getDescribe().getName(), new Set<String>{fieldNameParts[1]});
                    }
                } else {
                    throw new DmlException(String.format('Unknown field {0} on object {1}', new List<String>{objectName, fieldName}));
                }
            }
        }
    }

    private static void checkUpdate(String objectName, Set<String> fieldNameList) {
        SObjectType mSObjectType = getSObjectTypeByObjectName(objectName);

        if (!mSObjectType.getDescribe().isUpdateable()) {
            throw new DmlException(String.format('Insufficient {0} access on object {1}', new List<String>{'Update', objectName}));
        }

        for (String fieldName : fieldNameList) {
            Schema.DescribeFieldResult mSObjectFieldDescribe = getSObjectFieldByFieldNameAndSObjectType(fieldName, mSObjectType);

            if (!mSObjectFieldDescribe.isUpdateable()) {
                throw new DmlException(String.format('Insufficient {0} access on field {1} on object {2}', new List<String>{'Update', fieldName, objectName}));
            }
        }
    }

    private static void checkDelete(String objectName) {
        SObjectType mSObjectType = getSObjectTypeByObjectName(objectName);

        if (!mSObjectType.getDescribe().isDeletable()) {
            throw new DmlException(String.format('Insufficient {0} access on object {1}', new List<String>{'Delete', objectName}));
        }
    }

    private static SObjectType getSObjectTypeByObjectName(String objectName) {
        if (globalDescribe.containsKey(constants.NAMESPACE_API + objectName)) {
            return globalDescribe.get(constants.NAMESPACE_API + objectName);
        }

        if (!globalDescribe.containsKey(objectName)) {
            throw new DmlException(String.format('Unknown object {0}', new List<String>{objectName}));
        }

        return globalDescribe.get(objectName);
    }

    private static DescribeFieldResult getSObjectFieldByFieldNameAndSObjectType(String fieldName, SObjectType mSObjectType) {
        Schema.DescribeSObjectResult mDescribeSObjectResult = mSObjectType.getDescribe();
        Map<String, Schema.SObjectField> mSObjectFieldDescribeByFieldName = mDescribeSObjectResult.fields.getMap();

        if (mSObjectFieldDescribeByFieldName.containsKey(constants.NAMESPACE_API + fieldName)) {
            return mSObjectFieldDescribeByFieldName.get(constants.NAMESPACE_API + fieldName).getDescribe();
        }

        if (!mSObjectFieldDescribeByFieldName.containsKey(fieldName)) {
            throw new DmlException(String.format('Unknown field {0} on object {1}', new List<String>{fieldName, mDescribeSObjectResult.getName()}));
        }

        return mSObjectFieldDescribeByFieldName.get(fieldName).getDescribe();
    }
}