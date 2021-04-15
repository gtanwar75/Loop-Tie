({
    addOauthListener: function(component, helper) {
        window.addEventListener('message', $A.getCallback(function(event) {
            if(typeof event.data == 'object' && event.origin === 'https://loopandtie.secure.force.com') {
                var action = component.get('c.getToken');

                action.setParams({
                    code: event.data.code,
                    state: 'fromSalesforce'
                });
                action.setCallback(this, function(res) {
                    var parsedRes = JSON.parse(res.getReturnValue());
                    if (parsedRes.isSuccess) {
						component.set('v.inboundAuthed', parsedRes.isSuccess);
                    } else {
                        component.set('v.inboundAuthed', false);

                        helper.showToast(component, {
                            message: parsedRes.error,
                            type: 'error'
                        });
                    }

                });
                $A.enqueueAction(action);
            }
        }));
    }
})