/**
* ------------------------------------------------------------------------------------------------
* @Name     POCH_QuoteLine
* @Author   Mauricio Esquivel Cázares mesquivel@freewayconsulting.com
* @Date     Created: 2019-08-19
* @Group    POCH
* ------------------------------------------------------------------------------------------------
* @Related: POCH_OpportunityWithQuote , POCH_Quote
*@Description: 
* |2019-08-19 mesquivel@freewayconsulting.com
*             Class creation. 
* -----------------------------------------------------------------------------------------------
*/
public with sharing class POCH_QuoteLine {
    
    Public SBQQ__QuoteLine__c innerQuoteLine;
   
    
    public POCH_QuoteLine(SBQQ__Quote__c relatedQuote, POCH_DetalleInventario__c producto, String pricebookEntryId) {
        SBQQ__QuoteLine__c quoteLine        = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Quote__c            = relatedQuote.Id;
        quoteLine.SBQQ__Product__c	        = producto.POCH_Producto__c;
        //quoteLine.SBQQ__Quantity__c	    = Decimal.valueOf(producto.POCH_CantidadBase__c);
        //quoteLine.SBQQ__CustomerPrice__c  = Decimal.valueOf(producto.POCH_PrecioLista__c);
        quoteLine.POCH_PrecioUnitario__c	= Decimal.valueOf(producto.POCH_PrecioLista__c);
        //
        quoteLine.SBQQ__PricebookEntryId__c = pricebookEntryId;
        //
        quoteLine.POCH_UnidadMedidaVenta__c = producto.POCH_UnidadMedida__c;
        quoteLine.POCH_CantidadVenta__c     = Decimal.valueOf(producto.POCH_CantidadBase__c);
        quoteLine.CurrencyIsoCode           = producto.POCH_Moneda__c;
        quoteLine.POCH_IsMonthly__c			= true;
        quoteLine.EsInventario__c = true;
        this.innerQuoteLine = quoteLine;
    }
    
   
    /*Public OpportunityLineItem innerQuoteLine;

    public POCH_QuoteLine(Id relatedOpp, POCH_DetalleInventario__c di) {  //, Map<Id,Map<String,POCH_UnidadMedidaProducto__c>> mapPrd_UM
        OpportunityLineItem oli 	  = new OpportunityLineItem();
        oli.OpportunityId       	  = relatedOpp;
        oli.Product2Id          	  = di.POCH_Producto__c;
        oli.Quantity 	          	  = Decimal.valueOf(di.POCH_CantidadBase__c); //getQuantity(di, mapPrd_UM);                                  
        oli.POCH_CantidadVenta__c     = Decimal.valueOf(di.POCH_CantidadBase__c);
        oli.UnitPrice     			  = Decimal.valueOf(di.POCH_PrecioLista__c);
        oli.Description   		      = di.Name;
        oli.POCH_UnidadMedidaVenta__c = di.POCH_UnidadMedida__c;
        oli.POCH_IsMonthly__c 		  = true;
        this.innerQuoteLine 	      = oli;
        
        
        //Crear campo de prorated,quantity,etc en inv y ql y en trigger de QL en insert validar si vienen de inv y asignar a los campos reales
        
        /*SBQQ__QuoteLine__c quoteLine        = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Quote__c            = relatedQuote.Id;
        quoteLine.SBQQ__Product__c	        = producto.POCH_Producto__c;
        //quoteLine.SBQQ__Quantity__c	    = Decimal.valueOf(producto.POCH_CantidadBase__c);
        quoteLine.SBQQ__CustomerPrice__c    = Decimal.valueOf(producto.POCH_PrecioLista__c);
        //
        quoteLine.POCH_UnidadMedidaVenta__c = producto.POCH_UnidadMedida__c;
        quoteLine.POCH_CantidadVenta__c     = Decimal.valueOf(producto.POCH_CantidadBase__c);
        quoteLine.CurrencyIsoCode           = producto.POCH_Moneda__c;
        quoteLine.POCH_IsMonthly__c			= true;
        this.innerQuoteLine = quoteLine;*/
    //}
    
    
    /*
    private static Decimal getQuantity(POCH_DetalleInventario__c di, Map<Id,Map<String,POCH_UnidadMedidaProducto__c>> mapPrd_UM) {
        Decimal ctdBase = Decimal.valueOf(di.POCH_CantidadBase__c);
        if(mapPrd_UM.containsKey(di.POCH_Producto__c)) {
            Decimal fC_V = mapPrd_UM.get(di.POCH_Producto__c).containsKey(di.POCH_UnidadMedida__c) 
                ? mapPrd_UM.get(di.POCH_Producto__c).get(di.POCH_UnidadMedida__c).POCH_Numerador__c / mapPrd_UM.get(di.POCH_Producto__c).get(di.POCH_UnidadMedida__c).POCH_Denominador__c  : 1;
            Decimal fC_P = mapPrd_UM.get(di.POCH_Producto__c).containsKey(di.POCH_uma__c) 
                ? mapPrd_UM.get(di.POCH_Producto__c).get(di.POCH_uma__c).POCH_Numerador__c / mapPrd_UM.get(di.POCH_Producto__c).get(di.POCH_uma__c).POCH_Denominador__c  : 1;
            
            ctdBase = (ctdBase * fC_V) / fC_P;
        }
        System.debug('--> ctdBase ' + ctdBase);
        return ctdBase;       
    }    
	*/
}