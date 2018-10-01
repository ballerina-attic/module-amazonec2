// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/io;
import ballerina/http;
import ballerina/time;
import ballerina/crypto;

function AmazonEC2Connector::runInstances(string imgId, int maxCount, int minCount, string[]? securityGroup = (),
                                          string[]? securityGroupId = ()) returns EC2Instance[]|AmazonEC2Error {

    endpoint http:Client clientEndpoint = self.clientEndpoint;
    string[] groupNames;
    string[] groupIds;
    match securityGroup {string[] names => groupNames = names;() => groupNames = [];}
    match securityGroupId {string[] ids => groupIds = ids;() => groupIds = [];}
    AmazonEC2Error amazonEC2Error = {};
    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=RunInstances&";
    if(imgId != ""){
        canonicalQueryString = canonicalQueryString + "ImageId" + "=" + imgId + "&";
    }
    canonicalQueryString = canonicalQueryString + "MaxCount" + "=" + maxCount + "&" + "MinCount" + "=" + minCount + "&";
    if (lengthof groupNames > 0) {
        int i = 1;
        foreach name in groupNames {
            canonicalQueryString = canonicalQueryString + "SecurityGroup." + i + "=" + name + "&";
            i = i + 1;
        }
    }
    if(lengthof groupIds > 0) {
        int j = 1;
        foreach id in groupIds {
            canonicalQueryString = canonicalQueryString + "SecurityGroupId." + j + "=" + id + "&";
            j = j + 1;
        }
    }
    canonicalQueryString = canonicalQueryString+ "Version" + "=" + API_VERSION;
    string constructCanonicalString = "/?" + canonicalQueryString;
    request.setHeader(HOST, host);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);
    var httpResponse = clientEndpoint->get(constructCanonicalString, message = request);
    match httpResponse {
        error err => {
            amazonEC2Error.message = err.message;
            amazonEC2Error.cause = err.cause;
            return amazonEC2Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            match amazonResponse {
                error err => {
                    amazonEC2Error.message = "Error occured while extracting xml Payload for 'runInstances' action";
                    amazonEC2Error.cause = err.cause;
                    return amazonEC2Error;
                }
                xml xmlResponse => {
                    if (statusCode == 200) {
                        return getSpawnedInstancesList(xmlResponse);
                    } else {
                        amazonEC2Error.message = xmlResponse["Message"].getTextValue();
                        return amazonEC2Error;
                    }
                }
            }
        }
    }
}

function AmazonEC2Connector::describeInstances(string... instanceIds) returns EC2Instance[]|AmazonEC2Error {

    endpoint http:Client clientEndpoint = self.clientEndpoint;
    AmazonEC2Error amazonEC2Error = {};
    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=DescribeInstances&";
    if (instanceIds != null) {
        int i = 1;
        foreach instances in instanceIds {
            canonicalQueryString = canonicalQueryString + "InstanceId." + i + "=" + instances + "&";
            i = i + 1;
        }
    }
    canonicalQueryString = canonicalQueryString + "Version" + "=" + API_VERSION;
    string constructCanonicalString = "/?" + canonicalQueryString;
    request.setHeader(HOST, host);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);
    var httpResponse = clientEndpoint->get(constructCanonicalString, message = request);
    match httpResponse {
        error err => {
            amazonEC2Error.message = err.message;
            amazonEC2Error.cause = err.cause;
            return amazonEC2Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            match amazonResponse {
                error err => {
                    amazonEC2Error.message = "Error occured while extracting xml Payload for 'describeInstances' action";
                    amazonEC2Error.cause = err.cause;
                    return amazonEC2Error;
                }
                xml xmlResponse => {
                    if (statusCode == 200) {
                        return getInstanceList(xmlResponse);
                    } else {
                        amazonEC2Error.message = xmlResponse["Message"].getTextValue();
                        return amazonEC2Error;
                    }
                }
            }
        }
    }
}

