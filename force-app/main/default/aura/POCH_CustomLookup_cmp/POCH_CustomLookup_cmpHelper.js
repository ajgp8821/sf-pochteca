({
  searchHelper : function(component,event,getInputkeyWord) {
    if (component.get("v.indVentaM") == true ){
      var action = component.get("c.fetchLookUpValuesFromVentasMostrador");
      
      action.setParams({
        'searchKeyWord': getInputkeyWord,
        'ObjectName' : component.get("v.objectAPIName"),
        'parentId' : component.get("v.parentId"),
        'organizacionVenta': component.get("v.organizacionVentas")
      });
      action.setCallback(this, function(response) {
        $A.util.removeClass(component.find("mySpinner"), "slds-show");
        var state = response.getState();
        if (state === "SUCCESS") {
          var storeResponse = response.getReturnValue();
          if (storeResponse.length > 0) {
            component.set("v.Message", '');
            console.log('REPSUESTA');
            console.log(storeResponse);
            component.set("v.listOfSearchRecords", storeResponse);                      
          } else {
            component.set("v.Message", 'No Hay Resultados...');
          }
          // set searchResult list with return value from server.
        }
      });
      // enqueue the Action
      $A.enqueueAction(action);
    }
    else {
      var action = component.get("c.fetchLookUpValues");

      action.setParams({
        'searchKeyWord': getInputkeyWord,
        'ObjectName' : component.get("v.objectAPIName"),
        'parentId' : component.get("v.parentId")
      });
      action.setCallback(this, function(response) {
        A.util.removeClass(component.find("mySpinner"), "slds-show");
        var state = response.getState();
        if (state === "SUCCESS") {
          var storeResponse = response.getReturnValue();
          if (storeResponse.length > 0) {
            component.set("v.Message", '');
            console.log('REPSUESTA');
            console.log(storeResponse);
            component.set("v.listOfSearchRecords", storeResponse);                      
          } else {
            component.set("v.Message", 'No Hay Resultados...');
          }
          
          // set searchResult list with return value from server.     
        }
      });
      // enqueue the Action
      $A.enqueueAction(action);
    }
	},
})