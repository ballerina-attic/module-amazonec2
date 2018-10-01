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

import ballerina/io;
import ballerina/time;
import ballerina/http;
import ballerina/crypto;
import ballerina/system;

function generateSignature(http:Request request, string accessKeyId, string secretAccessKey, string region,
                           string httpVerb, string requestURI, string payload, string canonicalQueryString ) {
    string canonicalRequest;
    string stringToSign;
    string payloadBuilder;
    string authHeader;
    string amzDate;
    string shortDate;
    string signedHeader;
    string canonicalHeaders;
    string signedHeaders;
    string requestPayload;
    string signingKey;
    string encodedrequestURIValue;
    string signValue;
    string encodedSignValue;

    time:Time time = time:currentTime().toTimezone("UTC");
    amzDate = time.format(ISO8601_BASIC_DATE_FORMAT);
    shortDate = time.format(SHORT_DATE_FORMAT);
    request.setHeader(CONTENT_TYPE, APPLICATION_URL_ENCODED);
    request.setHeader(X_AMZ_DATE, amzDate);
    string host = SERVICE_NAME + "." + region + "." + "amazonaws.com";
    request.setHeader(HOST,host);

    canonicalRequest = httpVerb;
    canonicalRequest = canonicalRequest + "\n";
    encodedrequestURIValue = check http:encode(requestURI, UTF_8);
    encodedrequestURIValue = encodedrequestURIValue.replace("%2F", "/");
    canonicalRequest = canonicalRequest + encodedrequestURIValue;
    canonicalRequest = canonicalRequest + "\n";
    string encodedCanonicalQueryString = check http:encode(canonicalQueryString, UTF_8);
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

    requestPayload = crypto:hash(payloadBuilder, crypto:SHA256).toLower();
    canonicalRequest = canonicalRequest + requestPayload;
    string canonicalRequestHash = crypto:hash(canonicalRequest, crypto:SHA256).toLower();

    //Start creating the string to sign
    stringToSign = stringToSign + AWS4_HMAC_SHA256;
    stringToSign = stringToSign + "\n";
    stringToSign = stringToSign + amzDate;
    stringToSign = stringToSign + "\n";
    stringToSign = stringToSign + shortDate;
    stringToSign = stringToSign + "/";
    stringToSign = stringToSign + region;
    stringToSign = stringToSign + "/";
    stringToSign = stringToSign + SERVICE_NAME;
    stringToSign = stringToSign + "/";
    stringToSign = stringToSign + TERMINATION_STRING;
    stringToSign = stringToSign + "\n";
    stringToSign = stringToSign + crypto:hash(canonicalRequest, crypto:SHA256).toLower();

    signValue = (AWS4 + secretAccessKey);
    encodedSignValue = check signValue.base64Encode();

    string kDate = crypto:hmac(shortDate, encodedSignValue, keyEncoding = "BASE64", crypto:SHA256).base16ToBase64Encode();
    string kRegion = crypto:hmac(region, kDate, keyEncoding = "BASE64", crypto:SHA256).base16ToBase64Encode();
    string kService = crypto:hmac(SERVICE_NAME, kRegion, keyEncoding = "BASE64", crypto:SHA256).base16ToBase64Encode();
    signingKey = crypto:hmac("aws4_request", kService,  keyEncoding = "BASE64", crypto:SHA256).base16ToBase64Encode();

    authHeader = authHeader + (AWS4_HMAC_SHA256);
    authHeader = authHeader + (" ");
    authHeader = authHeader + (CREDENTIAL);
    authHeader = authHeader + ("=");
    authHeader = authHeader + (accessKeyId);
    authHeader = authHeader + ("/");
    authHeader = authHeader + (shortDate);
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

    authHeader = authHeader + crypto:hmac(stringToSign, signingKey, keyEncoding = "BASE64", crypto:SHA256).toLower();
    request.setHeader(AUTHORIZATION, authHeader);
}