function AmazonEC2Connector::terminateInstances(string... instanceArray) returns EC2Instance[]|AmazonEC2Error {

    endpoint http:Client clientEndpoint = self.clientEndpoint;
    AmazonEC2Error amazonEC2Error = {};
    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=TerminateInstances&";
    int i = 1;
    foreach instances in instanceArray {
        canonicalQueryString = canonicalQueryString + "InstanceId." + i + "=" + instances + "&";
        i = i + 1;
    }
    canonicalQueryString = canonicalQueryString + "Version" + "=" + API_VERSION;
    string constructCanonicalString = "/?" + canonicalQueryString;
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);
    var httpResponse = clientEndpoint->get(constructCanonicalString, message = request);
    match httpResponse {
    error err => {
            amazonEC2Error.message = err.message;
            amazonEC2Error.cause = err.cause;
            return amazonEC2Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            match amazonResponse {
                error err => {
                    amazonEC2Error.message = "Error occured while extracting xml Payload for 'terminateInstances' action";
                    amazonEC2Error.cause = err.cause;
                    return amazonEC2Error;
                }
                xml xmlResponse => {
                    if (statusCode == 200) {
                        return getTerminatedInstancesList(xmlResponse);
                    } else {
                        amazonEC2Error.message = xmlResponse["Message"].getTextValue();
                        return amazonEC2Error;
                    }
                }
            }
        }
    }
}

function AmazonEC2Connector::createImage(string instanceId, string name) returns Image|AmazonEC2Error {
    endpoint http:Client clientEndpoint = self.clientEndpoint;
    AmazonEC2Error amazonEC2Error = {};
    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=CreateImage"+ "&" + "InstanceId" + "="+ instanceId + "&" + "Name" + "=" + name
        + "&" + "Version" + "=" + API_VERSION;
    string constructCanonicalString = "/?" + canonicalQueryString;
    if(constructCanonicalString.contains(" ")){
        constructCanonicalString = constructCanonicalString.replace(" ", "+");
    }
    request.setHeader(HOST, host);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);
    var httpResponse = clientEndpoint->get(constructCanonicalString, message = request);
    match httpResponse {
        error err => {
            amazonEC2Error.message = err.message;
            amazonEC2Error.cause = err.cause;
            return amazonEC2Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            match amazonResponse {
                error err => {
                    amazonEC2Error.message = "Error occured while extracting xml Payload for 'createImage' action";
                    amazonEC2Error.cause = err.cause;
                    return amazonEC2Error;
                }
                xml xmlResponse => {
                    if (statusCode == 200) {
                          Image image = {};
                          image.imageId = xmlResponse["imageId"].getTextValue();
                          return image;
                    } else {
                        amazonEC2Error.message = xmlResponse["Message"].getTextValue();
                        return amazonEC2Error;
                    }
                }
            }
        }
    }
}

function AmazonEC2Connector::describeImages(string... imgIdArr) returns Image[]|AmazonEC2Error {
    endpoint http:Client clientEndpoint = self.clientEndpoint;
    AmazonEC2Error amazonEC2Error = {};
    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=DescribeImages" + "&";
    if(imgIdArr != null){
        int i = 1;
        foreach instances in imgIdArr {
            canonicalQueryString = canonicalQueryString + "ImageId." + i + "=" + instances + "&";
            i = i + 1;
        }
    }
    canonicalQueryString = canonicalQueryString + "Version" + "=" + API_VERSION;
    string constructCanonicalString = "/?" + canonicalQueryString;
    request.setHeader(HOST, host);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);
    var httpResponse = clientEndpoint->get(constructCanonicalString, message = request);
    match httpResponse {
        error err => {
            amazonEC2Error.message = err.message;
            amazonEC2Error.cause = err.cause;
            return amazonEC2Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            match amazonResponse {
                error err => {
                    amazonEC2Error.message = "Error occured while extracting xml Payload for 'describeImages' action";
                    amazonEC2Error.cause = err.cause;
                    return amazonEC2Error;
                }
                xml xmlResponse => {
                    if (statusCode == 200) {
                        return getSpawnedImageList(xmlResponse);
                    } else {
                        amazonEC2Error.message = xmlResponse["Message"].getTextValue();
                        return amazonEC2Error;
                    }
                }
            }
        }
    }
}

