/****************************************************************************************************
General Information
-------------------
author:  Victor Jiménez
company: Freeway
Project: Pochteca
Description:  Trigger Handler class POCH_AutorizacionMovil__c to send Approval Request
-------------------------------------
Number    Dates             Author                       Description
------    -----------       --------------				 -----------
1.0       04-mar-2020       Victor Jiménez               Creation
****************************************************************************************************/

public class POCH_AutorizacionMovilHandler {    
    
    public static Boolean esInvocadoPorTrigger = false;
    
    public static void gestionaPedidosDuplicados(List<POCH_AutorizacionMovil__c> lPedidos, String evt) {
        System.debug('===> IN POCH_AutorizacionMovilHandler.gestionaPedidosDuplicados --> lPedidos ' + lPedidos.size() + ' ::: evt ' + evt);
        
        if(esInvocadoPorTrigger) { return; }
        
        Map<String,POCH_AutorizacionMovil__c> mapAM  = new Map<String,POCH_AutorizacionMovil__c>();        
        for(POCH_AutorizacionMovil__c am : lPedidos) {
            if(mapAM.containsKey(am.POCH_NumeroPedido__c)) {                                
                     if(String.isBlank(mapAM.get(am.POCH_NumeroPedido__c).POCH_Aprobador1__c)) { mapAM.get(am.POCH_NumeroPedido__c).POCH_Aprobador1__c = am.POCH_Aprobador__c; }
                else if(String.isBlank(mapAM.get(am.POCH_NumeroPedido__c).POCH_Aprobador2__c)) { mapAM.get(am.POCH_NumeroPedido__c).POCH_Aprobador2__c = am.POCH_Aprobador__c; }
                else if(String.isBlank(mapAM.get(am.POCH_NumeroPedido__c).POCH_Aprobador3__c)) { mapAM.get(am.POCH_NumeroPedido__c).POCH_Aprobador3__c = am.POCH_Aprobador__c; }
                else if(String.isBlank(mapAM.get(am.POCH_NumeroPedido__c).POCH_Aprobador4__c)) { mapAM.get(am.POCH_NumeroPedido__c).POCH_Aprobador4__c = am.POCH_Aprobador__c; }

                am.POCH_PedidoDuplicado__c = true;
            } else {
                mapAM.put(am.POCH_NumeroPedido__c,am);
            }                       
        }
        System.debug('--> mapAM ' + mapAM.size() + ' - ' + mapAM); 
        
        for(POCH_AutorizacionMovil__c am : [SELECT Id,POCH_Aprobador__c,POCH_NumeroPedido__c,POCH_IdExterno2__c FROM POCH_AutorizacionMovil__c 
                                            WHERE POCH_NumeroPedido__c IN : mapAM.keySet() ORDER BY CreatedDate ASC LIMIT 1]) 
        {
            System.debug('--> mapAM ' + mapAM.get(am.POCH_NumeroPedido__c));
			System.debug('--> am    ' + am);
            mapAM.get(am.POCH_NumeroPedido__c).POCH_PedidoDuplicado__c = true;
            
            updatePedidoExistente(am.Id, 
                                  mapAM.get(am.POCH_NumeroPedido__c).POCH_Aprobador__c,
                                  mapAM.get(am.POCH_NumeroPedido__c).POCH_Aprobador1__c,
                                  mapAM.get(am.POCH_NumeroPedido__c).POCH_Aprobador2__c,
                                  mapAM.get(am.POCH_NumeroPedido__c).POCH_Aprobador3__c,
                                  mapAM.get(am.POCH_NumeroPedido__c).POCH_Aprobador4__c);
        }       
                        
        System.debug('<=== OUT POCH_AutorizacionMovilHandler.gestionaPedidosDuplicados');
    }
    
