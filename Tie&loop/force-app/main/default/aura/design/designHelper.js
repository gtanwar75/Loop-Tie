({
    getUserTeamDesigns : function(component, event, helper){
        var getUserDesigns = component.get('c.getUserDesigns');
        var selectedTeam = component.get('v.selectedTeam');
        getUserDesigns.setParams({
           team : selectedTeam
        })

        getUserDesigns.setCallback(this, function(res){
            var response = JSON.parse(res.getReturnValue());
            if(response.isSuccess){
                var body = response.results.body.data;
                body.forEach(function(element){
                    element.attributes.imageUrl = element.attributes['image-url'];
                    element.attributes.hasLogo = element.attributes['has-logo'];
                })
                component.set('v.userDesigns', body);
            }else{
                component.set('v.errorMessage', response.errMsg);
            }
        });
        $A.enqueueAction(getUserDesigns);
    }
})