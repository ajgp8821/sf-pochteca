/***************************************************************************************************************
Name:        POCH_OpportunityTriggerService.cls
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 18-09-2019
Project:	 Pochteca
Update for: Jesús Azuaje Zaga
UpdateDate: 16/03/2021 - JIRA RN-6503 y RN-6501 
Description: Opportunity Trigger Service Class, Se ajusta meotodo updateOppStage y setSucursalAndPricebook para identificar hojas de inventario y actualizar SPANCOP 
Version: 1.1
***************************************************************************************************************/

public class POCH_OpportunityTriggerService {

    public static Boolean isInvokedByTrigger = false;
    
/******************************** AFTER INSERT ******************************/    
    
    public static void validateAccountWithOpp(List<Opportunity> lOpportunity) {
        Set<Id> setOpps = new Set<Id>();
        for(Opportunity op : lOpportunity) {
            if(op.POCH_IsMonthly__c == FALSE) { setOpps.add(op.Id); }       	    
        }             
        if(!setOpps.isEmpty())
			updateOppStage(setOpps);        
    }
    
    @future
    public static void updateOppStage(set<Id> setOpps) {
        Integer i = 0;
        List<POCH_HojaInventario__c> listHojaInventario = new List<POCH_HojaInventario__c>();
        List<Opportunity> lOppUpd = new List<Opportunity>();
        for(Opportunity op : [SELECT Id,Account.POCH_TipoRegistro__c,StageName,POCH_ValidarCredito__c, POCH_Sucursal__c, AccountId, Estado_temporal__c FROM Opportunity WHERE Id IN : setOpps]) {
            if(op.Account.POCH_TipoRegistro__c == 'Cliente') {
                if(!op.POCH_ValidarCredito__c) {
                    for (POCH_HojaInventario__c listHojaInventarioAux : [SELECT Id FROM POCH_HojaInventario__c WHERE POCH_Cuenta__c =: op.AccountId AND POCH_Sucursal__c =: op.POCH_Sucursal__c]){
                    	i++;    
                    }
                    
                    if(i > 0){
                    	op.StageName = 'Análisis';    
                    }else{
                        op.StageName = 'Prospecto';
                    }
                    
                } else {
                    op.StageName = 'Prospecto';
                }
            } else { 
                op.StageName = 'Sospechoso'; 
            }
            lOppUpd.add(op);
        }
        
        try {
            isInvokedByTrigger = true;
            update lOppUpd;
            
            List<Opportunity> lOppUpd2 = new List<Opportunity>();
            for(Opportunity op : [SELECT Id, Estado_temporal__c FROM Opportunity WHERE Id IN : setOpps]) {
                op.Estado_temporal__c = true;
                lOppUpd2.add(op);
            }
            update lOppUpd2;
        } catch(DMLException e) { System.debug('ERROR: ' + e.getMessage()); } 
    }
    
/******************************** BEFORE UPDATE ******************************/     
    
    public static void setSucursalAndPricebook(List<Opportunity> lOpportunity) {
        Boolean exiteHojaSucursal = false;
        Id sucursalHojaInventario;
        if(isInvokedByTrigger) 
            return;            
        else isInvokedByTrigger = true;
        
        Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) Trigger.oldMap;
        
        
        Map<String,Pricebook2> mapSucursalPricebook = new Map<String,Pricebook2>();             
        Map<Id,List<String>>   mapUserOrgVentas     = new Map<Id,List<String>>();
        Set<Id>     setOwnerIds   = new Set<Id>();        
        Set<String> setSucursales = new Set<String>();
        
        Set<Id> accountIds = new Set<Id>();
        Map<Id,Set<Id>> mapAcc_sSuc      = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> mapAcc_setSucAmp = new Map<Id,Set<Id>>();
        
