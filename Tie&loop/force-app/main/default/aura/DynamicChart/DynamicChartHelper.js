({
    doInit : function(component, event, helper)
    {
        /*var action = component.get("c.getGiftsJSON");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var dataObj= response.getReturnValue();
                console.log('dataObj===='+dataObj);
                component.set("v.data",dataObj);
                console.log('diInIt method'+JSON.stringify(component.get("v.data")));
                helper.piechart(component,event,helper);     
            }
        });
        $A.enqueueAction(action);*/
        helper.piechart(component,event,helper);
    },
    
    /*getGiftListByMember : function(component, event, helper){
        var selectedMember= component.find('member').get('v.value');
        var action = component.get('c.getGiftsJSON');
        var recId=  component.get("v.recordId");
        
        action.setParams({
            "fMember":selectedMember,
            "campaignId":recId
        });
        
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var response = a.getReturnValue();
                
                if(response !== undefined && response.length > 0){
                    component.set("v.data",response);
                    helper.piechart(component,event,helper);
                } else{
                 	component.set("v.data",null);  
                	helper.piechart(component,event,helper);   
                }
            }
        });
        $A.enqueueAction(action);
        
    },*/
    
    piechart : function(component,event,helper) {
        var jsonData = component.get("v.data");
        var dataObj = JSON.parse(jsonData);
        
        new Highcharts.Chart({
            chart: {
                plotBackgroundColor: null,
                plotBorderWidth: null,
                plotShadow: false,
                renderTo: component.find("chart").getElement(),
                type: 'pie'
            },
            title: {
                text: component.get("v.chartTitle")
            },
            //subtitle: {
            //    text: component.get("v.chartSubTitle")
            //},
            xAxis: {
                categories: component.get("v.xAxisCategories"),
                crosshair: true
            },
            yAxis: {
                min: 0,
                title:{text: component.get("v.yAxisParameter")}
            },
            tooltip: {
                pointFormat: '{series.name}: <b>{point.y}</b>'
            },
            plotOptions: {
                pie: {
                    allowPointSelect: true,
                    cursor: 'pointer',
                    dataLabels: {
                        enabled: true,
                        format: '<b>{point.name}</b>: {point.y} ',
                        style: {
                            color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
                        }
                    }
                }
            },
            series: [{name:'StageName',data:dataObj}]
        });
        
    }
})