/*
Strike by Appiphony

Version: 1.0.0
Website: http://www.lightningstrike.io
GitHub: https://github.com/appiphony/Strike-Components
License: BSD 3-Clause License
*/
({
    destroyTile: function (component, event, helper) {
        var isNotStrikeDemo = component.getElement().parentElement.classList[0] !== 'strikeDemoOnly';
        if(!component.get("v.deleteModal")){
            if (component.get('v.destroyable') && isNotStrikeDemo) {
                helper.notifyParent(component);
                helper.destroyComponent(component);
            }
        }
        else{
            if(component.get("v.ignoreDialog")){
                if (component.get('v.destroyable')) {
                    helper.removeRecipient(component, event, helper);
                } 
            }else{
                component.set("v.openDeletePopup", true);
            }
        }
        
        
    },
    openModel: function(component, event, helper) {
        component.set("v.openDeletePopup", true);
    },
    
    closeModel: function(component, event, helper) { 
        component.set("v.openDeletePopup", false);
    },
    
    getDeletePopUp:function(component,event,helper){
        var getCheckboxValue =  component.find("checkbox").get('v.value');
        if(getCheckboxValue){
            component.set("v.ignoreDialog",true);
        }else{
            component.set("v.ignoreDialog",false);
        }
    },
    
    removeRecipient: function(component, event, helper) {        
        helper.removeRecipient(component, event, helper);
    },
    
    HandleDataMissingChange: function(cmp, evt) {
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