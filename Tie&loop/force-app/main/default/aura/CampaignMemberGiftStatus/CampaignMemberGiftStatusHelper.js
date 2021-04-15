({
    getGiftList : function(component, event, helper) {	
        var selectedValue= component.find('status').get('v.value');
        var selectedMember= component.find('member').get('v.value');
        var recId=  component.get("v.recordId");
        console.log('Send Gift Campaign');
        var action = component.get('c.giftsToCampaignMembers');
        action.setParams({
            "campaignId":recId,
            "giftStatus":selectedValue,
            "fMember":selectedMember
        });
        
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var response = a.getReturnValue();
                if(response.isSuccess){
                    console.log(response.userList);
                    if(response.userList !== undefined && response.userList.length > 0){
                        component.set("v.giftList",response.userList);
                        component.set("v.giftListWithoutFilter",response.userList);
                    }else{
                        component.set("v.giftList",null);    
                    }   
                    helper.getDynamicChartData(component, event, helper);
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": response.message,
                        "type":"error"
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getDynamicChartData : function(component, event, helper){
        var giftList = component.get("v.giftList");
        var giftStatusValues = [];
        var dataVar = [];
        var current = null;
        var cnt = 0;
        
        if(giftList != null && giftList != ""){
            for(var i=0; i < giftList.length; i++){
                giftStatusValues.push(giftList[i].giftStatus);
            }
            giftStatusValues.sort();
            
            for (var i = 0; i < giftStatusValues.length; i++) {
                if (giftStatusValues[i] != current) {
                    if (cnt > 0) {
                        dataVar.push({"y":cnt,"name":current});
                    }
                    current = giftStatusValues[i];
                    cnt = 1;
                } else {
                    cnt++;
                }
            }
            if (cnt > 0) {
                dataVar.push({"y":cnt,"name":current});
            }
            component.set("v.data",JSON.stringify(dataVar));
        }
        else{
            component.set("v.data",null);  
        }
    },
    
    getFilterRecords : function(component, event, helper){
        var searchText=  component.get("v.searchText");
        var giftList = component.get("v.giftList");
        var giftListWithoutFilter = component.get("v.giftListWithoutFilter");
        var filterRecords = [];
        var k = searchText.length;
        
        for(var i=0; i < giftListWithoutFilter.length; i++){
            var nameInitials = giftListWithoutFilter[i].name.substring(0,k);
            
            if(nameInitials.toLowerCase() == searchText.toLowerCase()){
                filterRecords.push(giftListWithoutFilter[i]);
            }
        }
        
        if(searchText != ""){
            component.set("v.giftList",filterRecords);
        }
        else if(searchText == ""){
            component.set("v.giftList",giftListWithoutFilter);
        }
        helper.getDynamicChartData(component, event, helper);
    },
    
    convertArrayOfObjectsToCSV : function(component,objectRecords){
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        // store ,[comma] in columnDivider variabel for sparate CSV values and for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
        
        // this labels use in CSV file header  
        keys = ['Name','Email','MemberType','GiftStatus'];
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
        
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
            for(var sTempkey in keys) {
                var skey;
                if(keys[sTempkey] === "Name") skey = "name";
                if(keys[sTempkey] === "Email") skey = "email";
                if(keys[sTempkey] === "MemberType") skey = "memberType";
                if(keys[sTempkey] === "GiftStatus") skey = "giftStatus";
                
                if(counter > 0){ 
                    csvStringResult += columnDivider; 
                } 
                csvStringResult += '"'+ objectRecords[i][skey]+'"';
                counter++;
            }
            csvStringResult += lineDivider;
        } 
        return csvStringResult;        
    },
})