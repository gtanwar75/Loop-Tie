/*
Strike by Appiphony

Version: 1.0.0
Website: http://www.lightningstrike.io
GitHub: https://github.com/appiphony/Strike-Components
License: BSD 3-Clause License
*/
({
    setHeight: function(component, event, helper) {
        var height = component.get('v.height');
        var size = component.get('v.size');

        if (size === 'small') {
            component.set('v.height', '56px');
        } else if (size === 'medium') {
            component.set('v.height', '72px');
        } else if (size === 'large') {
            component.set('v.height', '210px');
        } else {
            component.set('v.height', height);
        }
    },
    handleEmptyMaxLength: function(component, event, helper){
        if($A.util.isEmpty(component.get('v.maxlength'))){
            component.set('v.maxlength', undefined);
        } else {
            var maxlength = component.get('v.maxlength');
            
            component.set('v.maxlength', Math.abs(maxlength));
        }
    },
    disableInput: function(component, event, helper) {
        var inputEl = component.find('thisTextarea').getElement();
        if(!$A.util.isEmpty(inputEl)){
            inputEl.setAttribute('disabled', 'disabled');
        }
    },
    enableInput: function(component, event, helper) {
        var inputEl = component.find('thisTextarea').getElement();
        if(!$A.util.isEmpty(inputEl)){
            inputEl.removeAttribute('disabled');
        }
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