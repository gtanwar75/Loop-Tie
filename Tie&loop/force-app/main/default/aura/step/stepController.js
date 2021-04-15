({
    hide: function(component, event, helper) {
        component.set('v.hidden', true);
    },
    show: function(component, event, helper) {
        component.set('v.hidden', false);
    },
    validate: function(component, event, helper) {
        return new Promise($A.getCallback(function(resolve, reject) {
            var requireds = component.find('required');
            var errors = [];
            var valid = true;

            if (!$A.util.isEmpty(requireds)) {
                if (!Array.isArray(requireds)) {
                    requireds = new Array(requireds);
                }

                requireds.forEach(function(required) {
                    if ('function' == typeof(required.showHelpMessageIfInvalid)) {
                        required.showHelpMessageIfInvalid();
                        valid = valid && required.get('v.validity').valid;
                    }
                });
            }

            if (valid) {
                resolve();
            } else {
                reject(component.get('v.invalidFormMessage'));
            }
        }));
    }
})