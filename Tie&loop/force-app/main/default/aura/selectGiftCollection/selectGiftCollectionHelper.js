({
    getTeamCollections : function(component, event, helper, team) {
        var getTeamCollection = component.get('c.getTeamCollections');
        var teamCollections = component.get('v.teamCollections');
        var selectedTeam = team;
        component.set('v.collections', []);
        var collectionDetails = {};
        var collectionList =[];

        getTeamCollection.setParams({
                 team: selectedTeam
         });
        getTeamCollection.setCallback(this, function(res){
            var response = JSON.parse(res.getReturnValue());
            if(response.isSuccess){
                var collection = response.results.body;
                collection.data.forEach(function(element){
                    collectionDetails = {'name': element.attributes.name}
                    collectionList.push(collectionDetails);
                });
                var teamCollectionObj = {
                    team: selectedTeam,
                    collection: collectionList
                };
                teamCollections.push(teamCollectionObj);

                component.set('v.teamCollections', teamCollections);
                helper.setTeamCollections(component, event, helper, selectedTeam, false);
            }else{
                component.set('v.errorMessage', response.errMsg);
            }
        });
        $A.enqueueAction(getTeamCollection);
    },
    setTeamCollections : function(component, event, helper, team, listContainsTeam){
        var teamCollections = component.get('v.teamCollections');
        var selectedTeam = team;
        var tempArray =[];
        var tempArrayNoDollarSign =[];

        teamCollections.forEach(function(element){
            if(listContainsTeam){
                if(element.team === selectedTeam){
                    for(var i = 0; i < element.collection.length; i++){
                        if(!element.collection[i].name.startsWith("$")){
                            tempArrayNoDollarSign.push(element.collection[i].name);
                        }else{
                            tempArray.push(element.collection[i].name.replace("$", ""));
                        }
                        
                    }
                    tempArray.sort((a,b) => a - b);
                    tempArrayNoDollarSign.sort((a,b) => a - b);
                    for(var i = 0; i < tempArray.length; i++){

                        tempArray[i] = '$' + tempArray[i];
                    }
                    for(var i = 0; i < tempArrayNoDollarSign.length; i++){
                        tempArray.push(tempArrayNoDollarSign[i]);
                    }
                }
            }else{
                if(element.team === selectedTeam){
                    for(var i = 0; i < element.collection.length; i++){
                        if(!element.collection[i].name.startsWith("$")){
                            tempArrayNoDollarSign.push(element.collection[i].name);
                        }else{
                            tempArray.push(element.collection[i].name.replace("$", ""));
                        }
                    }
                }
                tempArray.sort((a,b) => a - b);
                tempArrayNoDollarSign.sort((a,b) => a - b);
                for(var i = 0; i < tempArray.length; i++){

                    tempArray[i] = '$' + tempArray[i];
                }
                for(var i = 0; i < tempArrayNoDollarSign.length; i++){
                    tempArray.push(tempArrayNoDollarSign[i]);
                }
            }
        })
        component.set('v.collections', tempArray);
        console.log('collections >>'+component.get("v.collections"));
    }
})