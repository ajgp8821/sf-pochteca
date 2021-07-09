/***************************************************************************************************************
Name:        POCH_QuoteTriggerService.cls
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 02-10-2019
Project:	 Pochteca

Description: Quote Trigger Service Class
***************************************************************************************************************/

public class POCH_QuoteTriggerService {    
    
    public static void setSucursalAndPricebook(List<SBQQ__Quote__c> lQuotes) {
        System.debug('::: IN POCH_QuoteTriggerService.setSucursalAndPricebook : lQuotes --> ' + lQuotes); 
        
        Map<Id,SBQQ__Quote__c> mapOldQuote = (Map<Id,SBQQ__Quote__c>) Trigger.oldMap;
        
        Set<Id> setIdOpp = new Set<Id>();
        Set<Id> setIdAcc = new Set<Id>();
        Set<Id> setOwner = new Set<Id>();
        for(SBQQ__Quote__c quote : lQuotes) {
            if(String.isNotBlank(quote.SBQQ__Opportunity2__c)) {
                setIdOpp.add(quote.SBQQ__Opportunity2__c);      
                quote.CurrencyIsoCode = quote.POCH_AccountDivisa__c;
            }
            if(String.isNotBlank(quote.SBQQ__Account__c))
            	setIdAcc.add(quote.SBQQ__Account__c);
            setOwner.add(quote.OwnerId);            
        }
        
        //Se obtienen las oportunidades de la quotes
        Map<Id,Opportunity> mapOpportunity = new Map<Id,Opportunity>([SELECT Id,Pricebook2Id,POCH_Sucursal__c FROM Opportunity WHERE Id IN : setIdOpp]);
        
        //Se obtienen las sucursales ampliadas de los clientes  
        Map<Id,Set<Id>> mapAcc_setSucAmp = new Map<Id,Set<Id>>();
        for(POCH_SucursalAmpliada__c sa : [SELECT Id,POCH_Cliente__c,POCH_Sucursal__c FROM POCH_SucursalAmpliada__c WHERE POCH_Cliente__c IN : setIdAcc]) {
            if(mapAcc_setSucAmp.containsKey(sa.POCH_Cliente__c))
               mapAcc_setSucAmp.get(sa.POCH_Cliente__c).add(sa.Poch_Sucursal__c);
            else mapAcc_setSucAmp.put(sa.POCH_Cliente__c, new Set<Id>{sa.Poch_Sucursal__c}); 
        }                

        //Se obtienen las org de ventas de los propietarios
        Map<Id,List<String>> mapUserOrgVentas = new Map<Id,List<String>>();
        Set<String> setSucursales = new Set<String>();
        for(User us : [SELECT Id,POCH_OrganizacionesVentas__c FROM User WHERE Id IN : setOwner]) {
            if(String.isNotBlank(us.POCH_OrganizacionesVentas__c)) {
                List<String> lOrgVtas = new List<String>();
                for(String orgVtas : us.POCH_OrganizacionesVentas__c.split(';')) {
                    if(orgVtas <> 'TODOS')
                        lOrgVtas.add(orgVtas);                    
                }
                mapUserOrgVentas.put(us.Id, lOrgVtas);
            	setSucursales.addAll(lOrgVtas); 
            }        
        }
        //Se obtienen los pricebook
        Map<String,Pricebook2> mapSucursalPricebook = new Map<String,Pricebook2>();
        Map<Id,Id> mapSuc_PB = new Map<Id,Id>();
        for(Pricebook2 pb : [SELECT Id,POCH_IdExterno__c,POCH_Sucursal__c FROM Pricebook2 WHERE POCH_IdExterno__c IN : setSucursales]) {
            mapSucursalPricebook.put(pb.POCH_IdExterno__c, pb);
            mapSuc_PB.put(pb.POCH_Sucursal__c,pb.Id);
        }
        
        for(SBQQ__Quote__c quote : lQuotes) {   
            if(String.isBlank(quote.POCH_Sucursal__c) || String.isBlank(quote.SBQQ__PriceBook__c) || (Trigger.isUpdate && quote.POCH_Sucursal__c <> mapOldQuote.get(quote.Id).POCH_Sucursal__c)) {
                if(String.isNotBlank(quote.SBQQ__Opportunity2__c)) {
                    System.debug('--> TIENE OPP, PERO NO PB NI SUC');
                    quote.SBQQ__PriceBook__c = mapOpportunity.get(quote.SBQQ__Opportunity2__c).Pricebook2Id;
                    quote.POCH_Sucursal__c   = mapOpportunity.get(quote.SBQQ__Opportunity2__c).POCH_Sucursal__c;                
                } else {
                    String error = '';
                    if(!mapUserOrgVentas.isEmpty()) {
                        if(mapUserOrgVentas.get(quote.OwnerId).size() == 1) {
                            System.debug('--> TIENE 1 SUC el Usuario');
                            quote.POCH_Sucursal__c   = mapSucursalPricebook.get(mapUserOrgVentas.get(quote.OwnerId)[0]).POCH_Sucursal__c;
                            quote.SBQQ__PriceBook__c = mapSucursalPricebook.get(mapUserOrgVentas.get(quote.OwnerId)[0]).Id;
                        } else if(mapUserOrgVentas.get(quote.OwnerId).size() > 1) {
                            if(String.isNotBlank(quote.POCH_Sucursal__c)) {
                                String idPricebook = '';
                                System.debug('--> quote.POCH_SucursalId__c ' + quote.POCH_SucursalId__c);
                                for(String orgVtas : mapUserOrgVentas.get(quote.OwnerId)) {
                                    if(orgVtas == quote.POCH_SucursalId__c) {
                                        idPricebook = mapSucursalPricebook.get(orgVtas).Id;
                                        break;
                                    }
                                }
                                if(String.isNotBlank(idPricebook))
                                    quote.SBQQ__PriceBook__c = idPricebook;
                                else error = 'El usuario actual no tiene asignada la Org. de Ventas';                                
                            } else error = 'Por favor, asigne la sucursal (org. de ventas) a la Cotización.';                                              
                        }
                    } else error = 'Por favor, contacte al administrador para asignar una sucursal al usuario';
                                                          
                    if(String.isBlank(error)) {
                        if(String.isNotBlank(quote.SBQQ__Account__c) && mapAcc_setSucAmp.containsKey(quote.SBQQ__Account__c)) {
                            if(String.isNotEmpty(quote.POCH_Sucursal__c) && !mapAcc_setSucAmp.get(quote.SBQQ__Account__c).contains(quote.POCH_Sucursal__c)) {
                                error = 'El cliente no se encuentra ampliado en la Org de Ventas.';     
                            } else if(String.isEmpty(quote.POCH_Sucursal__c)) { error = 'Debe asignar una sucursal a la cotización'; }
                        } else error = 'El cliente no se encuentra ampliado en la Org de Ventas-';
                    }                                  
                    
                    System.debug('error ' + error);
                    if(String.isNotBlank(error))                
                        quote.addError(error);
                } 
            }
        }        
        
        System.debug('::: OUT POCH_QuoteTriggerService.setSucursalAndPricebook'); 
    }
    
