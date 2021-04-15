({
    init : function(component, event, helper){
        component.set('v.defaultImageUrl', 'https://d2g0unjhwtexh1.cloudfront.net/uploads/designs/8/1454783314/uploads/standard.jpg?1454783314');
        component.set('v.defaultLogoUrl', 'https://d2g0unjhwtexh1.cloudfront.net/images/email/v1/logo-thin.png');
    },
    getUserTeamLogos : function(component, event, helper){
        var getUserLogos = component.get('c.getUserLogos');
        var selectedTeam = component.get('v.selectedTeam');
        console.log('selectedTeam '+selectedTeam);
        getUserLogos.setParams({
           team : selectedTeam
        })

        getUserLogos.setCallback(this, function(res){
            var response = JSON.parse(res.getReturnValue());
            console.log('response >>'+JSON.stringify(response));
            if(response.isSuccess){
                var body = response.results.body.data;
                helper.getUserTeamDesigns(component, event, helper);
                body.forEach(function(element){
                    element.attributes.imageUrl = element.attributes['image-url'];
                })
                component.set('v.userLogos', body);
            }else{
                component.set('v.errorMessage', response.errMsg);
            }
        });
        $A.enqueueAction(getUserLogos);
    },
    getLogoId : function(component, event, helper){
        var logos = component.get('v.userLogos');
        var logoUrl = component.get('v.selectedLogoUrl');
        logos.forEach(function(element){
            if(element.attributes.imageUrl === logoUrl){
                component.set('v.selectedLogoId', element.id);
            }
        })
    },
    getImageId : function(component, event, helper){
        var images = component.get('v.userDesigns');
        var imageUrl = component.get('v.selectedImageUrl');
        images.forEach(function(element){
            if(element.attributes.imageUrl === imageUrl){
                component.set('v.selectedImageId', element.id);
                component.set('v.hasLogo', element.attributes.hasLogo);
            }
        })
    }
})