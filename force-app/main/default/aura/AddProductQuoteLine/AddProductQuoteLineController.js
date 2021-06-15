({
    scriptsLoaded : function(component, event, helper) {
        console.log('Script loaded..'); 
           var timesToCheck = 10;
            var poll = function () {
      			setTimeout(function () {
                    timesToCheck--;
                    if (typeof $ !== 'undefined') {
                        console.log($);
                    } else if (timesToCheck > 0) {
                        poll();
                    } else {
                        console.log('giving up')
        			}
      			}, 1000);
    		};
    
    		poll();
    },
    
    doInit : function(component,event,helper){
        //call apex class method
        var action = component.get('c.fetchPreciEntry');
        var recordId = component.get('v.recordId');
        //alert(recordId);
        action.setParams({recordId: component.get('v.recordId')}); 
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //set response value in lstOpp attribute on component.
                  var selIlstOpp = [];
                component.set('v.lstOpp', response.getReturnValue());
                 selIlstOpp = component.get("v.lstOpp");
                if(selIlstOpp.length ==''){ helper.showToast(component, "Error", "Posible cotización Con Estatus diferente (Abierta) o la fecha caduco", "error");   
                    //let button = event.getSource();
                   //button.set('v.disabled',true);
                                        
                                          }else{
              //  console.log('pruba'+response.getReturnValue());
                // when response successfully return from server then apply jQuery dataTable after 500 milisecond
                window.setTimeout(function(){ 
                    $('#tableId').DataTable();
                    // add lightning class to search filter field with some bottom margin..  
                    $('div.dataTables_filter input').addClass('slds-input');
                    $('div.dataTables_filter input').css("marginBottom", "10px");
                }, 1000); 
              }
            }
        });
        $A.enqueueAction(action); 
    },
    //Process the selected contacts
    handleSelectedProducts: function(component, event, helper) {
        var selectedContacts = [];
        var checkvalue = component.find("checkAddProducto");
         event.getSource().set("v.disabled", true);
      
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                selectedContacts.push(checkvalue.get("v.text"));
            }
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    selectedContacts.push(checkvalue[i].get("v.text"));
                }
            }
        }
        component.set("v.selIds",selectedContacts);
        console.log('selectedContacts-' + selectedContacts);
        var selIdList = [];
        selIdList = component.get("v.selIds");
        console.log('selIdList-' + selIdList);
        var recordId = component.get('v.recordId');
       // alert(recordId);
        
        var action = component.get('c.addProductos');
        action.setParams({lstId : selIdList,recordId : recordId});
         
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 
               const data = response.getReturnValue();
                if (data.status == 'OK'){
                    helper.showToast(component, "Success", "Ingreso de partidas Satisfactoriamente Creado", "success");
                    $A.get('e.force:refreshView').fire();  
                }else{
                    helper.showToast(cmp, "Error", data.msg, "error");
                }
                  $A.get("e.force:closeQuickAction").fire();
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
        if(selIdList.length ==''){   helper.showToast(component, "Error", "Debe Seleccionar al menos un Item por favor", "error");}else{
          
         $A.enqueueAction(action);}
     
      },
    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    }
})