    @future
    public static void updatePedidoExistente(Id idPedido, Id apr, Id apr1, Id apr2, Id apr3, Id apr4) {
        try {
            POCH_AutorizacionMovil__c am = new POCH_AutorizacionMovil__c();
            am.Id = idPedido;
            am.Estatus__c = 'Pendiente por Aprobar';
            am.POCH_SendResponseSAP__c = false;
            am.POCH_PedidoDuplicado__c = false;
            am.POCH_Aprobador__c = apr;
            if(String.isNotBlank(apr1)) { am.POCH_Aprobador1__c = apr1; }
            if(String.isNotBlank(apr2)) { am.POCH_Aprobador1__c = apr2; }
            if(String.isNotBlank(apr3)) { am.POCH_Aprobador1__c = apr3; }
            if(String.isNotBlank(apr4)) { am.POCH_Aprobador1__c = apr4; }

			System.debug('--> am ' + am);            
            update am;
        } catch(DMLException e) { System.debug('--> ERROR : ' + e.getMessage()); }
    }

    public static void gestionaApprovalRequest(List<POCH_AutorizacionMovil__c> lPedidos, String evt) {
        System.debug('===> IN POCH_AutorizacionMovilHandler.gestionaApprovalRequest --> lPedidos ' + lPedidos.size() + ' ::: evt ' + evt);
        
        if(esInvocadoPorTrigger) { return; }
        
        Map<Id,POCH_AutorizacionMovil__c> mapOldPedidos = (Map<Id,POCH_AutorizacionMovil__c>) Trigger.oldMap;                
        Set<Id> setPedidos = new Set<Id>(); 
        
        for(POCH_AutorizacionMovil__c am : lPedidos) {                        
            if(!am.POCH_PedidoDuplicado__c) {
                setPedidos.add(am.Id);
            }                        	                                   
        }
        System.debug('--> setPedidos ' + setPedidos);
        
        map<Id,ProcessInstanceWorkItem> mapPIWI = new Map<Id,ProcessInstanceWorkItem>();
        for(ProcessInstanceWorkItem piwi : [SELECT Id,ProcessInstance.TargetObjectId,ActorId FROM ProcessInstanceWorkItem WHERE ProcessInstance.Status = 'Pending' 
                                            AND ProcessInstance.TargetObjectId IN : setPedidos ORDER BY CreatedDate DESC LIMIT 1]) //setPedidos
        {
            mapPIWI.put(piwi.ProcessInstance.TargetObjectId, piwi);
        }
        System.debug('--> mapPIWI ' + mapPIWI);
        
        Set<Id> setPedidosDuplicados = new Set<Id>();
        for(POCH_AutorizacionMovil__c am : lPedidos) {  
            if(!am.POCH_PedidoDuplicado__c) {
                if(mapPIWI.containsKey(am.Id)) {
                    if(Trigger.isUpdate && 
                       (am.POCH_Aprobador__c  <> mapOldPedidos.get(am.Id).POCH_Aprobador__c)  ||
                       (am.POCH_Aprobador1__c <> mapOldPedidos.get(am.Id).POCH_Aprobador1__c) ||
                       (am.POCH_Aprobador2__c <> mapOldPedidos.get(am.Id).POCH_Aprobador2__c) ||
                       (am.POCH_Aprobador3__c <> mapOldPedidos.get(am.Id).POCH_Aprobador3__c) ||
                       (am.POCH_Aprobador4__c <> mapOldPedidos.get(am.Id).POCH_Aprobador4__c)  )
                    {                        
                        mapPIWI.get(am.Id).ActorId = am.POCH_Aprobador__c;                    
                        System.debug('--> mapPIWI.get(am.Id).ActorId ' + mapPIWI.get(am.Id).ActorId);
                    }                
                } else {
                    String comentarios = String.isBlank(am.Comentarios__c) ? '' : am.Comentarios__c.left(4000);                    
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();                    
                    req.setComments(comentarios);
                    req.setObjectId(am.Id);
                    if(Trigger.isInsert) {
                    	Approval.ProcessResult result = Approval.process(req);                    
                    } else if(Trigger.isUpdate &&
                              (am.POCH_Aprobador__c  <> mapOldPedidos.get(am.Id).POCH_Aprobador__c)  ||
                              (am.POCH_Aprobador1__c <> mapOldPedidos.get(am.Id).POCH_Aprobador1__c) ||
                              (am.POCH_Aprobador2__c <> mapOldPedidos.get(am.Id).POCH_Aprobador2__c) ||
                              (am.POCH_Aprobador3__c <> mapOldPedidos.get(am.Id).POCH_Aprobador3__c) ||
                              (am.POCH_Aprobador4__c <> mapOldPedidos.get(am.Id).POCH_Aprobador4__c)  )
                    {
                        Approval.ProcessResult result = Approval.process(req);
                    }
                }    
            } else {
                System.debug('--> am dup ' + am.Id);
                setPedidosDuplicados.add(am.Id);
            }
        }                                
         
        if(!mapPIWI.isEmpty()) {
            System.debug('--> mapPIWI.values() ' + mapPIWI.values());
            try {
                update mapPIWI.values();
            } catch(DMLException e) { System.debug(':::(X) Error: ' + e.getMessage()); }
        }  
        
        if(!setPedidosDuplicados.isEmpty()) {
        	eliminaPedidosDuplicados(setPedidosDuplicados);
        }
        
        System.debug('<=== OUT POCH_AutorizacionMovilHandler.gestionaApprovalRequest');
    }        
    
