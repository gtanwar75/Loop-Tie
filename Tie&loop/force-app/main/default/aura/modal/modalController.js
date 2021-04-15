({
    hide: function(component, event, helper) {
        component.set('v.hidden', true);
    },
    show: function(component, event, helper) {
        component.set('v.hidden', false);
    }
})