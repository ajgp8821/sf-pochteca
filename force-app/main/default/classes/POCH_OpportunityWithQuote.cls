/**
* ------------------------------------------------------------------------------------------------
* @Name     POCH_OpportunityWithQuote
* @Author   Mauricio Esquivel Cázares mesquivel@freewayconsulting.com
* @Date     Created: 2019-08-16
* @Group    POCH
*Change Log
*09/06/2020 - Miriam Teloxa - Se agregan tipo y se cambia fecha de cierre calculandola de acuerdo al mes
* ------------------------------------------------------------------------------------------------
* @Related: POCH_IOpportunity
*@Description: Implementa las funciones de cualquier oportunidad relacionada a CPQ, favor de continuar la implementación
*en esta clase, a menos que sea un enfoque distinto de oportunidades, donde  implementaría también la interfaz de Iopportunity.

* |2019-08-16 mesquivel@freewayconsulting.com
*             Class creation. 
* -----------------------------------------------------------------------------------------------
*/
public with sharing Class POCH_OpportunityWithQuote implements POCH_IOpportunity {

    public Opportunity oportunidad{get;private set;}
    public POCH_Quote cotizacion{get;private set;}    
    Public Account relatedAccount;
    private string inventorySheetId;    
    public List<POCH_DetalleInventario__c> products{get;private set;}    
    
    public POCH_HojaInventario__c hojaInventario {get; private set;}    
    public Pricebook2 listaPrecios {get; private set;}        
    
    //public Set<String> divisas{get; private set;}
    public String lnCurrency;   
    public String idOwner;
    public POCH_OpportunityWithQuote() {}

    /*CONSTRUYE EL OBJETO OPORTUNIDAD CON SU CUENTA RELACIONADA Y LA HOJA DE INVENTARIO DE DONDE SE MANDÓ 
    */
    public POCH_OpportunityWithQuote(string relatedAccount, string inventorySheetId, Boolean isBatch, String div) {
        this.inventorySheetId = inventorySheetId;
        this.relatedAccount = [SELECT Id,Name,POCH_TipoRegistro__c,POCH_ListaPrecios__c FROM Account WHERE id =: relatedAccount limit 1];        
        this.hojaInventario = [SELECT Id,POCH_Sucursal__c,POCH_Cuenta__c,OwnerId FROM POCH_HojaInventario__c WHERE Id =: inventorySheetId limit 1];             
        this.lnCurrency = div;
        this.idOwner    = getUser(isBatch, relatedAccount, this.hojaInventario.POCH_Sucursal__c);
        
        Opportunity opp = new Opportunity();
        opp.accountId = relatedAccount;
        opp.stageName = (string.isNotEmpty(this.relatedAccount.POCH_TipoRegistro__c) && 
                (this.relatedAccount.POCH_TipoRegistro__c.toLowerCase() == 'sospechoso' || 
                this.relatedAccount.POCH_TipoRegistro__c.toLowerCase() == 'prospecto')) ? 
                this.relatedAccount.POCH_TipoRegistro__c : system.label.POCH_analysisStage ;
        opp.Name = System.label.POCH_Spancop + ' - ' + date.today().format() + ' - ' + div;
        //opp.closeDate = Date.today().addDays(30);
                
        
        Date firstDayOfMonth = Date.today().toStartOfMonth();
        System.debug('firstDayOfMonth: '+firstDayOfMonth);
        Date firstDayofNextMonth=firstDayOfMonth.addMonths(1);
        Date lastDayofMonth = Date.today().toStartOfMonth();
        System.debug('firstDayofNextMonth: '+firstDayofNextMonth);
        Date day=Date.today().toStartOfMonth();
        if(day.month()==1||day.month()==3||day.month()==5||day.month()==7||day.month()==8||day.month()==10||day.month()==12){
            lastDayofMonth=day.addDays(30);}
        else if(day.month()==4||day.month()==6||day.month()==9||day.month()==11){
            lastDayofMonth=day.addDays(29);}
        else if((math.mod(day.year(),400)==400)&&((math.mod(day.year(),4)==0)||(math.mod(day.year(),100)!=0))){
            lastDayofMonth=day.addDays(28);}
        else {lastDayofMonth=day.addDays(27);}
        
		opp.closeDate=lastDayofMonth;
        opp.AutomaticallyCreated__c=true;
        opp.POCH_Sucursal__c = this.hojaInventario.POCH_Sucursal__c;
        opp.POCH_OpportunityConversion__c = true;
        opp.POCH_MaterialHojaInventario__c = true;
        opp.CurrencyIsoCode = this.lnCurrency;
        opp.POCH_IniciativaComercial__c = 'ICV-0060';
        opp.POCH_IsMonthly__c = true;
        opp.OwnerId = this.idOwner;
        opp.Type = 'Corto plazo - Cliente Existente';
        opp.POCH_ActividadSCompletada__c = true;
        opp.POCH_FechaInicio__c  = Date.today();
      //  opp.closeDate = firstDayofNextMonth;
        
        List<PriceBook2> lPrices = [SELECT Id,Name FROM PriceBook2 WHERE POCH_Sucursal__c =: this.hojaInventario.POCH_Sucursal__c limit 1];
        if(!lPrices.isEmpty()) {
            this.listaPrecios = lPrices[0];
            opp.Pricebook2Id = this.listaPrecios.Id;
        }              
        
        this.oportunidad = opp;
    }
    public String getUser(Boolean isBatch, String acc, String suc) {
        if(isBatch) {
            List<POCH_SucursalAmpliada__c> lSA = [SELECT POCH_Vendedor__c FROM POCH_SucursalAmpliada__c WHERE POCH_Cliente__c =: acc AND POCH_Sucursal__c =: suc ORDER BY CreatedDate DESC LIMIT 1];
            if(!lSA.isEmpty()) {
                if(String.isNotBlank(lSA[0].POCH_Vendedor__c)) {
                	return lSA[0].POCH_Vendedor__c;    
                } return this.hojaInventario.OwnerId; 
            } else return this.hojaInventario.OwnerId;           
        } else return UserInfo.getUserId();
    }
    /*Retorna la oportunidad actual si no existe se puede pasar un Id de oportunidad para construir el objeto*/
    public Opportunity getOpportunity(String oppId) {
        if(this.oportunidad != null){
            return this.oportunidad;
        } else if(string.isNotEmpty(oppId)){
            this.oportunidad = [SELECT Name, AccountId, Id, StageName, Amount, CloseDate, Pricebook2Id, Estatus__c, POCH_Contacto__c, 
            SBQQ__PrimaryQuote__c FROM Opportunity where Id =:oppId limit 1];
            return this.oportunidad;
        } else {
            return null;
        }
    }
    /*Permite actualizar cualquier campo de oportunidad dando un mapa : campo->valor*/
    public void updateOppValues(Map<string,string> mapFieldValue) {
        sObject opp = this.oportunidad;
        For(String field : mapFieldValue.keySet()) {
            opp.put(field,mapFieldValue.get(field));
        }
        this.oportunidad = (Opportunity)opp;
    }
    /*Obtiene los productos relacionados dada una hoja de inventario, donde los productos son representados por 
    medio del objeto POCH_DetalleInvetario__c */
    public List<POCH_DetalleInventario__c> getPriceBookEntries() {
        List<POCH_DetalleInventario__c> detallesInventario = [SELECT CurrencyIsoCode,POCH_Estatus__c, POCH_Sucursal__c, POCH_Producto__c, POCH_CantidadPotencial__c,
                                                              POCH_CantidadBase__c,POCH_PrecioLista__c,POCH_UnidadMedida__c,POCH_Moneda__c
        													  FROM POCH_DetalleInventario__c WHERE POCH_HojaInventario__c =: this.inventorySheetId 
                                                              AND POCH_Estatus__c =: System.label.POCH_activeStatus
                                                              AND POCH_Moneda__c =: this.lnCurrency 
                                                              AND POCH_Producto__r.onlyInSalesforce__c = FALSE
                                                              AND POCH_PrecioLista__c <> '0' AND POCH_PrecioLista__c <> '.00' AND POCH_PrecioLista__c <> '0.00' 
                                                              AND POCH_PrecioLista__c <> '0.0' AND POCH_PrecioLista__c <> '' AND POCH_PrecioLista__c <> null];        
        this.products = detallesInventario;
        System.debug('--> this.products ' + this.products);
        return this.products;
    }

    public  POCH_Quote createQuote () {
        POCH_Quote cotizacion = new POCH_Quote(this.oportunidad.id ,this.oportunidad.accountId, this.listaPrecios.Id, this.lnCurrency, this.hojaInventario.POCH_Sucursal__c, this.idOwner);
        this.cotizacion = cotizacion;
        return this.cotizacion;
    }        

}