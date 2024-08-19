/************************************************************************
Name: TS4_IS_CalloutConstants
Copyright © 2024 Salesforce
========================================================================
Purpose:
Class used to set type of callout, content type and different types of headers
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      dmarcos@ts4.mx     18/07/2024     INITIAL        DEV CSR:
************************************************************************/
public without sharing  class TS4_IS_CalloutConstants {
    public static final String METHOD_GET  = 'GET';
    public static final String METHOD_POST = 'POST';
    public static final String METHOD_PUT  = 'PUT';
    public static final String METHOD_DELETE  = 'DELETE';
    
    public static final String CONTENT_TYPE_JSON = 'application/json';
    
    public static final String HEADER_AUTHORIZATION = 'Authorization';
    public static final String HEADER_CONTENT_LENGTH = 'Content-Length';
    public static final String HEADER_CONTENT_TYPE = 'Content-Type';
    public static final String HEADER_CLIENT_ID = 'client-id';
    public static final String HEADER_CLIENT_SECRET = 'client-secret';
    public static final String HEADER_SOURCE = 'source';
}