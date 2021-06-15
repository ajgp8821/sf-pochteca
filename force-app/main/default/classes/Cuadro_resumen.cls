public with sharing class Cuadro_resumen {
    
    public List <Clase_Resumen> resumenPedido {get; set;}
    public ApexPages.StandardController vfStandardCtrl;
    public Account account;
    public OrderItem productoPedido;
    public Clase_Resumen ItemStock;
    
    public Cuadro_resumen(ApexPages.StandardController controller) {
        vfStandardCtrl = controller;
        productoPedido = new OrderItem();
        this.productoPedido = (OrderItem)controller.getRecord();
        
        resumenPedido = new List<Clase_Resumen>();
        String theId = ApexPages.currentPage().getParameters().get('id');
        String control = ApexPages.currentPage().getParameters().get('Control_sf__c');
        
        List<OrderItem> itemPedido = [SELECT Id,OrderItemNumber,Control_sf__c,POCH_Almacen__c,AlmacenDeResumen__c FROM OrderItem WHERE id =: productoPedido.Id];
        system.debug(itemPedido);
        
        List<Stock_details__c> detallesInventario = [SELECT Id,Name,POCH_Almacen__c, POCH_Lote__c,Control__c,POCH_Indicador_stock_especial__c,POCH_Numero_stock_especial__c,
                                                     POCH_Indicador_bloqueo_inventario__c,POCH_Stock_valorado_libre_utilizacion__c,Stock_of_matrials__r.Id_Producto_SAP__c,
                                                     Stock_of_matrials__r.Control_Id_SF__c,Stock_of_matrials__r.Name,Unidad_de_Medida__c
                                                     FROM Stock_details__c WHERE Control__c =: itemPedido[0].Control_sf__c];
        system.debug(detallesInventario);
        system.debug(detallesInventario.size());
        
        List <string> loteExistentes = new list<String>();
        
        for(Stock_details__c loteLst : detallesInventario) {  
            //boolean existe = loteExistentes.contains(loteLst.Name);
            //system.debug(existe);
            //if (existe == false){
                //loteExistentes.add(loteLst.Name);
                ItemStock = new Clase_Resumen();
                ItemStock.nombreDetalle = loteLst.Name;
                ItemStock.Id_detalle = loteLst.Id;
                ItemStock.almacenDetalle = loteLst.POCH_Almacen__c;
                ItemStock.loteDetalle = loteLst.POCH_Lote__c;
                ItemStock.cantidadEnLibreUtilizacion = loteLst.POCH_Stock_valorado_libre_utilizacion__c; 
                ItemStock.material = loteLst.Stock_of_matrials__r.Name;
                ItemStock.unidadDeMedidad = loteLst.Unidad_de_Medida__c;
                ItemStock.Id_material = loteLst.Id;    
                
                system.debug(ItemStock);
               
                List<Stock_of_matrials__c> informacionInventario = [SELECT Id,Name,Id_Producto_SAP__c, POCH_Centro__c,Control_Id_SF__c,Unidad_de_Medida__c,stock_ok__c,
                                                                    Cantidad_en_Stock_disponible_SF__c,POCH_Stock_valorado_libre_utilizacion__c,POCH_Cantidad__c,
                                                                    Product__r.name
                                                                    FROM Stock_of_matrials__c WHERE Control_Id_SF__c =: itemPedido[0].Control_sf__c];
                system.debug(informacionInventario); 
                
                for(Stock_of_matrials__c Lst : informacionInventario) { 
                    ItemStock.totalcantidadEnLibreUtilizacion = Lst.POCH_Stock_valorado_libre_utilizacion__c; 
                    ItemStock.cantidadEnOrdenes = Lst.POCH_Cantidad__c; 
                    ItemStock.cantidadEnStock = Lst.Cantidad_en_Stock_disponible_SF__c; 
                }
                
                resumenPedido.add(ItemStock);
                system.debug(resumenPedido);
            //}
        }
        
    }//Llave del Constructor
    
    public class Clase_Resumen {
        public string nombreDetalle{get;set;}
        public Id Id_detalle{get;set;}
        public string almacenDetalle{get;set;}
        public string loteDetalle{get;set;}
        public string material{get;set;}
        public string unidadDeMedidad{get;set;}
        public Id Id_material{get;set;}
        public decimal cantidadEnLibreUtilizacion{get;set;}
        public decimal totalcantidadEnLibreUtilizacion{get;set;}
        public decimal cantidadEnOrdenes{get;set;}
        public decimal cantidadEnStock{get;set;}
        public boolean almacenResumen{get;set;}
    }
    
}//Llave Final