({
    hideToast: function(component) {
        var event = component.getEvent('hideToast');

        event.fire();
    },
    showToast: function(component, params) {
        var event = component.getEvent('showToast');
        event.setParams({
            data: params
        });
        event.fire();
    }
})