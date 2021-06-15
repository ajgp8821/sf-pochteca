/***************************************************************************************************************
Name:        POCH_EventTrigger.apxt
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 11-02-2020
Project:	 Pochteca

Description: Event Trigger
***************************************************************************************************************/

trigger POCH_EventTrigger on Event (before insert, before update) {
	if(Trigger.isBefore) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            POCH_ActivityTriggerHandler.handleActivitySucursal(Trigger.new, 'Event');
        }
    }
}