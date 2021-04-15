({
    hide: function(component, event, helper) {
        component.set('v.hidden', true);
    },
    show: function(component, event, helper) {
        helper.update(component);

        component.set('v.hidden', false);
    },
    clickStart: function(component, event, helper) {
        console.log('Click Start');
        component.getEvent('onNavigateClick').fire();
    },
    clickSection: function(component, event, helper) {
        component.getEvent('onNavigateClick').setParams({
            'data': event.getSource().get('v.value')
        }).fire();
    }
})