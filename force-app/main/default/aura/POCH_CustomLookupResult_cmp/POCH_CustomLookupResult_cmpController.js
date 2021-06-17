({
   doInit : function(component, event, helper){  
      var getSelectIconName = component.get("v.IconName");

      if(getSelectIconName == 'standard:avatar'){ //Nombre de la imagen se toma como referencia para la pàrte de sucursales
         var getSelectRecord = component.get("v.oRecord.Poch_Sucursal__r.Name");
         component.set("v.oRecord.Name", getSelectRecord);   
      }
      
   },
   selectRecord : function(component, event, helper){    
      var getSelectRecord = component.get("v.oRecord");
      var getSelectIconName = component.get("v.IconName");
      var isVentaMostrador = component.get("v.indVentaM");
      var compEvent = component.getEvent("oSelectedRecordEvent");
      if (isVentaMostrador){
         var compEventProductDetail = component.getEvent("AddProductLookupDetail2");
      } else {
         var compEventProductDetail = component.getEvent("AddProductLookupDetail");
      }
      
      
      // para lookup de Sucursales
      compEvent.setParams({"recordByEvent" : getSelectRecord });  

      // para lookup de products
      if(getSelectIconName == 'standard:product'){
         compEventProductDetail.setParams({"recordByEvent" : getSelectRecord });  
         console.log('REGISTRO SELECCIONADO');
         console.log(getSelectRecord);
         compEventProductDetail.fire();
      }
      compEvent.fire();          
   
   }
})