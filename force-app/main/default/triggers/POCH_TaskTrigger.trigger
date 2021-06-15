/***************************************************************************************************************
Name:        POCH_TaskTrigger.apxt
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 11-02-2020
Project:	 Pochteca

Description: Task Trigger
***************************************************************************************************************/

trigger POCH_TaskTrigger on Task (before insert, before update) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            POCH_ActivityTriggerHandler.handleActivitySucursal(Trigger.new, 'Task');
        }
    }
}