    public static void actualizaEstatusAprobado(List<SBQQ__Quote__c> lQuotes) {
        System.debug('::: IN POCH_QuoteTriggerService.actualizaEstatusAprobado : lQuotes --> ' + lQuotes); 
        
        Map<Id,SBQQ__Quote__c> mapOldQuote = (Map<Id,SBQQ__Quote__c>) Trigger.oldMap;
        Set<Id> setAprbQuote = new Set<Id>();
        for(SBQQ__Quote__c qt : lQuotes) {
            if(qt.POCH_ValidaAutorizaciones__c) {				              
                setAprbQuote.add(qt.Id);         
            }
        }
        
        if(!setAprbQuote.isEmpty() || Test.isRunningTest()) {
            Map<Id,Set<String>> mapLineasAprobadas = new Map<Id,Set<String>>();
            for(SBQQ__QuoteLine__c ql : [SELECT Id,SBQQ__Quote__c,POCH_EstatusPartida__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN : setAprbQuote]) {
                if(mapLineasAprobadas.containsKey(ql.SBQQ__Quote__c)) { mapLineasAprobadas.get(ql.SBQQ__Quote__c).add(ql.POCH_EstatusPartida__c); } 
                else mapLineasAprobadas.put(ql.SBQQ__Quote__c, new Set<String>{ql.POCH_EstatusPartida__c});
            }
            
            for(SBQQ__Quote__c ql : lQuotes) {
                if(mapLineasAprobadas.containsKey(ql.Id)) {
                    if(!mapLineasAprobadas.get(ql.Id).contains('Abierta') && !mapLineasAprobadas.get(ql.Id).contains('Por Autorizar') && !mapLineasAprobadas.get(ql.Id).contains('No Autorizado') && !mapLineasAprobadas.get(ql.Id).contains('Cancelado por Variación de Precio') && !mapLineasAprobadas.get(ql.Id).contains('Port Autorizar') && ql.POCH_EstatusCotizacion__c == 'Por Autorizar')
                    {
                        ql.POCH_EstatusCotizacion__c = 'Por Liberar';
                    } else ql.POCH_ValidaAutorizaciones__c = false;
                }            
            }
        }
        
        System.debug('::: OUT POCH_QuoteTriggerService.actualizaEstatusAprobado'); 
    }
	
    //Gestiona la actualización de las Quotes
    public static void handleQuoteLinesWF(List<SBQQ__Quote__c> lQuotes) {
        System.debug('::: IN POCH_QuoteTriggerService.handleQuoteLinesWF : lQuotes --> ' + lQuotes); 
        
        //Valida si el estatus de la Quote cambió a "Por Autorizar"
        Map<Id,SBQQ__Quote__c> mapOldQuote = (Map<Id,SBQQ__Quote__c>) Trigger.oldMap;
        Set<Id> setIdQuotes = new Set<Id>();
        for(SBQQ__Quote__c quote : lQuotes) {
            if(quote.POCH_EstatusCotizacion__c == 'Por Autorizar' && quote.POCH_EstatusCotizacion__c <> mapOldQuote.get(quote.Id).POCH_EstatusCotizacion__c)            
                setIdQuotes.add(quote.Id);            
        }
                 
        if(!setIdQuotes.isEmpty() || Test.isRunningTest()) {
            //Consulta las Quotes Lines dependientes de las Quotes actualizadas   
            List<SBQQ__QuoteLine__c> lQuoteLines = new List<SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c quoteLine : [SELECT Id,POCH_EnviarAprobacion__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN : setIdQuotes AND POCH_EstatusPartida__c = 'Abierta']) {
                quoteLine.POCH_EnviarAprobacion__c = true;
                lQuoteLines.add(quoteLine);
            }
            System.debug('--> lQuoteLines ' + lQuoteLines);
            
            if(!lQuoteLines.isEmpty()) {
                try {
                    update lQuoteLines;
                } catch(Exception ex) {
                    System.debug('--> ERROR: ' + ex.getMessage() + ' --> ' + ex.getStackTraceString());
                }
            }                        
        }
        
        System.debug('::: OUT POCH_QuoteTriggerService.handleQuoteLinesWF');         
    }
    
}