        for(Opportunity opp : lOpportunity) {
			            
            setOwnerIds.add(opp.OwnerId); 
            accountIds.add(opp.AccountId);
            sucursalHojaInventario = opp.POCH_Sucursal__c;
        }        
        //-----------------------------------------------
        //Se obtienen las sucursales ampliadas de los clientes         
        for(POCH_SucursalAmpliada__c sa : [SELECT Id,POCH_Cliente__c,POCH_Sucursal__c FROM POCH_SucursalAmpliada__c WHERE POCH_Cliente__c IN : accountIds]) {
            if(mapAcc_setSucAmp.containsKey(sa.POCH_Cliente__c))
               mapAcc_setSucAmp.get(sa.POCH_Cliente__c).add(sa.Poch_Sucursal__c);
            else mapAcc_setSucAmp.put(sa.POCH_Cliente__c, new Set<Id>{sa.Poch_Sucursal__c}); 
        }
        //-----------------------------------------------
        //Se obtienen las sucursales por cada vendedor    
        for(User vendedor : [SELECT Id,POCH_OrganizacionesVentas__c FROM User WHERE Id IN : setOwnerIds]) {
            if(String.isNotBlank(vendedor.POCH_OrganizacionesVentas__c)) {
                List<String> lOrgVtas = new List<String>();
                for(String orgVtas : vendedor.POCH_OrganizacionesVentas__c.split(';')) {
                    if(orgVtas <> 'TODOS')
                        lOrgVtas.add(orgVtas);                    
                }
                mapUserOrgVentas.put(vendedor.Id, lOrgVtas);
            	setSucursales.addAll(lOrgVtas);    
            }                        
        }                 
        for(Pricebook2 pb : [SELECT Id,POCH_IdExterno__c,POCH_Sucursal__c FROM Pricebook2 WHERE POCH_IdExterno__c IN : setSucursales]) {
            mapSucursalPricebook.put(pb.POCH_IdExterno__c, pb);
        }
        //-----------------------------------------------
        //Se obtienen los datos de detalle de hoja de inventario
		for(POCH_DetalleInventario__c di : [SELECT POCH_HojaInventario__r.POCH_Cuenta__c,POCH_HojaInventario__r.POCH_Sucursal__c 
                                            FROM POCH_DetalleInventario__c WHERE POCH_HojaInventario__r.POCH_Cuenta__c IN : accountIds 
                                            AND POCH_HojaInventario__r.POCH_Sucursal__c != null]) 
        {
            if(di.POCH_HojaInventario__r.POCH_Sucursal__c == sucursalHojaInventario){
                exiteHojaSucursal = true;
            }
            if(mapAcc_sSuc.containsKey(di.POCH_HojaInventario__r.POCH_Cuenta__c))
            	mapAcc_sSuc.get(di.POCH_HojaInventario__r.POCH_Cuenta__c).add(di.POCH_HojaInventario__r.POCH_Sucursal__c); 
            else mapAcc_sSuc.put(di.POCH_HojaInventario__r.POCH_Cuenta__c, new Set<Id>{di.POCH_HojaInventario__r.POCH_Sucursal__c});                            
        }        
        //-------------------------------------------------
        //Se itera para realizar la asignación y/o validación de datos
        for(Opportunity spancop : lOpportunity) {  
            if (exiteHojaSucursal){
                spancop.POCH_MaterialHojaInventario__c = true;
            }
     
            if(spancop.Zona__c == 'SUDAMERICA' && spancop.StageName == 'Negociación' && spancop.Numero_de_factura__c != null){
				spancop.POCH_PedidoConvertidoFactura__c = true;
                spancop.POCH_CotizacionConvertidaPedido__c = true;
            }
            if(spancop.Zona__c == 'SUDAMERICA' && (spancop.StageName == 'Negociación' || spancop.StageName == 'Cerrado Facturado') && spancop.Fecha_de_pago__c != null){
				spancop.POCH_FacturaPagada__c = true;
            }
                if(String.isBlank(spancop.POCH_Sucursal__c) || String.isBlank(spancop.Pricebook2Id) 
               		|| (Trigger.isUpdate && spancop.POCH_Sucursal__c <> mapOldOpportunity.get(spancop.Id).POCH_Sucursal__c)) {
                        String error = '';                                 
                    if(!mapUserOrgVentas.isEmpty()) {
                        if(mapUserOrgVentas.get(spancop.OwnerId).size() == 1) {
                            spancop.POCH_Sucursal__c = mapSucursalPricebook.get(mapUserOrgVentas.get(spancop.OwnerId)[0]).POCH_Sucursal__c;
                            spancop.Pricebook2Id     = mapSucursalPricebook.get(mapUserOrgVentas.get(spancop.OwnerId)[0]).Id;
                        } else if(mapUserOrgVentas.get(spancop.OwnerId).size() > 1) {
                            if(String.isNotBlank(spancop.POCH_Sucursal__c)) {
                                String idPricebook = '';
                                for(String orgVtas : mapUserOrgVentas.get(spancop.OwnerId)) {
                                    if(orgVtas == spancop.POCH_SucursalId__c) {
                                        idPricebook = mapSucursalPricebook.get(orgVtas).Id;
                                        break;
                                    }
                                }
                                if(String.isNotBlank(idPricebook))
                                    spancop.Pricebook2Id = idPricebook;
                                else if(!spancop.POCH_OpportunityConversion__c) error = 'El usuario actual no tiene asignada la Org. de Ventas';                                
                            } else if(!spancop.POCH_OpportunityConversion__c) error = 'Por favor, asigne la sucursal (org. de ventas) al SPANCOP.';                                              
                    	}
                	} else if(!spancop.POCH_OpportunityConversion__c) error = 'Por favor, contacte al administrador para asignar una sucursal al usuario'; 
                
                if(String.isBlank(error)) {
                    if(mapAcc_setSucAmp.containsKey(spancop.AccountId)) {                       
                        if(String.isNotEmpty(spancop.POCH_Sucursal__c) && mapAcc_setSucAmp.get(spancop.AccountId).contains(spancop.POCH_Sucursal__c)) {
                            if(mapAcc_sSuc.containsKey(spancop.AccountId)) {
                                if(mapAcc_sSuc.get(spancop.AccountId).contains(spancop.POCH_Sucursal__c))
                                    spancop.POCH_MaterialHojaInventario__c = true;
                                else if(spancop.StageName == 'Análisis') error = 'El cliente no cuenta con Inventario de Cliente creado en la Org. de ventas'; 
                            } else if(spancop.StageName == 'Análisis') error = 'El cliente no cuenta con un Inventario de Cliente creado en la Org. de Ventas';      
                        } else if(String.isNotEmpty(spancop.POCH_Sucursal__c) && !spancop.POCH_OpportunityConversion__c) error = 'El cliente no se encuentra ampliado en la Org de Ventas';
                    }                                        
                }
				if(String.isNotBlank(error))                
                    spancop.addError(error);
                    }    
        }
    }

    
	/******************************** AFTER UPDATE ******************************/   
    public static void closeOppsQuotes(List<Opportunity> lOpportunity, Map<Id,Opportunity> oldOppMap) {
        Set<Id> lClosedOpps=new Set<Id>();
        for(Opportunity opp : lOpportunity) {
            if(opp.StageName == 'Cerrada Perdida' && oldOppMap.get(opp.Id).StageName != 'Cerrada Perdida' && opp.AutomaticallyCreated__c) {
                lClosedOpps.add(opp.Id);
            }
        } 
        List<SBQQ__Quote__c> qQuotes=new List<SBQQ__Quote__c>();
        if(lClosedOpps!=null) {
            if (lClosedOpps.size()>0) {
                qQuotes=[SELECT Id, POCH_EstatusCotizacion__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c IN :lClosedOpps];
            }
        }
        if (qQuotes!=null) {
            if (qQuotes.size()>0) {
                for (SBQQ__Quote__c q: qQuotes) {
                    q.POCH_EstatusCotizacion__c='Cancelada';
                    q.Motivos_de_Cancelaci_n__c='Oportunidad Cerrada';
                }
                try {
            		update qQuotes;
                } catch(DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
            }
        }
    }    
}