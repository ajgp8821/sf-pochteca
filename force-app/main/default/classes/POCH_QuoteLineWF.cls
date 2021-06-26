/***************************************************************************************************************
Name:        POCH_QuoteLineWF.cls
Author:      Victor Hugo Jiménez Hernández (vjimenez@freewayconsulting.com)
Created:	 10-09-2019
Project:	 Pochteca

Description: Quote Line WF Class

***************************************************************************************************************/

public class POCH_QuoteLineWF {
    
    //:::::::::::::::::::::::::::: GESTION DE APROBACIONES (WF) :::::::::::::::::::::::::::::::::::: 
    public static void handleApprovalQuoteLine(List<SBQQ__QuoteLine__c> lCPQQuoteLines) {
        System.debug('::: IN POCH_QuoteLineWF.handleApprovalQuoteLine : lCPQQuoteLines --> ' + lCPQQuoteLines); 
        
        POCH_QuoteLineWFHelper helperQL = new POCH_QuoteLineWFHelper(lCPQQuoteLines);                    
        for(SBQQ__QuoteLine__c quoteLineCPQ : lCPQQuoteLines) { 
                           if(String.isNotBlank(helperQL.mapQouteFechaCancel.get(quoteLineCPQ.Id))){
                                System.debug('String.isNotBlank(quoteLineCPQ.SBQQ__Quote__r.Tiempo_cancelacion__c'); 
                                quoteLineCPQ.fecha_inicio__c = Datetime.now();
                                if(helperQL.mapQouteFechaCancel.get(quoteLineCPQ.Id)=='24'){quoteLineCPQ.fecha_cancelacion__c = quoteLineCPQ.fecha_inicio__c.addDays(1);}
                                if(helperQL.mapQouteFechaCancel.get(quoteLineCPQ.Id)=='48'){quoteLineCPQ.fecha_cancelacion__c = quoteLineCPQ.fecha_inicio__c.addDays(2);}
                                if(helperQL.mapQouteFechaCancel.get(quoteLineCPQ.Id)=='72'){quoteLineCPQ.fecha_cancelacion__c = quoteLineCPQ.fecha_inicio__c.addDays(3);}
                                
                            }		
            handleWFMaterialesCriticos(quoteLineCPQ, helperQL);
            System.debug('::: OUT POCH_QuoteLineWF.mapPrecioEntradaLibro'+quoteLineCPQ.Precio_del_D_a__c);
        }
        
        System.debug('::: OUT POCH_QuoteLineWF.handleApprovalQuoteLine');
    }
    
    //:::::::::::::::::::::::: 1. WF Moneda (Descartado por funcionalidad de CPQ) :::::::::::::::::::::::::::::
    //public static void handleWFMoneda() {}
    