function AmazonEC2Connector::deRegisterImage(string imgId) returns EC2ServiceResponse |AmazonEC2Error {
    endpoint http:Client clientEndpoint = self.clientEndpoint;
    AmazonEC2Error amazonEC2Error = {};
    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=DeregisterImage" + "&" + "ImageId" + "=" + imgId + "&" +
        "Version" + "=" + API_VERSION;
    string constructCanonicalString = "/?" + canonicalQueryString;
    request.setHeader(HOST, host);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);
    var httpResponse = clientEndpoint->get(constructCanonicalString, message = request);
    match httpResponse {
        error err => {
            amazonEC2Error.message = err.message;
            amazonEC2Error.cause = err.cause;
            return amazonEC2Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            match amazonResponse {
                error err => {
                    amazonEC2Error.message = "Error occured while extracting xml Payload for 'deRegisterImage' action";
                    amazonEC2Error.cause = err.cause;
                    return amazonEC2Error;
                }
                xml xmlResponse => {
                    if (statusCode == 200) {
                        EC2ServiceResponse serviceResponse = {};
                        serviceResponse.success = <boolean> xmlResponse["return"].getTextValue();
                        return serviceResponse;
                    } else {
                        amazonEC2Error.message = xmlResponse["Message"].getTextValue();
                        return amazonEC2Error;
                    }
                }
            }
        }
    }
}

function AmazonEC2Connector::describeImageAttribute(string amiId, string attribute)
                                 returns ImageAttribute|AmazonEC2Error {
    endpoint http:Client clientEndpoint = self.clientEndpoint;
    AmazonEC2Error amazonEC2Error = {};
    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=DescribeImageAttribute" + "&" + "Attribute" + "=" + attribute + "&" +
        "ImageId" + "=" + amiId + "&" + "Version" + "=" + API_VERSION;
    string constructCanonicalString = "/?" + canonicalQueryString;
    request.setHeader(HOST, host);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);
    var httpResponse = clientEndpoint->get(constructCanonicalString, message = request);
    match httpResponse {
        error err => {
            amazonEC2Error.message = err.message;
            amazonEC2Error.cause = err.cause;
            return amazonEC2Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            match amazonResponse {
                error err => {
                    amazonEC2Error.message = "Error occured while extracting xml Payload for 'describeImageAttribute' action";
                    amazonEC2Error.cause = err.cause;
                    return amazonEC2Error;
                }
                xml xmlResponse => {
                    if (statusCode == 200) {
                        return getAttributeValue(attribute,xmlResponse);
                    } else {
                        amazonEC2Error.message = xmlResponse["Message"].getTextValue();
                        return amazonEC2Error;
                    }
                }
            }
        }
    }
}

function AmazonEC2Connector::copyImage(string name, string sourceImageId, string sourceRegion)
                                 returns Image |AmazonEC2Error {
    endpoint http:Client clientEndpoint = self.clientEndpoint;
    AmazonEC2Error amazonEC2Error = {};
    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=CopyImage" + "&" + "Name" + "=" + name + "&" + "SourceImageId" + "=" +
        sourceImageId + "&" + "SourceRegion" + "=" + sourceRegion + "&" + "Version" + "=" + API_VERSION;
    string constructCanonicalString = "/?" + canonicalQueryString;
    request.setHeader(HOST, host);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);
    var httpResponse = clientEndpoint->get(constructCanonicalString, message = request);
    match httpResponse {
        error err => {
            amazonEC2Error.message = err.message;
            amazonEC2Error.cause = err.cause;
            return amazonEC2Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            match amazonResponse {
                error err => {
                    amazonEC2Error.message = "Error occured while extracting xml Payload for 'copyImage' action";
                    amazonEC2Error.cause = err.cause;
                    return amazonEC2Error;
                }
                xml xmlResponse => {
                    if (statusCode == 200) {
                        Image image = {};
                        image.imageId = xmlResponse["imageId"].getTextValue();
                        return image;
                    } else {
                        amazonEC2Error.message = xmlResponse["Message"].getTextValue();
                        return amazonEC2Error;
                    }
                }
            }
        }
    }
}

