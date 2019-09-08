//
// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import ballerina/crypto;
import ballerina/encoding;
import ballerina/http;
import ballerina/time;
import ballerina/stringutils;
import ballerina/lang.'array as arrays;

function generateSignature(http:Request request, string accessKeyId, string secretAccessKey, string? securityToken,
                           string region, string httpVerb, string requestURI, string payload,
                           string canonicalQueryString) returns error? {
    string canonicalRequest = "";
    string stringToSign = "";
    string payloadBuilder = "";
    string authHeader = "";
    string amzDateStr = "";
    string shortDateStr = "";
    string signedHeader = "";
    string canonicalHeaders = "";
    string signedHeaders = "";
    string requestPayload = "";
    string encodedrequestURIValue = "";
    string signValue = "";
    string encodedSignValue = "";
    string encodedCanonicalQueryString = "";

    time:Time|error time = time:toTimeZone(time:currentTime(), "UTC");
    if (time is time:Time) {
        string|error amzDate = time:format(time, ISO8601_BASIC_DATE_FORMAT);
        string|error shortDate = time:format(time, SHORT_DATE_FORMAT);
        if (amzDate is string) {
            amzDateStr = amzDate;
        } else {
            return amzDate;
        }
        if (shortDate is string) {
            shortDateStr = shortDate;
        } else {
            return shortDate;
        }
    } else {
        return time;
    }

    request.setHeader(CONTENT_TYPE, APPLICATION_URL_ENCODED);
    request.setHeader(X_AMZ_DATE, amzDateStr);
    if (securityToken is string) {
        request.setHeader(X_AMZ_SECURITY_TOKEN, securityToken);
    }
    string host = SERVICE_NAME + "." + region + "." + "amazonaws.com";
    request.setHeader(HOST,host);

    canonicalRequest = httpVerb;
    canonicalRequest = canonicalRequest + "\n";
    var value = encoding:encodeUriComponent(requestURI, UTF_8);
    if (value is string) {
        encodedrequestURIValue = value;
    } else {
        error err = error(AMAZONEC2_ERROR_CODE, message = "Error occurred when converting to int");
        panic err;
    }
    encodedrequestURIValue = stringutils:replace(encodedrequestURIValue, "%2F", "/");
    canonicalRequest = canonicalRequest + encodedrequestURIValue;
    canonicalRequest = canonicalRequest + "\n";
    var canonicalValue = encoding:encodeUriComponent(canonicalQueryString, UTF_8);
    if (canonicalValue is string) {
        encodedCanonicalQueryString = canonicalValue;
    } else {
        error err = error(AMAZONEC2_ERROR_CODE, message = "Error occurred when converting to int");
        panic err;
    }
    encodedCanonicalQueryString = stringutils:replace(encodedCanonicalQueryString,"%3D","=");
    encodedCanonicalQueryString = stringutils:replace(encodedCanonicalQueryString,"%26","&");
    canonicalRequest = canonicalRequest + encodedCanonicalQueryString;
    canonicalRequest = canonicalRequest + "\n";

    if (payload == "") {
        canonicalHeaders = canonicalHeaders + X_AMZ_CONTENT_TYPE.toLowerAscii();
        canonicalHeaders = canonicalHeaders + ":";
        canonicalHeaders = canonicalHeaders + request.getHeader(X_AMZ_CONTENT_TYPE.toLowerAscii());
        canonicalHeaders = canonicalHeaders + "\n";
        signedHeader = signedHeader + X_AMZ_CONTENT_TYPE.toLowerAscii();
        signedHeader = signedHeader + ";";
    }

    canonicalHeaders = canonicalHeaders + HOST.toLowerAscii();
    canonicalHeaders = canonicalHeaders + ":";
    canonicalHeaders = canonicalHeaders + request.getHeader(HOST.toLowerAscii());
    canonicalHeaders = canonicalHeaders + "\n";
    signedHeader = signedHeader + HOST.toLowerAscii();
    signedHeader = signedHeader + ";";

    canonicalHeaders = canonicalHeaders + X_AMZ_DATE.toLowerAscii();
    canonicalHeaders = canonicalHeaders + ":";
    canonicalHeaders = canonicalHeaders + request.getHeader(X_AMZ_DATE.toLowerAscii());
    canonicalHeaders = canonicalHeaders + "\n";
    signedHeader = signedHeader + X_AMZ_DATE.toLowerAscii();
    signedHeader = signedHeader;

    canonicalRequest = canonicalRequest + canonicalHeaders;
    canonicalRequest = canonicalRequest + "\n";
    signedHeaders = "";
    signedHeaders = signedHeader;
    canonicalRequest = canonicalRequest + signedHeaders;
    canonicalRequest = canonicalRequest + "\n";
    payloadBuilder = payload;
    requestPayload = "";

    requestPayload = arrays:toBase16(crypto:hashSha256(payloadBuilder.toBytes())).toLowerAscii();
    canonicalRequest = canonicalRequest + requestPayload;

    //Start creating the string to sign
    stringToSign = stringToSign + AWS4_HMAC_SHA256;
    stringToSign = stringToSign + "\n";
    stringToSign = stringToSign + amzDateStr;
    stringToSign = stringToSign + "\n";
    stringToSign = stringToSign + shortDateStr;
    stringToSign = stringToSign + "/";
    stringToSign = stringToSign + region;
    stringToSign = stringToSign + "/";
    stringToSign = stringToSign + SERVICE_NAME;
    stringToSign = stringToSign + "/";
    stringToSign = stringToSign + TERMINATION_STRING;
    stringToSign = stringToSign + "\n";
    stringToSign = stringToSign + arrays:toBase16(crypto:hashSha256(canonicalRequest.toBytes())).toLowerAscii();

    signValue = (AWS4 + secretAccessKey);

    byte[] kDate = crypto:hmacSha256(shortDateStr.toBytes(), signValue.toBytes());
    byte[] kRegion = crypto:hmacSha256(region.toBytes(), kDate);
    byte[] kService = crypto:hmacSha256(SERVICE_NAME.toBytes(), kRegion);
    byte[] signingKey = crypto:hmacSha256("aws4_request".toBytes(), kService);

    authHeader = authHeader + (AWS4_HMAC_SHA256);
    authHeader = authHeader + (" ");
    authHeader = authHeader + (CREDENTIAL);
    authHeader = authHeader + ("=");
    authHeader = authHeader + (accessKeyId);
    authHeader = authHeader + ("/");
    authHeader = authHeader + (shortDateStr);
    authHeader = authHeader + ("/");
    authHeader = authHeader + (region);
    authHeader = authHeader + ("/");
    authHeader = authHeader + (SERVICE_NAME);
    authHeader = authHeader + ("/");
    authHeader = authHeader + (TERMINATION_STRING);
    authHeader = authHeader + (",");
    authHeader = authHeader + (SIGNED_HEADER);
    authHeader = authHeader + ("=");
    authHeader = authHeader + (signedHeaders);
    authHeader = authHeader + (",");
    authHeader = authHeader + (SIGNATURE);
    authHeader = authHeader + ("=");

    string encodedStr = arrays:toBase16(crypto:hmacSha256(stringToSign.toBytes(), signingKey));
    authHeader = authHeader + encodedStr.toLowerAscii();
    request.setHeader(AUTHORIZATION, authHeader);
}

function setResponseError(xml xmlResponse) returns error {
    error err = error(AMAZONEC2_ERROR_CODE, message = xmlResponse["Message"].getTextValue());
    return err;
}