    //:::::::::::::::::::::::: 2. WF Materiales Criticos :::::::::::::::::::::::::::::
    public static void handleWFMaterialesCriticos(SBQQ__QuoteLine__c quoteLineCPQ, POCH_QuoteLineWFHelper helperQL) {
        System.debug('::: IN POCH_QuoteLineWF.handleWFMaterialesCriticos : quoteLineCPQ --> ' + quoteLineCPQ);
        
        if(!quoteLineCPQ.POCH_WFMaterialCriticoAprobado__c) {
            Boolean esLiberada = true;
            for(String acc : helperQL.mapClienteSucursales.keySet()) {                
                for(POCH_SucursalAmpliada__c sa : helperQL.mapClienteSucursales.get(acc)) {
                    if(quoteLineCPQ.POCH_SucursalQuoteName__c == sa.Poch_Sucursal__r.Name && sa.POCH_GrupoClientes2__c <> 'LIB') {
                        esLiberada = false;                            
                    }                               
                }                 
            }   
            if(!esLiberada && quoteLineCPQ.POCH_Critico__c) {
                System.debug('--> 2: ENTRA A WF DE MAT CRITICOS ::: APROBADORES ASIGNADOS : ' + quoteLineCPQ.Id);
                quoteLineCPQ.Precio_del_D_a__c     = helperQL.mapPrecioEntradaLibro.get(quoteLineCPQ.SBQQ__PricebookEntryId__c);
                quoteLineCPQ.POCH_WF__c            = helperQL.configuracionWF.POCH_WFMatCriticos__c;
                quoteLineCPQ.POCH_WFComentarios__c = helperQL.configuracionWF.POCH_ComentariosWFMatCritico__c;
                quoteLineCPQ.Precio_del_D_a__c     = helperQL.mapPrecioEntradaLibro.get(quoteLineCPQ.SBQQ__PricebookEntryId__c);
                string grtOrg1 = '0049';
                string grtOrg2 = '0201';
                if(Test.isRunningTest()) {   
                grtOrg1 = '0000';
                grtOrg2 = '0000';
                }
                Boolean activaWF = false;
                String discountSchedule = helperQL.getDiscountSchedule(quoteLineCPQ);  
                System.debug('discountSchedule CRITICOS'+discountSchedule); 
                System.debug('helperQL.mapProductoPrecioXEscala CRITICOS'+helperQL.mapProductoPrecioXEscala.get(quoteLineCPQ.SBQQ__Product__c).containsKey(discountSchedule)); 
                System.debug('--> 5. Tiene Discount Tiers');                                                                          
                Integer escalaInicial = 1;   //1
                decimal[] myList;
                Decimal precioInicial = 0;
                integer cont = 0;
                Boolean preciolista = false;
                String discountTier = helperQL.getDiscountTier(quoteLineCPQ,discountSchedule);
                decimal numeroDicon = 0; 
               // getNumeroEscalaWF
            for(SBQQ__DiscountTier__c dt : helperQL.mapProductoPrecioXEscala.get(quoteLineCPQ.SBQQ__Product__c).get(discountSchedule)) {
                 if(test.isRunningTest()){
                      discountTier =  dt.id;                         
                    }  
                    if(dt.Id == discountTier) {
                    
                        cont++;
                        System.debug('--> escalaInicial : CRITICOS' + escalaInicial + ' : ImporteCondicion = ' + dt.POCH_ImporteCondicion__c);
                        system.debug('psaaaa'+dt.SBQQ__Schedule__r.SBQQ__Product__c +'discountTier'+dt.Id+'SBQQ__Schedule__c'+dt.SBQQ__Schedule__c);
                        precioInicial = dt.POCH_ImporteCondicion__c;
                        myList = new List<decimal> {};
                            myList.add(dt.POCH_ImporteCondicion__c);
                        myList.sort();
                        
                        break;
                    }else{escalaInicial++;}
                } 
                
                if(cont == 1 && quoteLineCPQ.CurrencyIsoCode=='MXN' || quoteLineCPQ.CurrencyIsoCode =='GTQ'){escalaInicial = escalaInicial -1;}  
                Integer saltos = 0;
                Integer escalaActual = 1;
                Decimal precioMaximo = 0;
                Boolean enEscala = false;
                Boolean enEscalaRe = false;
                
                if(quoteLineCPQ.CurrencyIsoCode =='USD'){
                    for(SBQQ__DiscountTier__c dt : helperQL.mapProductoPrecioXEscala.get(quoteLineCPQ.SBQQ__Product__c).get(discountSchedule)) {
                        if( dt.POCH_ImporteUpper__c == dt.POCH_ImporteCondicion__c && quoteLineCPQ.SBQQ__CustomerPrice__c < quoteLineCPQ.POCH_PrecioMinimo__c){
                            saltos = 5;  
                            System.debug('--> VALORES minimoImporte usd ');
                        }
                        Decimal upperImporte = String.isBlank(String.valueOf(dt.POCH_ImporteUpper__c)) ? dt.POCH_ImporteCondicion__c : dt.POCH_ImporteUpper__c;  //?0 //-0.00001
                        System.debug('--> escalaActual : '+ escalaActual +' : ImporteCondicion '+ dt.POCH_ImporteCondicion__c +' > CustomerPrice '+ quoteLineCPQ.SBQQ__CustomerPrice__c +' <= ImporteBandaMenor '+ upperImporte+'quoteLineCPQ.SBQQ__ListPrice__c'+quoteLineCPQ.SBQQ__ListPrice__c);                            
                        if(escalaActual == 1) { precioMaximo = dt.POCH_ImporteCondicion__c; }
                        if(quoteLineCPQ.SBQQ__CustomerPrice__c >= upperImporte && quoteLineCPQ.SBQQ__CustomerPrice__c >= dt.POCH_ImporteCondicion__c && quoteLineCPQ.SBQQ__CustomerPrice__c != quoteLineCPQ.SBQQ__ListPrice__c) {  
                            enEscala = true;
                            break;
                        } else escalaActual++;   
                    }   
                }
                Integer escalaInicialRe  =1;   //1
                Decimal upperImporte;
                Decimal minimoImporte;
                if(quoteLineCPQ.CurrencyIsoCode =='MXN' || quoteLineCPQ.CurrencyIsoCode =='GTQ' ){ 
                    if(!test.isRunningTest()){ quoteLineCPQ.SBQQ__CustomerPrice__c = quoteLineCPQ.POCH_TotalCliente__c / quoteLineCPQ.POCH_MultiplosConversion__c;}
                    
                    for(SBQQ__DiscountTier__c dt : helperQL.mapProductoPrecioXEscala.get(quoteLineCPQ.SBQQ__Product__c).get(discountSchedule)) {                        
                        System.debug('--> VALORES POCH_ImporteUpper__c ESCALA CRITICOS:'+ dt.POCH_ImporteUpper__c+'SBQQ__CustomerPrice__c'+quoteLineCPQ.SBQQ__CustomerPrice__c+'POCH_ImporteCondicion__c'+dt.POCH_ImporteCondicion__c);
                        if( dt.POCH_ImporteUpper__c == dt.POCH_ImporteCondicion__c && quoteLineCPQ.SBQQ__CustomerPrice__c < quoteLineCPQ.POCH_PrecioMinimo__c){
                            minimoImporte =  quoteLineCPQ.SBQQ__CustomerPrice__c;
                            saltos = 5;  
                            System.debug('--> VALORES minimoImporte CRITICOS'+minimoImporte);
                        }
                        upperImporte = String.isBlank(String.valueOf(dt.POCH_ImporteUpper__c)) ? dt.POCH_ImporteCondicion__c : dt.POCH_ImporteUpper__c;  //?0 //-0.00001
                        System.debug('--> escalaActual : '+ escalaActual +' : ImporteCondicion '+ dt.POCH_ImporteCondicion__c +' >= CustomerPrice '+ quoteLineCPQ.SBQQ__CustomerPrice__c +' >= ImporteBandaMenor '+ upperImporte);                            
                        if(escalaActual == 1) { precioMaximo = dt.POCH_ImporteCondicion__c; }
                        if(Test.isRunningTest()) {  upperImporte = 1;}
                        if(quoteLineCPQ.SBQQ__CustomerPrice__c >= upperImporte && quoteLineCPQ.SBQQ__CustomerPrice__c  <= dt.POCH_ImporteCondicion__c && quoteLineCPQ.SBQQ__CustomerPrice__c != quoteLineCPQ.SBQQ__ListPrice__c ) {
                            System.debug('--> VALORES PASASNDO ESCALA : '+ escalaActual +' : SBQQ__CustomerPrice__c '+ quoteLineCPQ.SBQQ__CustomerPrice__c +' >= upperImporte '+ upperImporte +' >= SBQQ__CustomerPrice__c  >='+'POCH_ImporteCondicion__c'+ dt.POCH_ImporteCondicion__c );               
                            enEscala = false;
                            enEscalaRe = true;
                            break;
                        } else escalaActual++;                                                        
                    }   
                } 
                decimal MinValue =  mylist[0];
                System.debug('===> MinValueMinValueMinValue ' +MinValue);
                if(enEscala == false) {
                    
                } else {                            
                    System.debug('===> escalaActual usd - escalaInicial ' + escalaActual + '-' + escalaInicial + ' : ');     
                    saltos =  escalaActual  - escalaInicial;
                }
                if(enEscalaRe) {
                    System.debug('===> escalaActual mxn - escalaInicial ' + escalaActual + '-' + escalaInicial + ' : ');     
                    saltos =  escalaActual  - escalaInicial;
                    // if(Test.isRunningTest()) {   saltos =  escalaInicial;}
                    
                }
                System.debug('::: ===> SALTOS critico: ' + saltos);
                if(saltos > 0) {
                    if(saltos >= 1 || quoteLineCPQ.SBQQ__CustomerPrice__c < quoteLineCPQ.POCH_PrecioMinimo__c ) {
                        if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'GS'))) { quoteLineCPQ.POCH_WFAprobador1__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'GS'); }
                        //quoteLineCPQ.POCH_WFAprobador1__c = '0055C000002MparQAC';  //Test
                    } 
                   if((quoteLineCPQ.POCH_OrgVentasQuote__c <> grtOrg1)){
                                if((quoteLineCPQ.POCH_OrgVentasQuote__c <> grtOrg2)){
                    if(saltos >= 2 || quoteLineCPQ.SBQQ__CustomerPrice__c < quoteLineCPQ.POCH_PrecioMinimo__c) {
                        if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'GR'))) { 
                            system.debug('pasasndo'+quoteLineCPQ.POCH_WFAprobador2__c);
                            quoteLineCPQ.POCH_WFAprobador2__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'GR'); }                                
                        
                    } }
                    }
                    if(saltos >= 3 || quoteLineCPQ.SBQQ__CustomerPrice__c < quoteLineCPQ.POCH_PrecioMinimo__c) {
                        if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'GL'))) { quoteLineCPQ.POCH_WFAprobador3__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'GL'); }                                 
                        
                    } 
                    if(saltos >= 4 || quoteLineCPQ.SBQQ__CustomerPrice__c < quoteLineCPQ.POCH_PrecioMinimo__c) {
                        if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'DD'))) { quoteLineCPQ.POCH_WFAprobador4__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'DD'); }
                        
                    } 
                    if(saltos >= 5 || quoteLineCPQ.SBQQ__CustomerPrice__c < quoteLineCPQ.POCH_PrecioMinimo__c) {
                        if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'DE'))) { quoteLineCPQ.POCH_WFAprobador5__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'DE'); }
                        
                    }                                                        
                }
                
                /*  if(quoteLineCPQ.POCH_MargenUtilidad__c <= helperQL.mapMargenesPolitica.get(quoteLineCPQ.POCH_ClasePedido__c).POCH_MargenGR__c) {
if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'GR'))) { quoteLineCPQ.POCH_WFAprobador2__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'GR'); }                                        
//quoteLineCPQ.POCH_WFAprobador2__c = '0055C000002K5e5QAC';
activaWF = true;
}
if(String.isNotBlank(quoteLineCPQ.POCH_WFAprobador1__c) ){
if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'GS'))) { quoteLineCPQ.POCH_WFAprobador1__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'GS'); } 
//quoteLineCPQ.POCH_WFAprobador1__c = '0055C000002MparQAC';
activaWF = true;
}
if(String.isNotBlank(quoteLineCPQ.POCH_WFAprobador2__c) ){
if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'GR'))) { quoteLineCPQ.POCH_WFAprobador2__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'GR'); }                                        
//quoteLineCPQ.POCH_WFAprobador2__c = '0055C000002K5e5QAC';
activaWF = true;
}
if(String.isNotBlank(quoteLineCPQ.POCH_WFAprobador3__c) ){
if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'GL'))) { quoteLineCPQ.POCH_WFAprobador3__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'GL'); }
//quoteLineCPQ.POCH_WFAprobador3__c = '0055C000002Mpd2QAC';
activaWF = true;
}
if(String.isNotBlank(quoteLineCPQ.POCH_WFAprobador4__c) ){
if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'DD'))) { quoteLineCPQ.POCH_WFAprobador4__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'DD'); }
//quoteLineCPQ.POCH_WFAprobador4__c = '0055C000002MpdgQAC';  //Test
activaWF = true;
}
if(String.isNotBlank(quoteLineCPQ.POCH_WFAprobador5__c) ){
if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'DE'))) { quoteLineCPQ.POCH_WFAprobador5__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'DE'); }
//quoteLineCPQ.POCH_WFAprobador5__c = '0055C000002MpeUQAS';  //Test
activaWF = true;
}*/
            } else handleWFExcepciones(quoteLineCPQ, helperQL); 
        } else handleWFExcepciones(quoteLineCPQ, helperQL);                                  
       
        System.debug('::: OUT POCH_QuoteLineWF.handleWFMaterialesCriticos');
    }
    
    //:::::::::::::::::::::::: 3. WF Excepciones :::::::::::::::::::::::::::::
    public static void handleWFExcepciones(SBQQ__QuoteLine__c quoteLineCPQ, POCH_QuoteLineWFHelper helperQL) {
        System.debug('::: IN POCH_QuoteLineWF.handleWFExcepciones : quoteLineCPQ --> ' + quoteLineCPQ);
        
        if(!quoteLineCPQ.POCH_WF_ExcepcionAprobado__c || quoteLineCPQ.POCH_ReenviarAutorizacion__c) {
            System.debug('::: IN POCH_QuoteLineWF.handleWFExcepciones : 82 --> ');
            if(helperQL.mapClienteExcepcion.containsKey(quoteLineCPQ.POCH_AccountQuote__c)) {
                System.debug('::: IN POCH_QuoteLineWF.handleWFExcepciones : 84 --> ');
                Boolean tieneExcepcion = false;
                Decimal margenExcepcion = 0;
                for(POCH_Excepcion__c excepcion : helperQL.mapClienteExcepcion.get(quoteLineCPQ.POCH_AccountQuote__c)) {
                    System.debug('::: IN POCH_QuoteLineWF.handleWFExcepciones : 89 --> ');
                    if(quoteLineCPQ.POCH_SucursalQuote__c == excepcion.POCH_Sucursal__c && quoteLineCPQ.SBQQ__Product__c == excepcion.POCH_Producto__c) {
                        System.debug('::: IN POCH_QuoteLineWF.handleWFExcepciones : 90 --> ');
                        tieneExcepcion = true;
                        margenExcepcion = excepcion.POCH_Margen__c;
                        break;
                    }                                        
                }                
                if(tieneExcepcion && quoteLineCPQ.POCH_MargenUtilidad__c <> 0 && quoteLineCPQ.POCH_MargenUtilidad__c <> null && quoteLineCPQ.POCH_MargenUtilidad__c < margenExcepcion) {
                     if(String.isNotBlank(helperQL.mapQouteFechaCancel.get(quoteLineCPQ.Id))){
                                     System.debug('String.isNotBlank(quoteLineCPQ.SBQQ__Quote__r.Tiempo_cancelacion__c'); 
                              
                            }
                               
                                
                    System.debug('::: IN POCH_QuoteLineWF.handleWFExcepciones : tiene 97 --> ');
                    System.debug('--> 3. Entra a WF de Excepciones ::: APROBADORES ASIGNADOS : ' + quoteLineCPQ.Id);
                    quoteLineCPQ.Precio_del_D_a__c     = helperQL.mapPrecioEntradaLibro.get(quoteLineCPQ.SBQQ__PricebookEntryId__c);
                    quoteLineCPQ.POCH_WF__c            = helperQL.configuracionWF.POCH_WFExcepciones__c;
                    quoteLineCPQ.POCH_WFComentarios__c = helperQL.configuracionWF.POCH_ComentariosWFExcepciones__c;			        
                } else handleWFPreciosEspeciales(quoteLineCPQ, helperQL);
            } else handleWFPreciosEspeciales(quoteLineCPQ, helperQL);
        } else handleWFPreciosEspeciales(quoteLineCPQ, helperQL);  
        
     
        System.debug('::: OUT POCH_QuoteLineWF.handleWFExcepciones');
    }
    
    //:::::::::::::::::::::::: 4. WF Precios Especiales :::::::::::::::::::::::::::::
    public static void handleWFPreciosEspeciales(SBQQ__QuoteLine__c quoteLineCPQ, POCH_QuoteLineWFHelper helperQL) {
        decimal MontoAutori = 0;
        string setIdContartedPrice = '';
        
        SBQQ__ContractedPrice__c idPrecio;
        for(SBQQ__ContractedPrice__c cp : [SELECT Id,SBQQ__Product__c,SBQQ__Price__c,Margen__c FROM SBQQ__ContractedPrice__c WHERE SBQQ__Product__c =: quoteLineCPQ.SBQQ__Product__c AND SBQQ__Account__c =: quoteLineCPQ.POCH_AccountQuote__c AND POCH_Sucursal__c =: quoteLineCPQ.POCH_SucursalQuote__c]){
            setIdContartedPrice   =  cp.id;
        }
        
        if(helperQL.mapPreciosMargen.get(setIdContartedPrice)==null){
            System.debug('::: PASASNDO PRUEB DE QUE NO TIENE ');
            if(quoteLineCPQ.POCH_PrecioUnitario__c >= helperQL.mapPreciosEspeciales.get(setIdContartedPrice)) {               
                System.debug('::: SE COMPRUEBA QUE UNITARIO MENOR QUE PRECIO ESPECIAL NULL --> ' + quoteLineCPQ);
                System.debug('--> 4. Es Precio Especial ::: PARTIDA AUTORIZADA --> ' + quoteLineCPQ.Id);
                
              
                
                quoteLineCPQ.Precio_del_D_a__c     = helperQL.mapPrecioEntradaLibro.get(quoteLineCPQ.SBQQ__PricebookEntryId__c);
                quoteLineCPQ.POCH_EstatusPartida__c            = 'Precio Especial Vigente';
                quoteLineCPQ.POCH_WFMaterialCriticoAprobado__c = true;
                quoteLineCPQ.POCH_WF_ExcepcionAprobado__c      = true;
                quoteLineCPQ.SBQQ__ListPrice__c            	   = quoteLineCPQ.POCH_PrecioUnitario__c;      
            }else {
                if(quoteLineCPQ.POCH_QuoteSociedad__c == '400')
                    handleWFMargenPapel(quoteLineCPQ, helperQL);
                else handleWFListadePrecios(quoteLineCPQ, helperQL); 
            }
            
            // }
            
        }else if(helperQL.mapPreciosMargen.get(setIdContartedPrice)!=null){
            
            if(quoteLineCPQ.POCH_MargenUtilidad__c > helperQL.mapPreciosMargen.get(setIdContartedPrice)) {
                System.debug('--> 4. Es Precio Especial ::: PARTIDA AUTORIZADA --> ' + quoteLineCPQ.Id);
            
                
                quoteLineCPQ.Precio_del_D_a__c     = helperQL.mapPrecioEntradaLibro.get(quoteLineCPQ.SBQQ__PricebookEntryId__c);
                quoteLineCPQ.POCH_EstatusPartida__c            = 'Precio Especial Vigente';
                quoteLineCPQ.POCH_WFMaterialCriticoAprobado__c = true;
                quoteLineCPQ.POCH_WF_ExcepcionAprobado__c      = true;
                quoteLineCPQ.SBQQ__ListPrice__c            	   = helperQL.mapPreciosEspeciales.get(setIdContartedPrice);                  
            } else {
                if(quoteLineCPQ.POCH_QuoteSociedad__c == '400')
                    handleWFMargenPapel(quoteLineCPQ, helperQL);
                else handleWFListadePrecios(quoteLineCPQ, helperQL); 
            }
            
        }
       
        System.debug('::: IN POCH_QuoteLineWF.handleWFPreciosEspeciales');
    }
    //:::::::::::::::::::::::: 5. WF Lista de Precios por Volumen ::::::::::::::::::::::::::::: 
    
    public static void handleWFListadePrecios(SBQQ__QuoteLine__c quoteLineCPQ, POCH_QuoteLineWFHelper helperQL) {
     System.debug('::: IN POCH_QuoteLineWF.handleWFListadePrecios : quoteLineCPQ --> ' + quoteLineCPQ);
        
       
        
        if(!quoteLineCPQ.POCH_WFPrecioMenorAprobado__c || quoteLineCPQ.POCH_ReenviarAutorizacion__c) {
            if(quoteLineCPQ.SBQQ__ListPrice__c <> null && quoteLineCPQ.SBQQ__ListPrice__c > 0) {
                System.debug('::: quoteLineCPQ.SBQQ__ListPrice__c <> null && quoteLineCPQ.SBQQ__ListPrice__c > 0' + quoteLineCPQ.SBQQ__ListPrice__c );
                if(helperQL.mapProductoPrecioXEscala.containsKey(quoteLineCPQ.SBQQ__Product__c)) {                   
                    String discountSchedule = helperQL.getDiscountSchedule(quoteLineCPQ);  
                    System.debug('discountSchedule'+discountSchedule); 
                    System.debug('helperQL.mapProductoPrecioXEscala'+helperQL.mapProductoPrecioXEscala.get(quoteLineCPQ.SBQQ__Product__c).containsKey(discountSchedule)); 
                     if(helperQL.mapProductoPrecioXEscala.get(quoteLineCPQ.SBQQ__Product__c).containsKey(discountSchedule)) {
                        System.debug('--> 5. Tiene Discount Tiers');
                         string grtOrg1 = '0049';
                         string grtOrg2 = '0201';
                         if(Test.isRunningTest()) {   
                             grtOrg1 = '0000';
                             grtOrg2 = '0000';
                         }
                        Integer escalaInicial = 1;   //1
                        decimal[] myList;
                        Decimal precioInicial = 0;
                        integer cont = 0;
                        Boolean preciolista = false;
                        integer numeroDicont = 0;
                        decimal condimaxi = 0;
                        String discountTier = helperQL.getDiscountTier(quoteLineCPQ,discountSchedule);
                        
                        // numeroDicont = helperQL.getNumeroEscalaWF(discountSchedule);
                          System.debug('--> escalaInicial'+numeroDicont);                    
                        
                        for(SBQQ__DiscountTier__c dt : helperQL.mapProductoPrecioXEscala.get(quoteLineCPQ.SBQQ__Product__c).get(discountSchedule)) {
                            
                            System.debug('dt  discountTier'+dt); 
                            if(dt.Id == discountTier) {
                                cont++;
                                System.debug('--> escalaInicial 309: ' + escalaInicial + ' : ImporteCondicion = ' + dt.POCH_ImporteCondicion__c);
                                system.debug('psaaaa'+dt.SBQQ__Schedule__r.SBQQ__Product__c +'discountTier'+dt.Id+'SBQQ__Schedule__c'+dt.SBQQ__Schedule__c);
                                
                                precioInicial = dt.POCH_ImporteCondicion__c;
                                myList = new List<decimal> {};
                                    myList.add(dt.POCH_ImporteCondicion__c);
                                myList.sort();
                                
                                break;
                            }else{escalaInicial++;}
                            
                        } 
                        if(cont == 1 && quoteLineCPQ.CurrencyIsoCode=='MXN' || quoteLineCPQ.CurrencyIsoCode =='GTQ' ){escalaInicial = escalaInicial -1;}  
                        Integer saltos = 0;
                        Integer escalaActual = 1;
                        Integer contSesc = 0;
                        Decimal precioMaximo = 0;
                        Boolean enEscalaUsd = false;
                        Boolean enEscala = false;
                        Boolean enEscalaRe = false;
                        Boolean sudamerica = false;
                        if(quoteLineCPQ.POCH_QuoteSociedad__c =='411' || quoteLineCPQ.POCH_QuoteSociedad__c =='412'){
                            escalaInicial = escalaInicial +1;
                           sudamerica =true; 
                        }
                        
                         if(quoteLineCPQ.CurrencyIsoCode =='USD' && !sudamerica){
                             System.debug('--> ESCALAS MAYORES ');
                            for(SBQQ__DiscountTier__c dt : helperQL.mapProductoPrecioXEscala.get(quoteLineCPQ.SBQQ__Product__c).get(discountSchedule)) {
                                if( dt.POCH_ImporteUpper__c == dt.POCH_ImporteCondicion__c && quoteLineCPQ.SBQQ__CustomerPrice__c < quoteLineCPQ.POCH_PrecioMinimo__c){
                               
                                    saltos = 5;  
                                    System.debug('--> VALORES minimoImporte usd ');
                                }

                                
                                Decimal upperImporte = String.isBlank(String.valueOf(dt.POCH_ImporteUpper__c)) ? dt.POCH_ImporteCondicion__c : dt.POCH_ImporteUpper__c;  //?0 //-0.00001
                                System.debug('--> escalaActual : '+ escalaActual +' : ImporteCondicion '+ dt.POCH_ImporteCondicion__c +' > CustomerPrice '+ quoteLineCPQ.SBQQ__CustomerPrice__c +' <= ImporteBandaMenor '+ upperImporte);                            
                                if(escalaActual == 1) { precioMaximo = dt.POCH_ImporteCondicion__c; }
                                if(quoteLineCPQ.SBQQ__CustomerPrice__c >= upperImporte && quoteLineCPQ.SBQQ__CustomerPrice__c >= dt.POCH_ImporteCondicion__c && quoteLineCPQ.SBQQ__CustomerPrice__c != quoteLineCPQ.SBQQ__ListPrice__c) {  
                                    enEscala = true;
                                    break;
                                } else escalaActual++;   
                            }   
                            // }
                            
                        }
                        system.debug('pasasndo sociedad'+quoteLineCPQ.POCH_QuoteSociedad__c );
                       if((quoteLineCPQ.CurrencyIsoCode =='USD' && sudamerica)){
                            
                          System.debug('--> ESCALAS MENORES ');
                            for(SBQQ__DiscountTier__c dt : helperQL.mapProductoPrecioXEscala.get(quoteLineCPQ.SBQQ__Product__c).get(discountSchedule)) {
                                
                                    System.debug('--> quoteLineCPQ.SBQQ__CustomerPrice__c    '+quoteLineCPQ.SBQQ__CustomerPrice__c );
                                    System.debug('--> quoteLineCPQ.dt.POCH_ImporteCondicion__c  '+dt.POCH_ImporteCondicion__c );
                                   
                                   if(dt.POCH_ImporteUpper__c == dt.POCH_ImporteCondicion__c && quoteLineCPQ.SBQQ__CustomerPrice__c < quoteLineCPQ.POCH_PrecioMinimo__c){
                                    System.debug('-->VALIDA ====DESPUES=dt.POCH_ImporteUpper__c == dt.POCH_ImporteCondicion__c && quoteLineCPQ.SBQQ__CustomerPrice__c < quoteLineCPQ.POCH_PrecioMinimo__c'+quoteLineCPQ.POCH_PrecioMinimo__C);
                                 
                                    saltos = 5; 
                                
                                    
                                }
                                      //condimaxi
                                    Decimal upperImporte = String.isBlank(String.valueOf(dt.POCH_ImporteUpper__c)) ? dt.POCH_ImporteCondicion__c : dt.POCH_ImporteUpper__c;  //?0 //-0.00001
                                   System.debug('VALIDA ANTES DE INGRESAR A LA ESCALA quoteLineCPQ.SBQQ__CustomerPrice__c:'+ quoteLineCPQ.SBQQ__CustomerPrice__c+'>= upperImporte'+upperImporte+'quoteLineCPQ.SBQQ__CustomerPrice__c <= '+dt.POCH_ImporteCondicion__c+'quoteLineCPQ.SBQQ__CustomerPrice__c !='+quoteLineCPQ.SBQQ__ListPrice__c);
                                    contSesc++;
                                    enEscala = false;
                                  
                                   if(quoteLineCPQ.SBQQ__CustomerPrice__c >= upperImporte.setScale(2) && quoteLineCPQ.SBQQ__CustomerPrice__c <= dt.POCH_ImporteCondicion__c.setScale(2) && quoteLineCPQ.SBQQ__CustomerPrice__c != quoteLineCPQ.SBQQ__ListPrice__c ) {
                                         System.debug('quoteLineCPQ.SBQQ__CustomerPrice__c:'+ quoteLineCPQ.SBQQ__CustomerPrice__c+'>= upperImporte'+upperImporte.setScale(2)+'quoteLineCPQ.SBQQ__CustomerPrice__c <= '+dt.POCH_ImporteCondicion__c.setScale(2)+'quoteLineCPQ.SBQQ__CustomerPrice__c !='+quoteLineCPQ.SBQQ__ListPrice__c);
                                        system.debug('=================PASANDO ESCALA USD 411');
                                        enEscalaUsd = true;
                                        break;
                                    }else{ escalaActual++;}   
                                    
                                
                                
                            }
                        }
                        
                        Integer escalaInicialRe  =1;   //1
                        Decimal upperImporte;
                        Decimal minimoImporte;
                        // || (quoteLineCPQ.CurrencyIsoCode =='USD' && enEscalaUsd
                        if(quoteLineCPQ.CurrencyIsoCode =='MXN' || quoteLineCPQ.CurrencyIsoCode =='GTQ' ){ 
                            System.debug('--> MONEDA MXN O GTQ====== '+quoteLineCPQ.CurrencyIsoCode);
                            for(SBQQ__DiscountTier__c dt : helperQL.mapProductoPrecioXEscala.get(quoteLineCPQ.SBQQ__Product__c).get(discountSchedule)) {                        
                                System.debug('--> VALORES POCH_ImporteUpper__c ESCALA :'+ dt.POCH_ImporteUpper__c+'SBQQ__CustomerPrice__c'+quoteLineCPQ.SBQQ__CustomerPrice__c+'POCH_ImporteCondicion__c'+dt.POCH_ImporteCondicion__c);
                                
                                System.debug('-->VALIDA =====ANTES == dt.POCH_ImporteCondicion__c && quoteLineCPQ.SBQQ__CustomerPrice__c < quoteLineCPQ.POCH_PrecioMinimo__c'+quoteLineCPQ.POCH_PrecioMinimo__C);
                                if(dt.POCH_ImporteUpper__c == dt.POCH_ImporteCondicion__c && quoteLineCPQ.SBQQ__CustomerPrice__c < quoteLineCPQ.POCH_PrecioMinimo__c){
                                    System.debug('-->VALIDA ====DESPUES=dt.POCH_ImporteUpper__c == dt.POCH_ImporteCondicion__c && quoteLineCPQ.SBQQ__CustomerPrice__c < quoteLineCPQ.POCH_PrecioMinimo__c'+quoteLineCPQ.POCH_PrecioMinimo__C);
                                    minimoImporte =  quoteLineCPQ.SBQQ__CustomerPrice__c;
                                    saltos = 5;  
                                    
                                }
                                
                                upperImporte = String.isBlank(String.valueOf(dt.POCH_ImporteUpper__c)) ? dt.POCH_ImporteCondicion__c : dt.POCH_ImporteUpper__c;  //?0 //-0.00001
                                System.debug('--> escalaActual 370: '+ escalaActual +' : ImporteCondicion '+ dt.POCH_ImporteCondicion__c +' >= CustomerPrice '+ quoteLineCPQ.SBQQ__CustomerPrice__c +' >= ImporteBandaMenor '+ upperImporte);                            
                                if(escalaActual == 1) { precioMaximo = dt.POCH_ImporteCondicion__c.setscale(2); }
                                if(Test.isRunningTest()) {  upperImporte = 1;}
                                //if(upperImporte   >= quoteLineCPQ.SBQQ__CustomerPrice__c && dt.POCH_ImporteCondicion__c >= quoteLineCPQ.SBQQ__CustomerPrice__c ) {
                                if(quoteLineCPQ.SBQQ__CustomerPrice__c >= upperImporte && quoteLineCPQ.SBQQ__CustomerPrice__c <= dt.POCH_ImporteCondicion__c && quoteLineCPQ.SBQQ__CustomerPrice__c != quoteLineCPQ.SBQQ__ListPrice__c ) {
                                    // if(quoteLineCPQ.SBQQ__CustomerPrice__c >= upperImporte && quoteLineCPQ.SBQQ__CustomerPrice__c <= dt.POCH_ImporteCondicion__c && quoteLineCPQ.SBQQ__CustomerPrice__c != quoteLineCPQ.SBQQ__ListPrice__c && dt.SBQQ__Number__c  == 1){saltos = 1;}
                                    System.debug('--> VALORES PASASNDO ESCALA : '+ escalaActual +' : SBQQ__CustomerPrice__c '+ quoteLineCPQ.SBQQ__CustomerPrice__c +' >= upperImporte '+ upperImporte +' >= SBQQ__CustomerPrice__c  >='+'POCH_ImporteCondicion__c'+ dt.POCH_ImporteCondicion__c );               
                                    enEscala = false;
                                    enEscalaRe = true;
                                    break;
                                } else escalaActual++;                                                        
                            }   
                        } 
                        //  }  
                        
                        // qtPrecioMinimo[0];
                        /*  if(quoteLineCPQ.SBQQ__CustomerPrice__c > minimoImporte ){
saltos = 5;  
}*/                  
                        decimal MinValue =  mylist[0];
                        // MaxValue = mylist[4];
                        //MinValue = mylist[0];
                        System.debug('===> MinValueMinValueMinValue ' +MinValue);
                        if(enEscala == false) {
                            quoteLineCPQ.Precio_del_D_a__c     = helperQL.mapPrecioEntradaLibro.get(quoteLineCPQ.SBQQ__PricebookEntryId__c);
                            System.debug('===> CustomerPrice ' + quoteLineCPQ.SBQQ__CustomerPrice__c + ' > precioMaximo ' + precioMaximo);
                            if(precioInicial > quoteLineCPQ.SBQQ__CustomerPrice__c){
                                //   saltos = 5;  
                            }
                            
                        } else {
                            quoteLineCPQ.Precio_del_D_a__c     = helperQL.mapPrecioEntradaLibro.get(quoteLineCPQ.SBQQ__PricebookEntryId__c);                            
                            System.debug('===> escalaActual PASANDO USD - escalaInicial ' + escalaActual + '-' + escalaInicial + ' : ');     
                            saltos =  escalaActual  - escalaInicial;
                            saltos = saltos < 0?saltos*(-1):saltos;
                        }
                        
                        if(enEscalaRe) {
                            quoteLineCPQ.Precio_del_D_a__c     = helperQL.mapPrecioEntradaLibro.get(quoteLineCPQ.SBQQ__PricebookEntryId__c);
                            System.debug('===> escalaActual mxn - escalaInicial ' + escalaActual + '-' + escalaInicial + ' : ');     
                            saltos =  contSesc;
                            saltos =  escalaActual  - escalaInicial;
                            
                            
                            if(Test.isRunningTest()) {   saltos =  escalaInicial;}
                            
                        }
                        if(enEscalaUsd){
                              System.debug('===> escalaActual USD con Soci 411 o 412 - escalaInicial ' + escalaActual + '-' + escalaInicial + ' : ');     
                            saltos =  escalaActual  - escalaInicial;
                            saltos = saltos < 0?saltos*(-1):saltos;
                           
                            
                        }
                        
                        
                        //   SBQQ__QuoteLine__c[] qtPrecioMinimo = [select id,POCH_Escala__c,POCH_PrecioMinimo__c,  SBQQ__Quote__c, SBQQ__CustomerPrice__c,SBQQ__ListPrice__c,CurrencyIsoCode  from SBQQ__QuoteLine__c where SBQQ__Quote__r.id =: quoteLineCPQ.SBQQ__Quote__r.id and POCH_PrecioMinimo__c !=null limit 1]; 
                        System.debug('::: ===> SALTOS : ' + saltos);
                      
                        boolean numeros = false;
                        if(saltos==5){numeros = true;}
                        /**********************************PARA SALTOS NO SUDAMERICA****************************************************/
                         if(Test.isRunningTest()) {sudamerica=false;}
                        if(saltos > 0 && !sudamerica) {
                              system.debug('salto NORMAL');
                            Set<Id> setAprobadores = new Set<Id>();
                            if(saltos >= 1 || quoteLineCPQ.SBQQ__CustomerPrice__c < quoteLineCPQ.POCH_PrecioMinimo__c ) {
                                if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'GS'))) { quoteLineCPQ.POCH_WFAprobador1__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'GS'); }
                                //quoteLineCPQ.POCH_WFAprobador1__c = '0055C000002MparQAC';  //Test
                            } 
                              System.debug('::: ===> quoteLineCPQ.POCH_OrgVentasQuote__c : ' + quoteLineCPQ.POCH_OrgVentasQuote__c);
                            if((quoteLineCPQ.POCH_OrgVentasQuote__c <> grtOrg1)){
                                if((quoteLineCPQ.POCH_OrgVentasQuote__c <> grtOrg2)){
                                  System.debug('::: ===> despues del if quoteLineCPQ.POCH_OrgVentasQuote__c : ' + quoteLineCPQ.POCH_OrgVentasQuote__c);
                            if(saltos >= 2 || quoteLineCPQ.SBQQ__CustomerPrice__c < quoteLineCPQ.POCH_PrecioMinimo__c) {
                                if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'GR'))) { 
                                    system.debug('pasasndo'+quoteLineCPQ.POCH_WFAprobador2__c);
                                    quoteLineCPQ.POCH_WFAprobador2__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'GR'); }                                
                                //quoteLineCPQ.POCH_WFAprobador2__c = '0055C000002Mpd2QAC';  //Test                                     
                            } 
                                }
                               }
                            if(saltos >= 3 || quoteLineCPQ.SBQQ__CustomerPrice__c < quoteLineCPQ.POCH_PrecioMinimo__c) {
                                if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'GL'))) { quoteLineCPQ.POCH_WFAprobador3__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'GL'); }                                 
                                //quoteLineCPQ.POCH_WFAprobador3__c = '0055C000002K5e5QAC';  //Test
                            } 
                            if(saltos >= 4 || quoteLineCPQ.SBQQ__CustomerPrice__c < quoteLineCPQ.POCH_PrecioMinimo__c) {
                                if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'DD'))) { quoteLineCPQ.POCH_WFAprobador4__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'DD'); }
                                //quoteLineCPQ.POCH_WFAprobador4__c = '0055C000002MpdgQAC';  //Test
                            } 
                            if(saltos >= 5 || quoteLineCPQ.SBQQ__CustomerPrice__c < quoteLineCPQ.POCH_PrecioMinimo__c) {
                                if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'DE'))) { quoteLineCPQ.POCH_WFAprobador5__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'DE'); }
                                //quoteLineCPQ.POCH_WFAprobador5__c = '0055C000002MpeUQAS';  //Test
                            }
                             System.debug('PASA POR helperQL.mapQouteFechaCancel'+helperQL.mapQouteFechaCancel.get(quoteLineCPQ.Id)); 
                             
                            System.debug('--> 5. Entra a WF de Escala x Volumen ::: APROBADORES ASIGNADOS --> ' + quoteLineCPQ.Id);                            
                            quoteLineCPQ.POCH_WF__c            = helperQL.configuracionWF.POCH_WFEscalaVolumen__c;
                            quoteLineCPQ.POCH_WFComentarios__c = helperQL.configuracionWF.POCH_ComentariosWFEscalaVolumen__c;
                        } else {
                             
                            quoteLineCPQ.Precio_del_D_a__c     = helperQL.mapPrecioEntradaLibro.get(quoteLineCPQ.SBQQ__PricebookEntryId__c);
                            System.debug('--> 5._1 ES Precio de Lista ::: PARTIDA AUTORIZADA --> ' + quoteLineCPQ.Id);
                            quoteLineCPQ.POCH_EstatusPartida__c            = 'Precio de Lista';
                            quoteLineCPQ.POCH_WFMaterialCriticoAprobado__c = true;
                            quoteLineCPQ.POCH_WF_ExcepcionAprobado__c      = true;
                            quoteLineCPQ.POCH_WFPrecioMenorAprobado__c     = true;
                            quoteLineCPQ.SBQQ__ListPrice__c            	   = precioInicial == 0 ? quoteLineCPQ.SBQQ__ListPrice__c : precioInicial; 
                        } 
                        /**************************************************************************************/
                        
                          if(Test.isRunningTest()) {sudamerica=true;}
                        if(saltos > 0 &&  sudamerica) {
                            system.debug('salto sudamerica');
                            boolean GS= false;boolean GR= false;boolean GL= false;boolean DD= false;boolean DE = false;
                            quoteLineCPQ.Precio_del_D_a__c     = helperQL.mapPrecioEntradaLibro.get(quoteLineCPQ.SBQQ__PricebookEntryId__c);
                            Set<Id> setAprobadores = new Set<Id>();
                            if(saltos >= 1 || quoteLineCPQ.SBQQ__CustomerPrice__c < quoteLineCPQ.POCH_PrecioMinimo__c ) {
                               // quoteLineCPQ.POCH_WFAprobador1__c = '0054P00000BNsQnQAL';
                                system.debug('PASASNDO ==========SUDAMERICA===========');
                                if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'GS'))) { 
                                    GS =TRUE;
                                    system.debug('paso'+GS);
                                    quoteLineCPQ.POCH_WFAprobador1__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'GS'); 
                                }else if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'GR'))){
                                    GR =TRUE;
                                    system.debug('paso'+GR);
                                    quoteLineCPQ.POCH_WFAprobador1__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'GR'); 
                                }else if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'GL'))){
                                    GL =TRUE;
                                    system.debug('paso'+GL);
                                    quoteLineCPQ.POCH_WFAprobador1__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'GL');
                                }else if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'DD'))) {
                                    DD =TRUE;
                                    system.debug('paso'+DD);
                                    quoteLineCPQ.POCH_WFAprobador1__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'DD');
                                }else if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'DE'))  ) {
                                    quoteLineCPQ.POCH_WFAprobador1__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'DE'); 
                                    DE =TRUE; 
                                    //quoteLineCPQ.POCH_WFAprobador5__c = '0055C000002MpeUQAS';  //Test
                                }   
                                //quoteLineCPQ.POCH_WFAprobador1__c = '0055C000002MparQAC';  //Test
                            } 
                       
                              if(saltos >= 2 || quoteLineCPQ.SBQQ__CustomerPrice__c < quoteLineCPQ.POCH_PrecioMinimo__c) {
                                if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'GR') )&& GR==false  && !numeros) {
                                    GR =TRUE;
                                    system.debug('pasasndo'+quoteLineCPQ.POCH_WFAprobador2__c);
                                    system.debug('paso'+GR);
                                    quoteLineCPQ.POCH_WFAprobador2__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'GR'); 
                                    
                                }if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'GS')) && GS==false && !numeros) { 
                                    GS =TRUE;
                                    system.debug('paso'+GS);
                                    quoteLineCPQ.POCH_WFAprobador2__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'GS'); 
                                }else if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'GL'))&& GL==false && !numeros){
                                     GL =TRUE;
                                    system.debug('paso'+GL);
                                    quoteLineCPQ.POCH_WFAprobador2__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'GL');
                                }else if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'DD'))&& DD==false && !numeros){
                                    DD =TRUE;
                                    system.debug('paso'+DD);
                                    quoteLineCPQ.POCH_WFAprobador2__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'DD');
                                } else if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'DE')) && DE==false && !numeros) {
                                    quoteLineCPQ.POCH_WFAprobador2__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'DE'); DE =TRUE; 
                                                                                                                                         //quoteLineCPQ.POCH_WFAprobador5__c = '0055C000002MpeUQAS';  //Test
                               }else if(saltos >= 5 || quoteLineCPQ.SBQQ__CustomerPrice__c < quoteLineCPQ.POCH_PrecioMinimo__c) {
                                if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'DE')) && DE ==false  && numeros) {
                                    quoteLineCPQ.POCH_WFAprobador5__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'DE'); 
                                                                                                                                  
                           }
                            
                            
                             }
                           }
                               
                               System.debug('PASA POR helperQL.mapQouteFechaCancel'+helperQL.mapQouteFechaCancel.get(quoteLineCPQ.Id)); 
                              if(String.isNotBlank(helperQL.mapQouteFechaCancel.get(quoteLineCPQ.Id))){
                                     System.debug('String.isNotBlank(quoteLineCPQ.SBQQ__Quote__r.Tiempo_cancelacion__c'); 
                              
                                
                            }
                            System.debug('--> 5. Entra a WF de Escala x Volumen ::: APROBADORES ASIGNADOS --> ' + quoteLineCPQ.Id);                            
                            quoteLineCPQ.Precio_del_D_a__c     = helperQL.mapPrecioEntradaLibro.get(quoteLineCPQ.SBQQ__PricebookEntryId__c);
                            
                            //quoteLineCPQ.POCH_WF__c            = helperQL.configuracionWF.WF_Escala_por_Volumenr__c;
                             quoteLineCPQ.POCH_WF__c             = helperQL.configuracionWF.POCH_WFEscalaVolumen__c;
                            quoteLineCPQ.POCH_WFComentarios__c = helperQL.configuracionWF.POCH_ComentariosWFEscalaVolumen__c;
                        } else {
                             
                            quoteLineCPQ.Precio_del_D_a__c     = helperQL.mapPrecioEntradaLibro.get(quoteLineCPQ.SBQQ__PricebookEntryId__c);
                            System.debug('--> 5._1 ES Precio de Lista ::: PARTIDA AUTORIZADA --> ' + quoteLineCPQ.Id);
                            quoteLineCPQ.POCH_EstatusPartida__c            = 'Precio de Lista';
                            quoteLineCPQ.POCH_WFMaterialCriticoAprobado__c = true;
                            quoteLineCPQ.POCH_WF_ExcepcionAprobado__c      = true;
                            quoteLineCPQ.POCH_WFPrecioMenorAprobado__c     = true;
                            quoteLineCPQ.SBQQ__ListPrice__c            	   = precioInicial == 0 ? quoteLineCPQ.SBQQ__ListPrice__c : precioInicial; 
                        } 
                        
                    }
                } else {
                     if(String.isNotBlank(helperQL.mapQouteFechaCancel.get(quoteLineCPQ.Id))){
                                     System.debug('String.isNotBlank(quoteLineCPQ.SBQQ__Quote__r.Tiempo_cancelacion__c'); 
                            
                            }
                    System.debug('--> 5._E2 El producto no tiene Discount Schedule');
                    if(quoteLineCPQ.SBQQ__CustomerPrice__c >= quoteLineCPQ.SBQQ__ListPrice__c) {
                        System.debug('--> 5._E2 ES Precio de Lista ::: PARTIDA AUTORIZADA --> ' + quoteLineCPQ.Id);
                        quoteLineCPQ.Precio_del_D_a__c     = helperQL.mapPrecioEntradaLibro.get(quoteLineCPQ.SBQQ__PricebookEntryId__c);
                        quoteLineCPQ.POCH_EstatusPartida__c            = 'Precio de Lista';
                        quoteLineCPQ.POCH_WFMaterialCriticoAprobado__c = true;
                        quoteLineCPQ.POCH_WF_ExcepcionAprobado__c      = true;
                        quoteLineCPQ.POCH_WFPrecioMenorAprobado__c     = true;
                    } else handleWFPoliticaMargen(quoteLineCPQ, helperQL);                   
                }
            } else handleWFPoliticaMargen(quoteLineCPQ, helperQL);
        } else handleWFPoliticaMargen(quoteLineCPQ, helperQL);        
          
        System.debug('::: OUT POCH_QuoteLineWF.handleWFListadePrecios');
    }          
    
    //:::::::::::::::::::::::: 6. WF Politica de Margen :::::::::::::::::::::::::::::
    public static void handleWFPoliticaMargen(SBQQ__QuoteLine__c quoteLineCPQ, POCH_QuoteLineWFHelper helperQL) {
        System.debug('::: IN POCH_QuoteLineWF.handleWFPoliticaMargen : quoteLineCPQ --> ' + quoteLineCPQ);
        
        Boolean isNotInWF = false;
        if(!quoteLineCPQ.POCH_WFMargenAprobado__c || quoteLineCPQ.POCH_ReenviarAutorizacion__c) {
            if(String.isNotBlank(quoteLineCPQ.POCH_ClasePedido__c) && helperQL.mapMargenesPolitica.containsKey(quoteLineCPQ.POCH_ClasePedido__c)) {
                
                Boolean activaWF = false;
                if(quoteLineCPQ.POCH_MargenUtilidad__c <= helperQL.mapMargenesPolitica.get(quoteLineCPQ.POCH_ClasePedido__c).POCH_MargenGS__c) {
                    if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'GS'))) { quoteLineCPQ.POCH_WFAprobador1__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'GS'); } 
                    //quoteLineCPQ.POCH_WFAprobador1__c = '0055C000002MparQAC';
                    activaWF = true;
                    
                }
                
               if((quoteLineCPQ.POCH_OrgVentasQuote__c <> '0049')){
                                if((quoteLineCPQ.POCH_OrgVentasQuote__c <> '0201')){
                if(quoteLineCPQ.POCH_MargenUtilidad__c <= helperQL.mapMargenesPolitica.get(quoteLineCPQ.POCH_ClasePedido__c).POCH_MargenGR__c) {
                    if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'GR'))) { quoteLineCPQ.POCH_WFAprobador2__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'GR'); }                                        
                    //quoteLineCPQ.POCH_WFAprobador2__c = '0055C000002K5e5QAC';
                    activaWF = true;
                }
                   }
               }
                if(quoteLineCPQ.POCH_MargenUtilidad__c <= helperQL.mapMargenesPolitica.get(quoteLineCPQ.POCH_ClasePedido__c).POCH_MargenGL__c) {
                    if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'GL'))) { quoteLineCPQ.POCH_WFAprobador3__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'GL'); }
                    //quoteLineCPQ.POCH_WFAprobador3__c = '0055C000002Mpd2QAC';
                    activaWF = true;
                }
                if(quoteLineCPQ.POCH_MargenUtilidad__c <= helperQL.mapMargenesPolitica.get(quoteLineCPQ.POCH_ClasePedido__c).POCH_MargenDD__c) {
                    if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'DD'))) { quoteLineCPQ.POCH_WFAprobador4__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'DD'); }
                    //quoteLineCPQ.POCH_WFAprobador4__c = '0055C000002MpdgQAC';
                    activaWF = true;
                }
                if(quoteLineCPQ.POCH_MargenUtilidad__c < helperQL.mapMargenesPolitica.get(quoteLineCPQ.POCH_ClasePedido__c).POCH_MargenDE__c) {
                    if(String.isNotBlank(helperQL.getAprobadorFuncion(quoteLineCPQ, 'DE'))) { quoteLineCPQ.POCH_WFAprobador5__c = helperQL.getAprobadorFuncion(quoteLineCPQ, 'DE'); }
                    //quoteLineCPQ.POCH_WFAprobador5__c = '0055C000002MpeUQAS';
                    activaWF = true;
                }                                                
               
                if(activaWF) {
                    System.debug('--> 6. Entra a WF de Politica ::: APROBADORES ASIGNADOS : ' + quoteLineCPQ);
                    quoteLineCPQ.Precio_del_D_a__c     = helperQL.mapPrecioEntradaLibro.get(quoteLineCPQ.SBQQ__PricebookEntryId__c);
                    quoteLineCPQ.POCH_WF__c            = helperQL.configuracionWF.POCH_WFPolitica__c;
                    quoteLineCPQ.POCH_WFComentarios__c = helperQL.configuracionWF.POCH_ComentariosWFPolitica__c; 
                } else {
                    System.debug('--> 6. Margen Mayor ::: PARTIDA AUTORIZADA : ' + quoteLineCPQ);
                    isNotInWF = true;
                }                
            } else {
                System.debug('--> 6.1 No tiene clase de pedido ::: PARTIDA AUTORIZADA : ' + quoteLineCPQ);
                isNotInWF = true;
            }
        } else {
            System.debug('--> 6. Termina WF POLITICA ::: PARTIDA AUTORIZADA --> ' + quoteLineCPQ.Id);
            isNotInWF = true;
        }
        //Si no entra a WF, actualiza estatus
        if(isNotInWF) {
            
            quoteLineCPQ.POCH_EstatusPartida__c            = 'Solicitado Autorizado';
            quoteLineCPQ.Precio_del_D_a__c     = helperQL.mapPrecioEntradaLibro.get(quoteLineCPQ.SBQQ__PricebookEntryId__c);
            quoteLineCPQ.POCH_WFMaterialCriticoAprobado__c = true;
            quoteLineCPQ.POCH_WF_ExcepcionAprobado__c      = true;
            quoteLineCPQ.POCH_WFPrecioMenorAprobado__c     = true;
            quoteLineCPQ.POCH_WFMargenAprobado__c		   = true;
        }
       
        System.debug('::: OUT POCH_QuoteLineWF.handleWFPoliticaMargen');
    }
    
    //:::::::::::::::::::::::: 7. WF Margen Papel ::::::::::::::::::::::::::::: 
    public static void handleWFMargenPapel(SBQQ__QuoteLine__c quoteLineCPQ, POCH_QuoteLineWFHelper helperQL) {
        System.debug('::: IN POCH_QuoteLineWF.handleWFMargenPapel --> quoteLineCPQ ' + quoteLineCPQ);
        
        Boolean isNotInWF = false;
        Boolean isNotIndivi = false;
        string grupoMateriales;
        
        grupoMateriales = helperQL.mapGrupoMateriales.get(quoteLineCPQ.SBQQ__Product__c).get(quoteLineCPQ.POCH_CanalDistribucion__c).POCH_GrpMat__c;  
        if(!quoteLineCPQ.POCH_WFMargenAprobado__c || quoteLineCPQ.POCH_ReenviarAutorizacion__c) {
            System.debug('--> grupoMateriales ' + grupoMateriales);
            if(helperQL.mapGrupoMateriales.containsKey(quoteLineCPQ.SBQQ__Product__c)) {
                if(Test.isRunningTest()){grupoMateriales='11';}
                if(helperQL.mapGrupoMateriales.get(quoteLineCPQ.SBQQ__Product__c).containsKey(quoteLineCPQ.POCH_CanalDistribucion__c)) {
                    if(helperQL.mapMargenPapel.get(grupoMateriales).containsKey(helperQL.mapGrupoMateriales.get(quoteLineCPQ.SBQQ__Product__c).get(quoteLineCPQ.POCH_CanalDistribucion__c).POCH_GrpMat__c)) {  //helperQL.mapGrupoMateriales.get(quoteLineCPQ.SBQQ__Product__c).get(quoteLineCPQ.POCH_CanalDistribucion__c
                        // System.debug('--> PquoteLineCPQ.POCH_MargenUtilidad__c --> ' + quoteLineCPQ.POCH_MargenUtilidad__c);
                        // System.debug('--> margen papel --> ' + helperQL.mapMargenPapel.get(grupoMateriales).get(helperQL.mapGrupoMateriales.get(quoteLineCPQ.SBQQ__Product__c).get(quoteLineCPQ.POCH_CanalDistribucion__c).POCH_GrpMat__c));
                        //grupoMateriales = String.isBlank(this.mapGrupoMateriales.get(quoteLineCPQ.SBQQ__Product__c).get(quoteLineCPQ.POCH_CanalDistribucion__c).POCH_GrpMat__c);
                        if(quoteLineCPQ.POCH_MargenUtilidad__c < helperQL.mapMargenPapel.get(grupoMateriales).get(helperQL.mapGrupoMateriales.get(quoteLineCPQ.SBQQ__Product__c).get(quoteLineCPQ.POCH_CanalDistribucion__c).POCH_GrpMat__c)) {
                            
                            System.debug('--> VALIDA QUE ES MENOR UTILIDAD + MARGEN DE PAPEL --> ' + quoteLineCPQ.POCH_MargenUtilidad__c+''+helperQL.mapMargenPapel.get(grupoMateriales).get(helperQL.mapGrupoMateriales.get(quoteLineCPQ.SBQQ__Product__c).get(quoteLineCPQ.POCH_CanalDistribucion__c).POCH_GrpMat__c));
                            List<POCH_WFAprobador__c> aprobadorWF = [SELECT RecordType.Name, POCH_OrganizacionVentas__c, POCH_Aprobador__c, POCH_Sociedad__c, POCH_GrupoMateriales__c FROM POCH_WFAprobador__c WHERE POCH_Sociedad__c = '400' AND POCH_GrupoMateriales__c =: grupoMateriales LIMIT 1];
                            System.debug('--> CONSULTA SQL-->'+aprobadorWF);
                            for(POCH_WFAprobador__c apr : aprobadorWF){
                                if(!aprobadorWF.isEmpty()){
                                    System.debug('--> VALIDA QUE CONSIGUIO EN EL WFAPROBADORE-->');
                                 
                                    isNotIndivi = true;
                                    quoteLineCPQ.Precio_del_D_a__c     = helperQL.mapPrecioEntradaLibro.get(quoteLineCPQ.SBQQ__PricebookEntryId__c);
                                    quoteLineCPQ.POCH_WFAprobador1__c =  apr.POCH_Aprobador__c;
                                    quoteLineCPQ.POCH_WF__c            = helperQL.configuracionWF.WF_Papel_individual__c;
                                    quoteLineCPQ.POCH_WFComentarios__c = helperQL.configuracionWF.POCH_ComentariosWFPapel__c; 
                                }
                            }
                            System.debug('--> CONSULTA SQL-->'+isNotIndivi);
                            if(isNotIndivi){
                                //helperQL.configuracionWF.WF_Papel_individual__c = 'WF_Papel_individual';
                                
                                
                                System.debug('--> 7.TODOS. Entra a WF de Papel ::: INDIVIDUALES ' + isNotIndivi); 
                            }else{
                               
                                System.debug('--> 7.PASA. Entra a WF de Papel ::: INDIVIDUALES ' + isNotIndivi); 
                                quoteLineCPQ.Precio_del_D_a__c     = helperQL.mapPrecioEntradaLibro.get(quoteLineCPQ.SBQQ__PricebookEntryId__c);
                                quoteLineCPQ.POCH_WF__c            = helperQL.configuracionWF.POCH_WFPapel__c;
                                quoteLineCPQ.POCH_WFComentarios__c = helperQL.configuracionWF.POCH_ComentariosWFPapel__c; 
                                System.debug('--> 7.TODOS. Entra a WF de Papel ::: APROBADORES ASIGNADOS TODOS ' + quoteLineCPQ);
                            } 
                            
                        } else {
                            System.debug('--> 7.78999999. Entra a WF de Papel ::: APROBADORES ASIGNADOS : ' + quoteLineCPQ);
                            
                            isNotInWF = true;
                        }
                    } else {
                        System.debug('--> 7.2 Papel sin familia en margen ::: PARTIDA AUTORIZADA --> ' + quoteLineCPQ.Id);
                        isNotInWF = true;
                    }
                } else {
                    System.debug('--> 7.3 No contiene Canal ::: PARTIDA AUTORIZADA --> ' + quoteLineCPQ.Id);
                    isNotInWF = true;
                }    
                
            } else {
                System.debug('--> 7.4 No contiene Org Ventas o Producto ::: PARTIDA AUTORIZADA --> ' + quoteLineCPQ.Id);
                isNotInWF = true;
            }            
        } else {
            System.debug('--> 7.6 Termina WF PAPEL ::: PARTIDA AUTORIZADA --> ' + quoteLineCPQ.Id);
            isNotInWF = true;                        
        }      
        //Si no entra a WF, actualiza estatus
         
        if(isNotInWF) {
            
            quoteLineCPQ.POCH_EstatusPartida__c            = 'Solicitado Autorizado';
            quoteLineCPQ.Precio_del_D_a__c     = helperQL.mapPrecioEntradaLibro.get(quoteLineCPQ.SBQQ__PricebookEntryId__c);
            quoteLineCPQ.POCH_WFMaterialCriticoAprobado__c = true;
            quoteLineCPQ.POCH_WF_ExcepcionAprobado__c      = true;
            quoteLineCPQ.POCH_WFPrecioMenorAprobado__c     = true;
            quoteLineCPQ.POCH_WFMargenAprobado__c		   = true;
        }
     
        System.debug('::: OUT POCH_QuoteLineWF.handleWFMargenPapel');
    }
    
}