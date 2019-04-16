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
import ballerina/system;
import ballerina/time;

function generateSignature(http:Request request, string accessKeyId, string secretAccessKey, string region,
                           string httpVerb, string requestURI, string payload, string canonicalQueryString )
                           returns error? {
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
    string host = SERVICE_NAME + "." + region + "." + "amazonaws.com";
    request.setHeader(HOST,host);

    canonicalRequest = httpVerb;
    canonicalRequest = canonicalRequest + "\n";
    var value = http:encode(requestURI, UTF_8);
    if (value is string) {
        encodedrequestURIValue = value;
    } else {
        error err = error(AMAZONEC2_ERROR_CODE, { message: "Error occurred when converting to int"});
        panic err;
    }
    encodedrequestURIValue = encodedrequestURIValue.replace("%2F", "/");
    canonicalRequest = canonicalRequest + encodedrequestURIValue;
    canonicalRequest = canonicalRequest + "\n";
    var canonicalValue = http:encode(canonicalQueryString, UTF_8);
    if (canonicalValue is string) {
        encodedCanonicalQueryString = canonicalValue;
    } else {
        error err = error(AMAZONEC2_ERROR_CODE, { message: "Error occurred when converting to int"});
        panic err;
    }
    encodedCanonicalQueryString = encodedCanonicalQueryString.replace("%3D","=");
    encodedCanonicalQueryString = encodedCanonicalQueryString.replace("%26","&");
    canonicalRequest = canonicalRequest + encodedCanonicalQueryString;
    canonicalRequest = canonicalRequest + "\n";

    if (payload == "") {
        canonicalHeaders = canonicalHeaders + X_AMZ_CONTENT_TYPE.toLower();
        canonicalHeaders = canonicalHeaders + ":";
        canonicalHeaders = canonicalHeaders + request.getHeader(X_AMZ_CONTENT_TYPE.toLower());
        canonicalHeaders = canonicalHeaders + "\n";
        signedHeader = signedHeader + X_AMZ_CONTENT_TYPE.toLower();
        signedHeader = signedHeader + ";";
    }

    canonicalHeaders = canonicalHeaders + HOST.toLower();
    canonicalHeaders = canonicalHeaders + ":";
    canonicalHeaders = canonicalHeaders + request.getHeader(HOST.toLower());
    canonicalHeaders = canonicalHeaders + "\n";
    signedHeader = signedHeader + HOST.toLower();
    signedHeader = signedHeader + ";";

    canonicalHeaders = canonicalHeaders + X_AMZ_DATE.toLower();
    canonicalHeaders = canonicalHeaders + ":";
    canonicalHeaders = canonicalHeaders + request.getHeader(X_AMZ_DATE.toLower());
    canonicalHeaders = canonicalHeaders + "\n";
    signedHeader = signedHeader + X_AMZ_DATE.toLower();
    signedHeader = signedHeader;

    canonicalRequest = canonicalRequest + canonicalHeaders;
    canonicalRequest = canonicalRequest + "\n";
    signedHeaders = "";
    signedHeaders = signedHeader;
    canonicalRequest = canonicalRequest + signedHeaders;
    canonicalRequest = canonicalRequest + "\n";
    payloadBuilder = payload;
    requestPayload = "";

    requestPayload = encoding:encodeHex(crypto:hashSha256(payloadBuilder.toByteArray(UTF_8))).toLower();
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
    stringToSign = stringToSign + encoding:encodeHex(crypto:hashSha256(canonicalRequest.toByteArray(UTF_8))).toLower();

    signValue = (AWS4 + secretAccessKey);

    byte[] kDate = crypto:hmacSha256(shortDateStr.toByteArray(UTF_8), signValue.toByteArray(UTF_8));
    byte[] kRegion = crypto:hmacSha256(region.toByteArray(UTF_8), kDate);
    byte[] kService = crypto:hmacSha256(SERVICE_NAME.toByteArray(UTF_8), kRegion);
    byte[] signingKey = crypto:hmacSha256("aws4_request".toByteArray(UTF_8), kService);

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

    string encodedStr = encoding:encodeHex(crypto:hmacSha256(stringToSign.toByteArray(UTF_8), signingKey));
    authHeader = authHeader + encodedStr.toLower();
    request.setHeader(AUTHORIZATION, authHeader);
}

function setResponseError(xml xmlResponse) returns error {
    error err = error(AMAZONEC2_ERROR_CODE, { message : xmlResponse["Message"].getTextValue()});
    return err;
}
