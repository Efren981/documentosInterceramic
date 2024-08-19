public with sharing class TS4_ClienteWrapper {
    public List<Cliente> Clientes;

    public class Cliente {
        public String customerNumber;
        public String Nombres;
        public String Apellidos;
        public String Correo;
        public String fiscalCode;
        public String Estado;
        public String Municipio;
        public String Colonia;
        public String Calle;
        public String Numero_Exterior;
        public String Numero_Interior;
        public String Telefono;
        public String Entre_que_calles;
        public String Pais;
        public Ubicacion Ubicacion;
    }

    public class Ubicacion {
        public String Lugar;
        public Boolean Estacionamiento;
        public String Distancia_aproximada;
        public String Distancia_entrada;
        public String Piso_de_entrega;
        public Boolean Desnivel;
        public Boolean Rampa;
        public String Por_donde_se_subira_el_material;
        public Boolean Escaleras;
    }

    // Método para deserializar el JSON con claves válidas en Apex
    public static TS4_ClienteWrapper deserializeJson(String jsonInput) {
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
        List<Object> clientesList = (List<Object>) jsonMap.get('Clientes');
        
        for (Object clienteObj : clientesList) {
            Map<String, Object> clienteMap = (Map<String, Object>) clienteObj;
            if (clienteMap.containsKey('INT_CP_Fiscal__c')) {
                clienteMap.put('fiscalCode', clienteMap.remove('INT_CP_Fiscal__c'));
            }
        }
        
        String modifiedJson = JSON.serialize(jsonMap);
        return (TS4_ClienteWrapper) JSON.deserialize(modifiedJson, TS4_ClienteWrapper.class);
    }
}