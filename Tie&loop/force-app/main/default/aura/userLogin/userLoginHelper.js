({
    getUserTeams: function(component, event, helper){
        var getTeams = component.get("c.getUserTeams");
        var teamsList = [];
        getTeams.setCallback(this, function(res){
            var response = JSON.parse(res.getReturnValue());
            console.log(JSON.stringify(response));
            if(response.isSuccess){
                var teams = response.results.body;
                teams.data.forEach(function(element){
                        teamsList.push(element.id);
                });
                component.set('v.teams', teamsList);
                component.set('v.userLoggedIn', true);
                component.set('v.isLoading', false);
            }else{
                component.set('v.errorMessage', response.errMsg);
            }
        });
        $A.enqueueAction(getTeams);
    }
})