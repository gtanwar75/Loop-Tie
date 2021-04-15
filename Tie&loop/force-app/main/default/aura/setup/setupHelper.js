({
    /*** INIT ***/
    build: function(component) {
        var settings = component.get('v._data');

        var sections = new Array();
        var steps = new Array();

        var completedSteps = settings.Steps_Completed__c;

        component.find('content').find({
            instancesOf: 'c:section'
        }).forEach(function(sectionComponent) {
            var sectionStatus;
            var sectionSteps = new Array();

            sectionComponent.find({
                instancesOf: 'c:step'
            }).forEach(function(stepComponent) {
                stepComponent = stepComponent.getConcreteComponent();

                stepComponent.set('v.data', component.getReference('v.data'));

                sectionSteps.push({
                    component: stepComponent,
                    sectionIndex: sections.length,
                    stepIndex: steps.length + sectionSteps.length,
                    isFirstStep: sectionSteps.length == 0,
                    isLastStep: false
                });
            });

            if (sectionSteps.length > 0) {
                // all steps in section completed
                if (steps.length + sectionSteps.length <= completedSteps) {
                    sectionStatus = 'completed';
                }
                // at least the first step has been started
                else if (steps.length + 1 <= completedSteps) {
                    sectionStatus = 'started';
                } else {
                    sectionStatus = '';
                }

                sections.push({
                    name: sectionComponent.get('v.name'),
                    description: sectionComponent.get('v.description'),
                    status: sectionStatus,
                    sectionIndex: sections.length,
                    initStepIndex: steps.length,
                    stepsLength: sectionSteps.length
                });

                sectionSteps[sectionSteps.length - 1].isLastStep = true;

                steps = steps.concat(sectionSteps);
            }
        });

        component.set('v.sections', sections);
        component.set('v.steps', steps);

    },
    /*** /INIT ***/

    /*** NAVIGATE ***/
    navigateToLanding: function(component) {
        this.navigateToStep(component, {
            component: component.find('landing')
        });
    },
    navigateToComplete: function(component, sectionIndex) {
        var activeStep = component.get('v.activeStep');
        var sections = component.get('v.sections');
        sections[sectionIndex].status = 'completed';

        component.set('v.sections', sections);

        this.navigateToStep(component, {
            component: component.find('complete'),
            sectionIndex: sectionIndex,
            stepIndex: activeStep.stepIndex + 1,
            isComplete: true
        });
    },
    navigateToStep: function(component, step) {
        var activeStep = component.get('v.activeStep');
        var sections = component.get('v.sections');
        var updateSections = false;

        if (null != activeStep) {
            activeStep.component.hide();

            if (null != activeStep.sectionIndex) {
                var section = sections[activeStep.sectionIndex];

                if ('completed' != section.status) {
                    section.status = 'started';
                    updateSections = true;
                }
            }
        }

        component.set('v.data', Object.assign({}, component.get('v._data')));
        console.log('Step ::'+step);
        if (null != step.sectionIndex) {
            var section = sections[step.sectionIndex];

            section.progress = Math.min(1, (step.stepIndex - section.initStepIndex) / (section.stepsLength - 1));
            updateSections = true;

            component.set('v.activeSection', section);
        } else {
            component.set('v.activeSection', null);
        }

        if (updateSections) {
            component.set('v.sections', sections);
        }

        component.set('v.activeStep', step);

        step.component.show();
    },
    /*** /NAVIGATE ***/

    /*** SAVE ***/
    save: function(component) {
        var activeStep = component.get('v.activeStep');
        var data = component.get('v.data');

        if (activeStep.stepIndex >= data.Steps_Completed__c) {
            data.Steps_Completed__c++;
        }

        return new Promise($A.getCallback(function(resolve, reject) {
            var action = component.get('c.saveData');

            action.setParams({
                data: JSON.stringify(data)
            });

            action.setCallback(this, function(res) {
                if ('SUCCESS' == res.getState()) {
                    var parsedRes = JSON.parse(res.getReturnValue());

                    if (parsedRes.isSuccess) {
                        component.set('v._data', parsedRes.results.data);
                        resolve()
                    } else {
                        helper.renderToast(component, {
                            message: parsedRes.error,
                            type: 'error'
                        });
                        reject();
                    }
                } else {
                    helper.renderToast(component, {
                        message: res.getError()[0].message,
                        type: 'error'
                    });
                    reject();
                }
            });

            $A.enqueueAction(action);
        }));
    },
    /*** /SAVE ***/

    /*** TOAST ***/
    renderToast: function(component, toast) {
        switch (toast.type) {
            case 'error':
                toast.iconName = 'utility:error';
                break;
            case 'warning':
                toast.iconName = 'utility:warning';
                break;
            case 'success':
                toast.iconName = 'utility:success';
                break;
            case 'info':
                toast.iconName = 'utility:info';
                break;
            default:
                toast.type = 'other';
                toast.iconName = toast.key;
        }

        component.set('v.toast', toast);

        if ('sticky' != toast.mode) {
            if ($A.util.isEmpty(toast.duration)) {
                toast.duration = 5000;
            }

            setTimeout($A.getCallback(function() {
                component.set('v.toast', null);
            }), toast.duration);
        }
    }
    /*** /TOAST ***/
})