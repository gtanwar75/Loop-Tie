({
    init : function(component, event, helper) {
        var getAuthURL = component.get("c.getAuthURL");
        getAuthURL.setCallback(this, function(res){
            var response = JSON.parse(res.getReturnValue());
            if(response.isSuccess){
                var oauthURL = response.results.oauthURL;
                component.set('v.oauthURL', oauthURL);
                helper.addOauthListener(component, helper)
            }else{
                console.log(response.errMsg);
            }
        });
        $A.enqueueAction(getAuthURL);
    },
    handleOauthClick : function(component, event, helper) {

        var oauthURL = component.get('v.oauthURL');
        oauthURL += '&state=' + window.location.origin;
        console.log(typeof(oauthURL));
        component.get('v.initOauth')(oauthURL);

        var width = 500;
        var height = 500;
        var left = (screen.width / 2) - (width / 2);
        var top = (screen.height / 2) - (height / 2);

        //window.open(oauthURL, 'oAuth', 'height=' + height + ',width=' + width + ',left=' + left + ',top=' + top);
    },
    handleOAuthComplete : function(component, event, helper){
        var state = event.getParam('data');
        if(state === 'fromSalesforce'){
            component.set('v.inboundAuthed', true);
        }
    },
    validate : function(component, event, helper){
        return new Promise($A.getCallback(function(resolve, reject) {

            if(component.get('v.inboundAuthed')){
                resolve();
            }else{
                helper.showToast(component, {
                    message: 'Account not authorized. Please complete authorization before proceeding.',
                    type: 'error'
                });
                reject();
            }
        }));
    }
})