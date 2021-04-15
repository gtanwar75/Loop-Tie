({  init : function(component,event, helper){
        component.set('v.isLoading', false);
    },
    handleSubmitButtonClick : function(component, event, helper) {
        var redirectURL = component.get('v.redirectURL');
        console.log('redirectURL >>'+redirectURL);
        redirectURL+='&state='+ window.location.href;
        console.log(redirectURL)
        try{
            window.addEventListener('message', $A.getCallback(function(event){
                if(event.origin === 'https://loopandtie.secure.force.com'){
					console.log('event.data.code >>'+event.data.code);
                    if(event.data.code) {
                        var action = component.get('c.getToken');
                        action.setParams({
                            code: event.data.code
                        });
                        action.setCallback(this, function(res) {
                            var parsedRes = JSON.parse(res.getReturnValue());
                            console.log(JSON.stringify(parsedRes));
                            if (parsedRes.isSuccess) {
                                helper.getUserTeams(component, event, helper);
                            } else {
                                console.log('********' + parsedRes.error);

                                helper.showToast(component, {
                                    message: parsedRes.error,
                                    type: 'error'
                                });
                            }

                        });
                        $A.enqueueAction(action);
                    }
                }
            }))
            console.log(redirectURL);
            window.open(redirectURL, 'oAuth', "width=500px, height=500px");

        }catch(e){
            console.log(e);
        }
    }
})