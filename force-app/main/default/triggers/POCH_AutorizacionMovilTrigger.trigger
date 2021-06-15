/****************************************************************************************************
General Information
-------------------
author:  Victor Jiménez
company: Freeway
Project: Pochteca
Description:  Trigger POCH_AutorizacionMovil__c to send Approval Request
-------------------------------------
Number    Dates             Author                       Description
------    -----------       --------------				 -----------
1.0       04-mar-2020       Victor Jiménez               Creation
****************************************************************************************************/

trigger POCH_AutorizacionMovilTrigger on POCH_AutorizacionMovil__c (before insert, after insert, after update) {

    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            POCH_AutorizacionMovilHandler.gestionaPedidosDuplicados(Trigger.new, 'Before Insert');
        }
    }
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            POCH_AutorizacionMovilHandler.gestionaApprovalRequest(Trigger.new, 'After Insert');
        }
        if(Trigger.isUpdate) {
            POCH_AutorizacionMovilHandler.gestionaApprovalRequest(Trigger.new, 'After Update');
            POCH_AutorizacionMovilHandler.setComments(Trigger.new, 'After Update');
        }
    }
    
}