function AmazonEC2Connector::createSecurityGroup(string groupName, string groupDescription, string? vpcId = ())
                                 returns SecurityGroup |AmazonEC2Error {
    endpoint http:Client clientEndpoint = self.clientEndpoint;
    string vpc_id;
    match vpcId {string id => vpc_id = id;() => vpc_id = "";}
    AmazonEC2Error amazonEC2Error = {};
    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=CreateSecurityGroup" + "&" + "GroupDescription" + "=" + groupDescription + "&" +
        "GroupName" + "=" + groupName + "&" + "Version" + "=" + API_VERSION;
    if(vpc_id != "") {
        canonicalQueryString = canonicalQueryString + "&VpcId" + "=" + vpc_id;
    }
    string constructCanonicalString = "/?" + canonicalQueryString;
    if(constructCanonicalString.contains(" ")){
        constructCanonicalString = constructCanonicalString.replace(" ", "+");
    }
    request.setHeader(HOST, host);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);
    var httpResponse = clientEndpoint->get(constructCanonicalString, message = request);
    match httpResponse {
        error err => {
            amazonEC2Error.message = err.message;
            amazonEC2Error.cause = err.cause;
            return amazonEC2Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            match amazonResponse {
                error err => {
                    amazonEC2Error.message = "Error occured while extracting xml Payload for 'createSecurityGroup' action";
                    amazonEC2Error.cause = err.cause;
                    return amazonEC2Error;
                }
                xml xmlResponse => {
                    if (statusCode == 200) {
                        SecurityGroup securityGroup = {};
                        securityGroup.groupId = xmlResponse["groupId"].getTextValue();
                        return securityGroup;
                    } else {
                        amazonEC2Error.message = xmlResponse["Message"].getTextValue();
                        return amazonEC2Error;
                    }
                }
            }
        }
    }
}

function AmazonEC2Connector::deleteSecurityGroup(string? groupId = (), string? groupName = ())
                                 returns EC2ServiceResponse |AmazonEC2Error {
    endpoint http:Client clientEndpoint = self.clientEndpoint;
    AmazonEC2Error amazonEC2Error = {};
    string group_id;
    string group_name;
    match groupId {string id => group_id = id;() => group_id = "";}
    match groupName {string name => group_name = name;() => group_name = "";}
    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=DeleteSecurityGroup" + "&";
    if(group_id != "") {
        canonicalQueryString = canonicalQueryString + "GroupId" + "=" + group_id + "&";
    }
    if(group_name != "") {
        canonicalQueryString = canonicalQueryString + "GroupName" + "=" + group_name + "&";
    }
    canonicalQueryString = canonicalQueryString  + "Version" + "=" + API_VERSION;
    string constructCanonicalString = "/?" + canonicalQueryString;
    request.setHeader(HOST, host);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);
    var httpResponse = clientEndpoint->get(constructCanonicalString, message = request);
    match httpResponse {
        error err => {
            amazonEC2Error.message = err.message;
            amazonEC2Error.cause = err.cause;
            return amazonEC2Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            match amazonResponse {
                error err => {
                    amazonEC2Error.message = "Error occured while extracting xml Payload for 'deleteSecurityGroup' action";
                    amazonEC2Error.cause = err.cause;
                    return amazonEC2Error;
                }
                xml xmlResponse => {
                    if (statusCode == 200) {
                        EC2ServiceResponse serviceResponse = {};
                        serviceResponse.success = <boolean> xmlResponse["return"].getTextValue();
                        return serviceResponse;
                    } else {
                        amazonEC2Error.message = xmlResponse["Message"].getTextValue();
                        return amazonEC2Error;
                    }
                }
            }
        }
    }
}

