/*
Strike by Appiphony

Version: 0.10.0
Website: http://www.lightningstrike.io
GitHub: https://github.com/appiphony/Strike-Components
License: BSD 3-Clause License
*/
({
    checkIfInitialized: function(component, event, helper) {
        
        var initCallsRunning = component.get('v.initCallsRunning');
        
        if (--initCallsRunning < 0) {
            initCallsRunning = 0;
        }
        
        component.set('v.initCallsRunning', initCallsRunning);
    },
    closeMenu: function(component, event, helper) {
        component.set('v.focusIndex', null);
        component.set('v.openMenu', false);
    },
    getParams: function(component, event, helper, filterIds) {
        var object = component.get('v.object');
        var objectCampaign = component.get('v.objectCampaign');
        var value = component.get('v.value')
        var emailOpt = component.get("v.emailOpt");
        
        var selectedIds = [];
        if(!$A.util.isEmpty(value)){
            value.split(';').forEach(function(splitVal){
                selectedIds.push('\'' + splitVal + '\'')
            })
        }
        return {
            object: object,
            objectCampaign: objectCampaign,
            ids: selectedIds.join(','),
            emailopt:emailOpt
        };
    },
    getRecordByValue: function(component, event, helper) {
        var value = component.get('v.value');
        if (!value) {
            helper.checkIfInitialized(component, event, helper);
            return;
        }
        
        var getRecordsAction = component.get('c.getRecords');
        var params = helper.getParams(component, event, helper, false);
        console.log('params@@' +params);
       //debugger;
        getRecordsAction.setParams({
            jsonString: JSON.stringify(params),
            isSearch: false,
        });
        
        getRecordsAction.setCallback(this, function(res) {
            if (res.getState() === 'SUCCESS') {
                var returnValue = JSON.parse(res.getReturnValue());
                
                if (returnValue.isSuccess) {
                    //var allTiles = component.get('v.allOptionTiles');
                    var allTiles = new Array();
                    returnValue.results.data.forEach(function(record) {
                        var tile = {
                            title: record.label,
                            subtitle: record.sublabel,
                            value: record.value
                        }
                        
                        allTiles.push(tile);
                    });
                    component.set('v.allOptionTiles', allTiles);
                    component.set('v.mainOptionTiles', allTiles);
                    component.set('v.selectedOptionTiles', allTiles.slice(0, component.get('v.visibleTiles')));
                    component.set('v.internalValue', value);
                }
            }
            
            helper.checkIfInitialized(component, event, helper);
        });
        
        $A.enqueueAction(getRecordsAction);
    },
    getRecordsBySearchTerm: function(component, event, helper) {
        var searchTerm = component.find('lookupInput').getElement().value;
        
        var lastSearchTerm = component.get('v.lastSearchTerm');
        var searchTimeout = component.get('v.searchTimeout');
        var showRecentRecords = component.get('v.showRecentRecords');
        clearTimeout(searchTimeout);
        if ($A.util.isEmpty(searchTerm)) {
            if (showRecentRecords) {
                helper.setRecords(component, event, helper, component.get('v.recentRecords'));
            } else {
                helper.setRecords(component, event, helper, []);
            }
            
            return;
        } else if (searchTerm === lastSearchTerm) {
            component.set('v.searching', false);
            helper.openMenu(component, event, helper);
            return;
        }
        
        component.set('v.searching', true);
        
        component.set('v.searchTimeout', setTimeout($A.getCallback(function() {
            if (!component.isValid()) {
                return;
            }
            
            var getRecordsAction = component.get('c.getRecords');
            var params = helper.getParams(component, event, helper, true);
            
            params.searchTerm = component.find('lookupInput').getElement().value;
            getRecordsAction.setParams({
                jsonString: JSON.stringify(params),
                isSearch: true
            });
            
            getRecordsAction.setCallback(this, function(res) {
                if (res.getState() === 'SUCCESS') {
                    var returnValue = JSON.parse(res.getReturnValue());
                    if (returnValue.isSuccess && returnValue.results.searchTerm === component.find('lookupInput').getElement().value) {
                        var returnedRecords = [];
                        
                        returnValue.results.data.forEach(function(record) {
                            returnedRecords.push({
                                label: record.label,
                                sublabel: record.sublabel,
                                value: record.value
                            });
                        });
                        helper.setRecords(component, event, helper, returnedRecords);
                    }
                } else {
                    helper.setRecords(component, event, helper, []);
                }
            });
            
            $A.enqueueAction(getRecordsAction);
        }), 200));
    },
    setRecords: function(component, event, helper, returnedRecords) {
        component.set('v.focusIndex', null);
        component.set('v.lastSearchTerm', component.find('lookupInput').getElement().value);
        component.set('v.records', returnedRecords);
        component.set('v.searching', false);
        
        helper.openMenu(component, event, helper);
    },
    openMenu: function(component, event, helper) {
        var showRecentRecords = component.get('v.showRecentRecords') && !$A.util.isEmpty(component.get('v.recentRecords'));
        component.set('v.openMenu', !component.get('v.disabled') && (!$A.util.isEmpty(component.get('v.lastSearchTerm')) || showRecentRecords));
    },
    closeMobileLookup: function(component, event, helper) {
        $A.util.removeClass(component.find('lookup'), 'sl-lookup--open');
        component.find('lookupInput').getElement().value = ''
    },
    updateValueByFocusIndex: function(component, event, helper) {
        var focusIndex = component.get('v.focusIndex');
        
        if (focusIndex == null) {
            focusIndex = 0;
        }
        var records = component.get('v.records');
        if (focusIndex < records.length) {
            var tile = {
                title: records[focusIndex].label,
                subtitle: records[focusIndex].sublabel,
                value: records[focusIndex].value
            }
            
            var tiles = component.get('v.selectedOptionTiles');
            var allTiles = component.get('v.allOptionTiles');
            component.set('v.allOptionTiles', [tile].concat(allTiles))
            component.set('v.selectedOptionTiles', [tile].concat(tiles.splice(0, component.get('v.visibleTiles') - 1)));
            
            var internalValue = component.get('v.internalValue');
            
            if($A.util.isEmpty(internalValue)){
                internalValue = records[focusIndex].value;
            } else {
                internalValue += ';' + records[focusIndex].value;
            }
            component.set('v.internalValue', internalValue);
            component.set('v.value', internalValue);
            component.find('lookupInput').getElement().value = '';
            component.set('v.records',[]);
            component.set('v.lastSearchTerm', '');
            
            helper.closeMenu(component, event, helper);
        } else if (focusIndex === records.length) {
            helper.addNewRecord(component, event, helper);
        }
        
        helper.closeMobileLookup(component, event, helper);
    },
    addNewRecord: function(component, event, helper) {
        if (!component.get('v.allowNewRecords')) {
            return;
        }
        
        var addRecordEvent;
        var overrideNewEvent = component.get('v.overrideNewEvent');
        
        if (overrideNewEvent) {
            addRecordEvent = component.getEvent('strike_evt_addNewRecord');
        } else {
            addRecordEvent = $A.get('e.force:createRecord');
            
            addRecordEvent.setParams({
                entityApiName: component.get('v.object')
            });
        }
        addRecordEvent.fire();
        
        helper.closeMenu(component, event, helper);
    },
    moveRecordFocusUp: function(component, event, helper) {
        var openMenu = component.get('v.openMenu');
        
        if (openMenu) {
            var focusIndex = component.get('v.focusIndex');
            var options = component.find('lookupMenu').getElement().getElementsByTagName('li');
            
            if (focusIndex === null || focusIndex === 0) {
                focusIndex = options.length - 1;
            } else {
                --focusIndex;
            }
            
            component.set('v.focusIndex', focusIndex);
        }
    },
    moveRecordFocusDown: function(component, event, helper) {
        var openMenu = component.get('v.openMenu');
        
        if (openMenu) {
            var focusIndex = component.get('v.focusIndex');
            var options = component.find('lookupMenu').getElement().getElementsByTagName('li');
            
            if (focusIndex === null || focusIndex === options.length - 1) {
                focusIndex = 0;
            } else {
                ++focusIndex;
            }
            
            component.set('v.focusIndex', focusIndex);
        }
    },
    removeOptionTile: function(component, event, sourceCmpIndex) {
        var currentOptionTiles = component.get('v.selectedOptionTiles');
        var allOptionTiles = component.get('v.allOptionTiles')
        var visibleTiles = component.get('v.visibleTiles')
        
        if(sourceCmpIndex < visibleTiles){
            currentOptionTiles.splice(sourceCmpIndex, 1);
        }
        
        allOptionTiles.splice(sourceCmpIndex, 1);
        
        if(currentOptionTiles.length < visibleTiles && allOptionTiles.length > currentOptionTiles.length){
            currentOptionTiles.push(allOptionTiles[visibleTiles - 1])
        }
        component.set('v.allOptionTiles', allOptionTiles);
        component.set('v.selectedOptionTiles', currentOptionTiles);
    },
    removeFromComponentValue: function(component, event, sourceCmpValue) {
        
        var parentCmpValue = component.get('v.internalValue');
        
        
        var valueArray = parentCmpValue.split(';');
        
        var valueIndex = valueArray.indexOf(sourceCmpValue);
        
        valueArray.splice(valueIndex, 1);
        
        var newValue = valueArray.join(';');
        component.set('v.internalValue', newValue);
        component.set('v.value', newValue);
    }
})
/*
Copyright 2017 Appiphony, LLC

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the 
following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following 
disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following 
disclaimer in the documentation and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote 
products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/