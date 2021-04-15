({
    init: function(component, event, helper) {
        var action = component.get('c.getData');

        action.setCallback(this, function(res) {
            if ('SUCCESS' == res.getState()) {
                var parsedRes = JSON.parse(res.getReturnValue());
                if (parsedRes.isSuccess) {
                    component.set('v._data', parsedRes.results.data);
                    helper.build(component);
                    helper.navigateToLanding(component);
                } else {
                    helper.renderToast(component, {
                        message: parsedRes.errMsg,
                        type: 'error',
                        mode: 'sticky'
                    });
                }
            } else {
                helper.renderToast(component, {
                    message: res.getError()[0].message,
                    type: 'error',
                    mode: 'sticky'
                });
            }

            component.set('v.loading', false);
        });

        $A.enqueueAction(action);
    },

    /*** NAVIGATION ***/
    clickBack: function(component, event, helper) {
        component.set('v.loading', true);
        component.set('v.toast', null);

        var activeStep = component.get('v.activeStep');
        var steps = component.get('v.steps');

        helper.navigateToStep(component, steps[activeStep.stepIndex - 1]);

        component.set('v.loading', false);
    },
    clickCancel: function(component, event, helper) {
        var activeStep = component.get('v.activeStep');

        if (activeStep.isComplete) {
            helper.navigateToLanding(component);
        } else {
            var modal = component.find('modal');
            modal.show();
        }
    },
    clickNavigate: function(component, event, helper) {
        component.set('v.loading', true);
        component.set('v.toast', null);

        var sectionName = event.getParam('data');
		console.log('Section Name >>'+sectionName);
        var settings = component.get('v._data');
        var steps = component.get('v.steps');
        var stepIndex;

        if (null == sectionName) {
            stepIndex = settings.Steps_Completed__c;
        } else {
            component.get('v.sections').forEach(function(section) {
                if (section.name == sectionName) {
                    if ('started' == section.status) {
                        stepIndex = settings.Steps_Completed__c;
                    } else {
                        stepIndex = section.initStepIndex;
                    }
                }
            })
        }

        if (stepIndex >= steps.length) {
            helper.navigateToLanding(component);
        } else {
            helper.navigateToStep(component, steps[stepIndex]);
        }

        component.set('v.loading', false);
    },
    clickNext: function(component, event, helper) {
        component.set('v.loading', true);
        component.set('v.toast', null);

        var activeStep = component.get('v.activeStep');

        activeStep.component.validate().then($A.getCallback(function() {
            return helper.save(component).then($A.getCallback(function() {
                var activeStep = component.get('v.activeStep');

                if (activeStep.isLastStep) {
                    helper.navigateToComplete(component, activeStep.sectionIndex);
                } else {
                    var steps = component.get('v.steps');

                    helper.navigateToStep(component, steps[activeStep.stepIndex + 1]);
                }

                component.set('v.loading', false);
            }));
        })).catch($A.getCallback(function(error) {
            component.set('v.loading', false);
        }));
    },
    /*** /NAVIGATION ***/

    /*** MODAL ***/
    clickCancelModal: function(component, event, helper) {
        var modal = component.find('modal');
        modal.hide();
    },
    clickExitModal: function(component, event, helper) {
        var modal = component.find('modal');
        modal.hide();
        helper.navigateToLanding(component);
    },
    /*** /MODAL ***/

    /*** TOAST ***/
    hideToast: function(component, event, helper) {
        component.set('v.toast', null);
    },
    showToast: function(component, event, helper) {
        helper.renderToast(component, event.getParam('data'), helper);
    }
    /*** /TOAST ***/
})