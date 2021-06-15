/****************************************************************************************************
General Information
-------------------
author:  Victor Jiménez
company: Freeway
Project: Pochteca
Description:  Controller APEX component POCH_AutorizacionMovilDetalle_cmp
-------------------------------------
Number    Dates             Author                       Description
------    -----------       --------------				 -----------
1.0       24-feb-2020       Victor Jiménez               Creation
****************************************************************************************************/

public class POCH_AutorizacionMovilDetalle_ctrl {
    
    /**
     *  Metodo para obtener los detalles del pedido de ventas
     **/
    @AuraEnabled
    public static POCH_AutorizacionMovil__c getDetallesPedido(String idPedido) {
        return [SELECT Id, Name, CurrencyIsoCode, POCH_NumeroPedido__c, POCH_Cliente__c, POCH_Sucursal__c, POCH_Vendedor__c, POCH_Vendedor__r.Name, 
                POCH_Plazo__c, Incoterm__c, POCH_Aprobador__c, POCH_Aprobador__r.Name, Comentarios__c, Estatus__c, POCH_DetalleAutorizacion__c, 
                 (SELECT Id, Name, CurrencyIsoCode, POCH_AutorizacionMovil__c, POCH_Producto__c, POCH_PorcentajeUtil__c, POCH_Utilidad__c, 
                  POCH_Precio__c, POCH_Costo__c, POCH_Cantidad__c, POCH_Almancen__c, POCH_IdExterno__c FROM Detalles_de_autorizaciones__r)
                FROM POCH_AutorizacionMovil__c WHERE Id =: idPedido];
    }
    /**
     *  Metodo para obtener el Id de la ultima solicitud de aprobación
     **/
    @AuraEnabled
    public static String getIdApprovalRequest(String idPedido) {
        String idAprReq = '';
        for(ProcessInstanceWorkItem piwi : [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.Status = 'Pending' 
                                            AND ProcessInstance.TargetObjectId =: idPedido AND ActorId =: UserInfo.getUserId()
                                            ORDER BY CreatedDate DESC LIMIT 1]) 
        {
            idAprReq = piwi.Id;
        }
        return idAprReq;
    }
    /**
     *  Metodo para obtener el Id de la ultima solicitud de aprobación
     **/
    @AuraEnabled
    public static String makeApprovalDecision(String idPedido, String idAppReq, String strResolucion, String strComentarios) {
        try {
            POCH_AutorizacionMovil__c pedido = [SELECT Id,Estatus__c,Comentarios__c FROM POCH_AutorizacionMovil__c WHERE Id =: idPedido LIMIT 1];    
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkItemID(idAppReq);
            req.setComments(strComentarios);
            req.setAction(strResolucion);
            Approval.ProcessResult result = Approval.process(req);
            
            pedido.Comentarios__c = String.isNotBlank(strComentarios) ? strComentarios : '';
            pedido.Estatus__c     = strResolucion == 'Reject' ? 'Rechazado' : 'Aprobado';
            update pedido;
            
            return 'OK';
        } catch(Exception e) {            
            return 'ERROR : ' + e.getMessage();
        }
    }
    
    @AuraEnabled
    public static List<StepWrapper> getApprovalComments(String idPedido) {
        List<StepWrapper> lPIS = new List<StepWrapper>();
        Map<Id,ProcessInstanceStep> mapPIS = new Map<Id,ProcessInstanceStep>();
        for(ProcessInstanceStep step : [SELECT Id,Comments,ActorId,Actor.Name,CreatedDate FROM ProcessInstanceStep WHERE ProcessInstance.Status = 'Pending' 
                                        AND ProcessInstance.TargetObjectId =: idPedido ORDER BY CreatedDate ASC]) 
        {
            mapPIS.put(step.ActorId, step);
        }

        for(User usr : [SELECT Id,FullPhotoUrl FROM User WHERE Id IN : mapPIS.keySet()]) {
            lPIS.add(new StepWrapper(mapPIS.get(usr.Id), usr.FullPhotoUrl, mapPIS.get(usr.Id).CreatedDate.format('dd/MM/yyyy HH:mm:ss','America/Mexico_City'))); 
        }
        return lPIS;
    }
    public class StepWrapper {
        @AuraEnabled public ProcessInstanceStep pis           {get;set;}
        @AuraEnabled public String              urlPhoto      {get;set;}
        @AuraEnabled public String              fechaCreacion {get;set;}
        public StepWrapper(ProcessInstanceStep step, String url, String fCreacion) {
            this.pis = step;
            this.urlPhoto = url;
            this.fechaCreacion = fCreacion;
        }
    }

}