function AmazonEC2Connector::createVolume(string availabilityZone, int ? size = (), string ? snapshotId = (),
                                          string? volumeType = ()) returns Volume|AmazonEC2Error {
    endpoint http:Client clientEndpoint = self.clientEndpoint;
    AmazonEC2Error amazonEC2Error = {};
    int volumeSize;
    string volumeSnapshotId;
    string Vtype;
    match size {int value => volumeSize = value;() => volumeSize = 0;}
    match snapshotId {string id => volumeSnapshotId = id;() => volumeSnapshotId = "";}
    match volumeType {string volume_type => Vtype = volume_type;() => Vtype = "";}
    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=CreateVolume" + "&" + "AvailabilityZone" + "=" + availabilityZone + "&";
    if(volumeSize != 0) {
        canonicalQueryString = canonicalQueryString + "Size" + "=" + <string> volumeSize + "&";
    }
    if(volumeSnapshotId != "") {
        canonicalQueryString = canonicalQueryString + "SnapshotId" + "=" + volumeSnapshotId + "&";
    }
    canonicalQueryString = canonicalQueryString  + "Version" + "=" + API_VERSION;
    if(Vtype != "") {
        canonicalQueryString = canonicalQueryString  + "&" + "VolumeType" + "=" + Vtype;
    }
    string constructCanonicalString = "/?" + canonicalQueryString;
    request.setHeader(HOST, host);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);
    var httpResponse = clientEndpoint->get(constructCanonicalString, message = request);
    match httpResponse {
        error err => {
            amazonEC2Error.message = err.message;
            amazonEC2Error.cause = err.cause;
            return amazonEC2Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            match amazonResponse {
                error err => {
                    amazonEC2Error.message = "Error occured while extracting xml Payload for 'createVolume' action";
                    amazonEC2Error.cause = err.cause;
                    return amazonEC2Error;
                }
                xml xmlResponse => {
                    if (statusCode == 200) {
                     return getVolumeList(xmlResponse);
                    } else {
                        amazonEC2Error.message = xmlResponse["Message"].getTextValue();
                        return amazonEC2Error;
                    }
                }
            }
        }
    }
}

function AmazonEC2Connector::attachVolume(string device, string instanceId, string volumeId)
                                 returns AttachmentInfo|AmazonEC2Error {
    endpoint http:Client clientEndpoint = self.clientEndpoint;
    AmazonEC2Error amazonEC2Error = {};
    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=AttachVolume" + "&" + "Device" + "=" + device + "&" + "InstanceId" + "="
        + instanceId + "&" + "Version" + "=" + API_VERSION + "&" + "VolumeId" + "=" + volumeId;
    string constructCanonicalString = "/?" + canonicalQueryString;
    request.setHeader(HOST, host);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);
    var httpResponse = clientEndpoint->get(constructCanonicalString, message = request);
    match httpResponse {
        error err => {
            amazonEC2Error.message = err.message;
            amazonEC2Error.cause = err.cause;
            return amazonEC2Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            match amazonResponse {
                error err => {
                    amazonEC2Error.message = "Error occured while extracting xml Payload for 'attachVolume' action";
                    amazonEC2Error.cause = err.cause;
                    return amazonEC2Error;
                }
                xml xmlResponse => {
                    if (statusCode == 200) {
                        return getVolumeAttachmentList(xmlResponse);
                    } else {
                        amazonEC2Error.message = xmlResponse["Message"].getTextValue();
                        return amazonEC2Error;
                    }
                }
            }
        }
    }
}

function AmazonEC2Connector::detachVolume(boolean force = false, string volumeId) returns AttachmentInfo|AmazonEC2Error {
    endpoint http:Client clientEndpoint = self.clientEndpoint;
    AmazonEC2Error amazonEC2Error = {};
    match force {boolean value => force = value;}
    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=DetachVolume" + "&" + "Force" + "=" + force + "&" +
        "Version" + "=" + API_VERSION + "&" + "VolumeId" + "=" + volumeId;
    string constructCanonicalString = "/?" + canonicalQueryString;
    request.setHeader(HOST, host);
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);
    var httpResponse = clientEndpoint->get(constructCanonicalString, message = request);
    match httpResponse {
        error err => {
            amazonEC2Error.message = err.message;
            amazonEC2Error.cause = err.cause;
            return amazonEC2Error;
        }
        http:Response response => {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            match amazonResponse {
                error err => {
                    amazonEC2Error.message = "Error occured while extracting xml Payload for 'detachVolume' action";
                    amazonEC2Error.cause = err.cause;
                    return amazonEC2Error;
                }
                xml xmlResponse => {
                    if (statusCode == 200) {
                        return getVolumeAttachmentList(xmlResponse);
                    } else {
                        amazonEC2Error.message = xmlResponse["Message"].getTextValue();
                        return amazonEC2Error;
                    }
                }
            }
        }
    }
}