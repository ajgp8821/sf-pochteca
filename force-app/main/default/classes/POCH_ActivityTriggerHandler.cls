/***************************************************************************************************************
Name:        POCH_ActivityTriggerHandler.apxt
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 11-02-2020
Project:	 Pochteca

Description: Activity Trigger Handler Class
***************************************************************************************************************/

public class POCH_ActivityTriggerHandler {
	
    public static void handleActivitySucursal(List<sObject> lActivities, String objeto) {
        System.debug('::: IN POCH_ActivityTriggerHandler.handleActivitySucursal --> lActivities: ' + lActivities.size() + ' --> Objeto: ' + objeto);

        Set<Id> setAccs = new Set<Id>();
        Set<Id> setOpps = new Set<Id>();
        Set<Id> setLead = new Set<Id>();
        for(sObject actv : lActivities) {
            if(objeto.containsIgnoreCase('Task')) {
                Task tsk = (Task) actv;
                if(String.isNotBlank(tsk.WhatId)) {
                    if(tsk.WhatId.getsObjectType().getDescribe().getName().containsIgnoreCase('Account'))     { setAccs.add(tsk.WhatId); }
                    if(tsk.WhatId.getsObjectType().getDescribe().getName().containsIgnoreCase('Opportunity')) { setOpps.add(tsk.WhatId); }
                } else if(String.isNotBlank(tsk.WhoId)) {
                    if(tsk.WhoId.getsObjectType().getDescribe().getName().containsIgnoreCase('Lead'))         { setLead.add(tsk.WhoId); }                    
                }
            }
            if(objeto.containsIgnoreCase('Event')) {
                Event evt = (Event) actv;
                if(String.isNotBlank(evt.WhatId)) {
                    if(evt.WhatId.getsObjectType().getDescribe().getName().containsIgnoreCase('Account'))     { setAccs.add(evt.WhatId); }
                    if(evt.WhatId.getsObjectType().getDescribe().getName().containsIgnoreCase('Opportunity')) { setOpps.add(evt.WhatId); }
                } else if(String.isNotBlank(evt.WhoId)) {
                    if(evt.WhoId.getsObjectType().getDescribe().getName().containsIgnoreCase('Lead'))         { setLead.add(evt.WhoId); }                    
                }
            }
        }
        
        Map<Id,Opportunity> mapOpps = new Map<Id,Opportunity>([SELECT Id,POCH_Sucursal__c FROM Opportunity WHERE Id IN : setOpps]);
        Map<Id,Lead>        mapLead = new Map<Id,Lead>       ([SELECT Id,POCH_Sucursal__c FROM Lead        WHERE Id IN : setLead]);
        Map<Id,Set<Id>>     mAccSuc = new Map<Id,Set<Id>>();
        for(POCH_SucursalAmpliada__c sa : [SELECT Id,POCH_Cliente__c,POCH_Sucursal__c FROM POCH_SucursalAmpliada__c WHERE POCH_Cliente__c IN : setAccs]) {
            if(mAccSuc.containsKey(sa.POCH_Cliente__c)) 
                mAccSuc.get(sa.POCH_Cliente__c).add(sa.POCH_Sucursal__c);
            else mAccSuc.put(sa.POCH_Cliente__c, new Set<Id>{sa.Poch_Sucursal__c});
        }
        
        for(sObject actv : lActivities) {
            if(objeto.containsIgnoreCase('Task')) {
                Task tsk = (Task) actv;
                if(String.isNotBlank(tsk.WhatId)) {
                    if(tsk.WhatId.getsObjectType().getDescribe().getName().containsIgnoreCase('Opportunity')) { 
                        if(mapOpps.containsKey(tsk.WhatId)) { tsk.POCH_Sucursal__c = mapOpps.get(tsk.WhatId).POCH_Sucursal__c; }                        
                    } else if(tsk.WhatId.getsObjectType().getDescribe().getName().containsIgnoreCase('Account')) { 
                        if(mAccSuc.containsKey(tsk.WhatId)) {
                          	Set<Id> setIdsSucursales = mAccSuc.get(tsk.WhatId);
                          	if(tsk.POCH_Sucursal__c == null) tsk.POCH_Sucursal__c = (new list<Id>(setIdsSucursales) )[0] ;
                            if(String.isBlank(tsk.POCH_Sucursal__c) || !mAccSuc.get(tsk.WhatId).contains(tsk.POCH_Sucursal__c)) {
                                System.debug('Linea 57');
                                tsk.addError('Por favor, selecciona una sucursal ampliada para el cliente');
                            }
                        }
                    }                    
                } else if(String.isNotBlank(tsk.WhoId)) {
                    if(tsk.WhoId.getsObjectType().getDescribe().getName().containsIgnoreCase('Lead')) { 
                        if(mapLead.containsKey(tsk.WhoId)) { tsk.POCH_Sucursal__c = mapLead.get(tsk.WhoId).POCH_Sucursal__c; } 
                    }                    
                }
            }
            if(objeto.containsIgnoreCase('Event')) {
                Event evt = (Event) actv;
                if(String.isNotBlank(evt.WhatId)) {
                    if(evt.WhatId.getsObjectType().getDescribe().getName().containsIgnoreCase('Opportunity')) { 
                        if(mapOpps.containsKey(evt.WhatId)) { evt.POCH_Sucursal__c = mapOpps.get(evt.WhatId).POCH_Sucursal__c; }                        
                    } else if(evt.WhatId.getsObjectType().getDescribe().getName().containsIgnoreCase('Account')) { 
                        if(mAccSuc.containsKey(evt.WhatId)) {
                            if(String.isBlank(evt.POCH_Sucursal__c) || !mAccSuc.get(evt.WhatId).contains(evt.POCH_Sucursal__c)) {
                                System.debug('Linea 76');
                                evt.addError('Por favor, selecciona una sucursal ampliada para el cliente');
                            }
                        }
                    }                    
                } else if(String.isNotBlank(evt.WhoId)) {
                    if(evt.WhoId.getsObjectType().getDescribe().getName().containsIgnoreCase('Lead')) { 
                        if(mapLead.containsKey(evt.WhoId)) { evt.POCH_Sucursal__c = mapLead.get(evt.WhoId).POCH_Sucursal__c; } 
                    }                    
                }
            }
        }
        
        System.debug('::: OUT POCH_ActivityTriggerHandler.handleActivitySucursal');
    }
    
    
}