({
    init : function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'UnitPrice', fieldName: 'UnitPrice', type: 'text'},
            {label: 'Grupo de Materiales', fieldName: 'Grupo_de_Materiales__c', type: 'text'},
            {label: 'Descripción', fieldName: 'ProductDescription', type: 'text'},
            {label: 'Moneda', fieldName: 'CurrencyIsoCode', type: 'text'},
            {label: 'Producto', fieldName: 'ProductProductCode', type: 'text'},
            {label: 'Name', fieldName: 'ProductName', type: 'text'},
            
        ]);
            var styl = "background-color:green;text-align:center;color:red;font-weight:bold;height:" + component.get("v.height") + "px;width:" + component.get("v.width") + "px;";
            //UnitPrice,Grupo_de_Materiales__c, Product2Id,ProductCode,Name,CurrencyIsoCode,Product2.ProductCode,Product2.Name
            var action = component.get("c.fetchPreciEntry");
            var recordId = component.get('v.recordId');
            alert(recordId);
            action.setParams({recordId: component.get('v.recordId')}); 
            
            action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
           // console.log(response.getReturnValue());
            component.set("v.data", response.getReturnValue());
            component.set("v.filteredData", response.getReturnValue());
            
           
}
 else if (state === "ERROR") {
    var errors = response.getError();
    if (errors) {
        if (errors[0] && errors[0].message) {
            console.log("Error message: " + 
                        errors[0].message);
        }
    } 
    else {
        console.log("Unknown Error");
    }
}
});
$A.enqueueAction(action);
},
    
    handleRowAction : function(component, event, helper){
        var selRows = event.getParam('selectedRows');
        component.set("v.delIds",selRows);
    },
        
        doAddProd : function(component, event, helper){
            var delIdList = component.get("v.delIds");
            var action = component.get('c.addProductos');
            action.setParams({lstId : delIdList});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    $A.get('e.force:refreshView').fire();
                    alert('Successfully Deleted');   
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } 
                    else {
                        console.log("Unknown Error");
                    }
                }
            });
            $A.enqueueAction(action);
        },
            searchTable : function(cmp,event,helper) {
                var allRecords = cmp.get("v.data");
                var searchFilter = event.getSource().get("v.value").toUpperCase();
                console.log('allRecords'+allRecords);

                var tempArray = [];
                var i;
                //    //UnitPrice,Grupo_de_Materiales__c, Product2Id,ProductCode,Name,CurrencyIsoCode,Product2.ProductCode,Product2.Name
                for(i=0; i < allRecords.length; i++){
                    if((allRecords[i].UnitPrice && allRecords[i].UnitPrice.toUpperCase().indexOf(searchFilter) != -1)  )
                    {
                        tempArray.push(allRecords[i]);
                    }
                }
               // cmp.set("v.filteredData",tempArray);
            }


})