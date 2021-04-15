({
    handleTeamSelection : function(component, event, helper) {
        var selectedTeam = component.get('v.selectedTeam');
        component.set('v.selectedCollection', '');
        var teamCollections = component.get('v.teamCollections');

        if(teamCollections.length > 0){
            var listContainsTeam = false;
            teamCollections.forEach(function(element){
                if(selectedTeam === element.team){
                    listContainsTeam = true;
                }
            })
            if(listContainsTeam){
                helper.setTeamCollections(component, event, helper, selectedTeam, listContainsTeam);
            }else{
                helper.getTeamCollections(component, event, helper, selectedTeam);
            }
        }else{
            helper.getTeamCollections(component, event, helper, selectedTeam);
        }
    },
    checkFieldValidation : function(component, event, helper){
        var selectedTeam = component.get('v.selectedTeam');
        var selectedCollection = component.get('v.selectedCollection');
        var activeStep = component.get('v.activeStep');

        if(activeStep === 1){
            if(selectedTeam === '' || selectedCollection === ''){
                component.set('v.buttonDisabled', true);
            }else{
                component.set('v.buttonDisabled', false);
            }
        }
    }
})