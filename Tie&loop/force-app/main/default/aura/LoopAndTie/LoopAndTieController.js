({
    init : function(component, event, helper){

    },
   /* render : function(component, event, helper){
        var cdataContainers = component.find('cdataContainer')
        console.log('in render '+ cdataContainers)
        if(!Array.isArray(cdataContainers) && !$A.util.isEmpty(cdataContainers)){
             cdataContainers = [cdataContainers]
        }
        if(!$A.util.isEmpty(cdataContainers)){
            cdataContainers.forEach(function(container){
                if(container){
                    if(container.getElement()){
                        var value = container.getElement().innerText
                        value = value.replace('<![CDATA[', '').replace(']]>', '')
                        container.getElement().innerHTML = value
                    }
                }
            })
        }
     },*/
    handleSendGiftClick : function(component, event, helper){
        var namespace = component.getType().split(':')[0];
        var namespaceAPI = namespace == 'c' ? '' : namespace + '__';
        var navEvt = $A.get('e.force:navigateToURL')
        
            navEvt.setParams({
            url: "/apex/" + namespaceAPI + "sendGift_Page?id=" + component.get('v.recordId')
         })
            
        navEvt.fire()
    }
})