    @future
    public static void eliminaPedidosDuplicados(Set<Id> setPedidosDuplicados) {
        esInvocadoPorTrigger = true;
        delete [SELECT Id FROM POCH_AutorizacionMovil__c WHERE Id IN : setPedidosDuplicados];
    }
    
    public static void setComments(List<POCH_AutorizacionMovil__c> lPedidos, String evt) {        
        System.debug('===> IN POCH_AutorizacionMovilHandler.setComments --> lPedidos ' + lPedidos.size() + ' ::: evt ' + evt);
        
        if(esInvocadoPorTrigger) { return; }
        
        Map<Id,POCH_AutorizacionMovil__c> mapOldPedidos = (Map<Id,POCH_AutorizacionMovil__c>) Trigger.oldMap;
        
        Set<Id> setPedidos = new Set<Id>();
        for(POCH_AutorizacionMovil__c am : lPedidos) {
            if(am.Estatus__c <> mapOldPedidos.get(am.Id).Estatus__c && (am.Estatus__c == 'Aprobado' || am.Estatus__c == 'Rechazado')) {
            	setPedidos.add(am.Id);    
            }            
        }
        
        if(!setPedidos.isEmpty()) {
            sendResponseSAP(setPedidos);
        }          
        
        System.debug('<=== OUT POCH_AutorizacionMovilHandler.setComments');
    }
    
    @future
    public static void sendResponseSAP(Set<Id> setPedidos) {
        Map<Id,ProcessInstanceStep> mapPIS = new Map<Id,ProcessInstanceStep>();
        List<POCH_AutorizacionMovil__c> lAM = new List<POCH_AutorizacionMovil__c>();
        for(ProcessInstanceStep step : [SELECT Id,Comments,ProcessInstance.TargetObjectId FROM ProcessInstanceStep 
                                        WHERE ProcessInstance.TargetObjectId IN : setPedidos ORDER BY CreatedDate DESC LIMIT 1]) 
        {
            mapPIS.put(step.ProcessInstance.TargetObjectId, step);
            
        }
        
        for(POCH_AutorizacionMovil__c am : [SELECT Id,Estatus__c,Comentarios__c,POCH_SendResponseSAP__c FROM POCH_AutorizacionMovil__c WHERE Id IN : setPedidos]) {
            if(mapPIS.containsKey(am.Id)) {
                am.Comentarios__c = mapPIS.get(am.Id).Comments;
                am.POCH_SendResponseSAP__c = true;
                lAM.add(am);
            }            	   
        }
        
        if(!lAM.isEmpty()) {
            System.debug('--> lAM ' + lAM);
            esInvocadoPorTrigger = true;
            update lAM;
        }        
    }
    
}