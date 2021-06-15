/*---------------------------------------------------------------------------------------------------------------
--- Company: Zaga System 
--- Author: Jesús Azuaje
--- Update for: 
--- Description: Test class for create records test
--- CreateDate: 24/03/2021 - JIRA RN6520
--- UpdateDate:  - JIRA
--- Version: 1.0
---------------------------------------------------------------------------------------------------------------*/
@isTest
public with sharing class DataFactory {
    @TestSetup
    public static void setup(){
        
        Account acc 				   	= new Account();
        acc.Name 					   	= 'ACC TEST';
        acc.Phone						= '5536848775';
        acc.POCH_IDClienteSAP__c 	   	= '181114';
        acc.POCH_CorreoElectronico__c  	= 'test@mail.com';
        acc.POCH_TipoRegistro__c       	= 'Prospecto';
        acc.POCH_OrganizacionVentas__c 	= '0049';
        acc.CurrencyIsoCode			   	= 'MXN';
        acc.BillingStreet			   	= 'Calle';
        acc.BillingPostalCode		   	= '02400';
        acc.BillingCity				   	= 'CDMX';
        acc.BillingCountry				= 'MEXICO';
        acc.POCH_PaisFactura__c			= 'MX';
        acc.POCH_Incoterms__c		   	= 'CF';
        acc.POCH_GrupoClientes__c	   	= '01';        
        //acc.POCH_ClasificacionFiscal__c	= '0';
        acc.POCH_RFC__c 				= 'PCH910211C39';
        acc.POCH_IdentificacionOficial__c = true;
        acc.POCH_ComprobanteDomicilio__c  = true;
        acc.POCH_5Gerente__c 			= true;
        acc.POCH_10Vendedor__c 			= false;
        acc.POCH_15Sucursal__c			= false;
        
    }
}