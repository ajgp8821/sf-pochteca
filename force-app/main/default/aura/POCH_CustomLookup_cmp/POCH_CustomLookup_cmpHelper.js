({
  searchHelper : function(component,event,getInputkeyWord) {
    var foo = [];
    component.set("v.listOfSearchRecords", foo);
    if (component.get("v.indVentaM") == true ){
      var action2 = component.get("c.fetchLookUpValuesFromVentasMostrador");
      
      action2.setParams({
        'searchKeyWord': getInputkeyWord,
        'ObjectName' : component.get("v.objectAPIName"),
        'parentId' : component.get("v.parentId"),
        'organizacionVenta': component.get("v.organizacionVentas")
      });
      action2.setCallback(this, function(response) {
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
      $A.enqueueAction(action2);
    }
    else {
      var action = component.get("c.fetchLookUpValues");

      action.setParams({
        'searchKeyWord': getInputkeyWord,
        'ObjectName' : component.get("v.objectAPIName"),
        'parentId' : component.get("v.parentId")
      });
      action.setCallback(this, function(response) {
        //A.util.removeClass(component.find("mySpinner"), "slds-show"); //ocasiona error
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
      $A.enqueueAction(action);
    }
	},
})