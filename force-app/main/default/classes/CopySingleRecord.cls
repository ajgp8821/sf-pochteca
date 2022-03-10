public class CopySingleRecord {
    
    @AuraEnabled
    public static String copyQuoteSobjet(Id recordId){
        
        Date firstDayOfMonth = System.today().toStartOfMonth();
        System.debug('firstDayOfMonth: '+ firstDayOfMonth);
        Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
        System.debug('lastDayOfMonth: '+ lastDayOfMonth);

        SBQQ__Quote__c quoteOriginal = [SELECT Id,
                                    SBQQ__Account__c,
                                    POCH_Sucursal__c,
                                    POCH_Sucursal_Ampliada__c,
                                    POCH_Sucursal__r.POCH_OrganizacionVentas__c, // obtengo la organización de venta de la Quote
                                    CurrencyIsoCode,
                                    Asunto__c,
                                    Condici_n_de_Pago__c,
                                    POCH_IdOrgVentas__c,
                                    SBQQ__PricebookId__c,
                                    Lead_time__c,
                                    Lugar_de_entrega__c,
                                    Lugarentrega__c,
                                    Medidas_Papel__c,
                                    SBQQ__Notes__c,
                                    POCH_NotasCotizacion__c,
                                    Tiempo_cancelacion__c,
                                    Tiempo_de_entrega__c,
                                    Tiempo_entrega__c,
                                    Tipo_Venta__c,
                                    Tipo_venta_des__c,
                                    Terminos_y_condiciones__c,
                                    POCH_ValidaAutorizaciones__c,
                                    Validezoferta__c 
                                FROM SBQQ__Quote__c 
                                WHERE Id =: recordId];
        
        System.debug('q ' + quoteOriginal.POCH_Sucursal__r.POCH_OrganizacionVentas__c );
        // Validaciones
        String orgVentas = [SELECT Id, name, POCH_OrganizacionesVentas__c  from User where id =: UserInfo.getUserId()].POCH_OrganizacionesVentas__c;
        // String orgVentas = [SELECT Id, name, POCH_OrganizacionesVentas__c  from User where id = '0052i0000021KDfAAM'].POCH_OrganizacionesVentas__c;
        // String orgVentas = [SELECT Id, name, POCH_OrganizacionesVentas__c  from User where id = '0052i000002BTcMAAW'].POCH_OrganizacionesVentas__c;
        system.debug('orgVentas ' + orgVentas);

        Set<String> multiselectValues = new Set<String>();
        multiSelectValues.addAll(orgVentas.split(';'));
        
        // Debe ser el mismo que tiene el usuario
        if(multiSelectValues.contains(quoteOriginal.POCH_Sucursal__r.POCH_OrganizacionVentas__c)){
            System.debug('SI');
            SBQQ__Quote__c quote = quoteOriginal.clone(false, true);
            quote.POCH_EstatusCotizacion__c = 'Abierta';
            quote.Estatus_de_cotizaci_n_anterior__c = 'Abierta';
            quote.SBQQ__StartDate__c = System.today();
            quote.SBQQ__EndDate__c = lastDayOfMonth;
            quote.SBQQ__ExpirationDate__c = lastDayOfMonth;
            quote.SBQQ__Primary__c = false;
            quote.SBQQ__Opportunity2__c = null; // SPANCOP
            quote.Monedaimpresion__c = quote.CurrencyIsoCode;
            quote.Moneda_documento__c = quote.CurrencyIsoCode;
            quote.POCH_FechaEntrega__c = null;
            quote.Impuesto_impreso__c = 0;
            quote.Motivos_de_Cancelaci_n__c = '';
            quote.Valor_Neto_impreso__c = 0;
            quote.Valor_TotalImpreso__c = '';
            
            Database.SaveResult saveQuote = Database.insert(quote, false);

            if (saveQuote.isSuccess() == true){
                return quote.id;
            }
            else {
                return 'error';
            }
        }
        else {
            System.debug('NO');
            return 'errorUser';
        }
    
    }
}
