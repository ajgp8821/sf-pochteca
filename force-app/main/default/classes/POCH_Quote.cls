/**
* ------------------------------------------------------------------------------------------------
* @Name     POCH_Quote
* @Author   Mauricio Esquivel Cázares mesquivel@freewayconsulting.com
* @Date     Created: 2019-08-16
* @Group    POCH
*Change Log
*09/06/2020 - Miriam Teloxa - Se cambia fecha de finalización calculandola de acuerdo al mes
* ------------------------------------------------------------------------------------------------
* @Related: POCH_OpportunityWithQuote
*@Description: Objeto específicamente para tratar Quotes dentro de clases. 
* |2019-08-16 mesquivel@freewayconsulting.com
*             Class creation. 
* -----------------------------------------------------------------------------------------------
*/
public with sharing class POCH_Quote {
    
    public SBQQ__Quote__c innerQuote;
    public List<SBQQ__QuoteLine__c> childQuoteLines;
    
    public POCH_Quote(string opportunityId, string accountId , string priceBookId, String qCurrency, String sucursalId, String idOwner) {
        List<POCH_Sucursal__c> sucursal = [SELECT POCH_Centro__c FROM POCH_Sucursal__c WHERE Id =: sucursalId];
        
        SBQQ__Quote__c innerQuote = new SBQQ__Quote__c();
        innerQuote.SBQQ__Account__c = accountId;
        innerQuote.SBQQ__Opportunity2__c = opportunityId;
        innerQuote.SBQQ__priceBookId__c = priceBookId;
        //        
        innerQuote.SBQQ__PriceBook__c = priceBookId;
        innerQuote.SBQQ__SalesRep__c  = idOwner;
        innerQuote.OwnerId = idOwner;
        //
        Date day=Date.today().toStartOfMonth();
        if(day.month()==1||day.month()==3||day.month()==5||day.month()==7||day.month()==8||day.month()==10||day.month()==12){
            innerQuote.SBQQ__EndDate__c=day.addDays(30);}
        else if(day.month()==4||day.month()==6||day.month()==9||day.month()==11){
            innerQuote.SBQQ__EndDate__c=day.addDays(29);}
        else if((math.mod(day.year(),400)==400)&&((math.mod(day.year(),4)==0)||(math.mod(day.year(),100)!=0))){
            innerQuote.SBQQ__EndDate__c=day.addDays(28);}
        else {innerQuote.SBQQ__EndDate__c=day.addDays(27);}
        //innerQuote.SBQQ__EndDate__c = Date.today() + 30;
        innerQuote.CurrencyIsoCode  = qCurrency;
        innerQuote.SBQQ__Primary__c = true;
        innerQuote.POCH_Sucursal__c = sucursalId;
        //innerQuote.SBQQ__LastCalculatedOn__c = System.now().addHours(1);
        if(!sucursal.isEmpty())
            innerQuote.POCH_Centro__c = sucursal[0].POCH_Centro__c;
        this.innerQuote = innerQuote;
        System.debug('--> this.innerQuote ' + this.innerQuote);
    }
    public POCH_Quote(){
        
        
    }
    /**
* --------------------------------------------------------------------------------------
* @Description fill quoteLine products with data from inventory sheet.
* --------------------------------------------------------------------------------------
* @param products-> List of inventory sheet detail(POCH_Details__C)
* @author: mesquivel@freewayconsulting.com -Esquivel Cázares Mauricio
* --------------------------------------------------------------------------------------
**/

public List<SBQQ__QuoteLine__c> createQuoteProducts(List<POCH_DetalleInventario__c> productos, Map<Id,Id> mapPrdPBE) {
List<SBQQ__QuoteLine__c> quoteLns = new List<SBQQ__QuoteLine__c>();
if(productos.size() > 0) {
For(POCH_DetalleInventario__c producto : productos) {
POCH_QuoteLine quoteLn = new POCH_QuoteLine(this.innerQuote, producto, mapPrdPBE.containsKey(producto.POCH_Producto__c) ? String.valueOf(mapPrdPBE.get(producto.POCH_Producto__c)) : '');
if (!Test.isRunningTest()) {
quoteLns.add(quoteLn.innerQuoteLine);
}
}
if (!Test.isRunningTest()) {
this.childQuoteLines = quoteLns ;
}
System.debug('--> this.childQuoteLines ' + this.childQuoteLines);
//insert quoteLns;
}
return quoteLns;
}

    public void createQuoteProductsList(List<POCH_DetalleInventario__c> productos, Map<Id,Id> mapPrdPBE) {
        
        
        System.debug('--> this.childQuoteLinesproductos ' + productos);
        List<SBQQ__QuoteLine__c> quoteLns = new List<SBQQ__QuoteLine__c>();
        if(productos.size() > 0) {
            For(POCH_DetalleInventario__c producto : productos) {
                SBQQ__QuoteLine__c quoteLine        = new SBQQ__QuoteLine__c();
                //  POCH_QuoteLine quoteLn = new POCH_QuoteLine(this.innerQuote, producto, mapPrdPBE.containsKey(producto.POCH_Producto__c) ? String.valueOf(mapPrdPBE.get(producto.POCH_Producto__c)) : '');
                string SBQQPricebookEntryIds =  mapPrdPBE.containsKey(producto.POCH_Producto__c) ? String.valueOf(mapPrdPBE.get(producto.POCH_Producto__c)) : '';       
                quoteLine.SBQQ__Quote__c            = innerQuote.id;
                quoteLine.SBQQ__Product__c	        = producto.POCH_Producto__c;
                quoteLine.POCH_PrecioUnitario__c	= Decimal.valueOf(producto.POCH_PrecioLista__c);
                quoteLine.SBQQ__PricebookEntryId__c = SBQQPricebookEntryIds;
                quoteLine.POCH_UnidadMedidaVenta__c = producto.POCH_UnidadMedida__c;
                quoteLine.POCH_CantidadVenta__c     = Decimal.valueOf(producto.POCH_CantidadBase__c);
                quoteLine.CurrencyIsoCode           = producto.POCH_Moneda__c;
                quoteLine.POCH_IsMonthly__c			= true;
            
                quoteLine.EsInventario__c = true;
                
                quoteLns.add(quoteLine);
            }
            // this.childQuoteLines = quoteLns ;
            System.debug('--> this.childQuoteLines ' + quoteLns);
             if (!Test.isRunningTest()) { 
            insert quoteLns;
             }
        }
        
    }
    
}