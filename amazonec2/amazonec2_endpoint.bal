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

import ballerina/http;
import ballerina/time;

# AmazonEC2 Client object.
# + accessKeyId - The access key of Amazon ec2 account
# + secretAccessKey - The secret key of the Amazon ec2 account
# + region - The AWS region
# + amazonClient - HTTP client endpoint config
public type Client client object {

    public string accessKeyId;
    public string secretAccessKey;
    public string region;
    public http:Client amazonClient;

    public function __init(AmazonEC2Configuration amazonec2Config) {
        string ec2Endpoint = "https://ec2." + amazonec2Config.region + ".amazonaws.com";
        self.amazonClient = new(ec2Endpoint, config = amazonec2Config.clientConfig);
        self.accessKeyId = amazonec2Config.accessKeyId;
        self.secretAccessKey = amazonec2Config.secretAccessKey;
        self.region = amazonec2Config.region;
    }

    # Launches the specified number of instances using an AMI for which you have permissions.
    # + imgId -  The ID of the AMI which is required to launch an instance
    # + maxCount - The maximum number of instances to launch
    # + minCount - The minimum number of instances to launch
    # + securityGroup - [EC2-Classic, default VPC] One or more security group names
    # + securityGroupId - One or more security group IDs
    # + return - If success, returns EC2Instance of launched instances, else returns error
    public remote function runInstances(string imgId, int maxCount, int minCount, string[]? securityGroup = (),
                                        string[]? securityGroupId = ()) returns EC2Instance[]|error;

    # Describes one or more of your instances.
    # + instanceIds -  Array of instanceIds to describe those
    # + return - If successful, returns EC2Instance[] with zero or more instances, else returns an error
    public remote function describeInstances(string... instanceIds) returns EC2Instance[]|error;

    # Shuts down one or more instances.
    # + instanceArray -  Array of instanceIds to terminate those
    # + return - If success, returns EC2Instance with terminated instances, else returns error
    public remote function terminateInstances(string... instanceArray) returns EC2Instance[]|error;

    # Create image.
    # + instanceId -  The ID of the instance which is created with the particular image id
    # + name - The name of the image
    # + return - If successful, returns Image with image id, else returns an error
    public remote function createImage(string instanceId, string name) returns Image|error;

    # Describe images.
    # + imgIdArr -  The string of AMI array to describe those images
    # + return - If successful, returns Image[] with image details, else returns an error
    public remote function describeImages(string... imgIdArr) returns Image[]|error;

    # Deregisters the specified AMI. After you deregister an AMI, it can't be used to launch new instances.
    # + imgId - The ID of the AMI
    # + return - If successful, returns success response, else returns an error
    public remote function deregisterImage(string imgId) returns EC2ServiceResponse|error;

    # Describes the specified attribute of the specified AMI. You can specify only one attribute at a time.
    # + amiId - The ID of the AMI
    # + attribute - The specific attribute of the image
    # + return - If successful, returns success response, else returns an error
    public remote function describeImageAttribute(string amiId, string attribute) returns ImageAttribute|error;

    # Initiates the copy of an AMI from the specified source region to the current region.
    # + name -  The name of the new AMI in the destination region
    # + sourceImageId - The ID of the AMI to copy
    # + sourceRegion - The name of the region that contains the AMI to copy
    # + return - If successful, returns Image object, else returns an error
    public remote function copyImage(string name, string sourceImageId, string sourceRegion) returns Image|error;

    # Creates a security group.
    # + groupName - The name of the security group
    # + groupDescription - A description for the security group
    # + vpcId - The ID of the VPC, Required for EC2-VPC
    # + return - If successful, returns SecurityGroup object with groupId, else returns an error
    public remote function createSecurityGroup(string groupName, string groupDescription, string? vpcId = ())
                               returns SecurityGroup|error;

    # Deletes a security group. Can specify either the security group name or the security group ID,
    # But group id is required for a non default VPC.
    # + groupId -  The id of the security group
    # + groupName - The name of the security group
    # + return - If successful, returns success response, else returns an error
    public remote function deleteSecurityGroup(string? groupId = (), string? groupName = ())
                               returns EC2ServiceResponse|error;

    # Creates an EBS volume that can be attached to an instance in the same Availability Zone.
    # + availabilityZone - The Availability Zone in which to create the volume
    # + size - The size of the volume, in GiBs
    # + snapshotId - The snapshot from which to create the volume
    # + volumeType - The volume type
    # + return - If successful, returns Volume object with created volume details, else returns an error
    public remote function createVolume(string availabilityZone, int? size = (), string? snapshotId = (),
                                        string? volumeType = ()) returns Volume|error;

    # Attaches an EBS volume to a running or stopped instance and exposes it to the instance with the specified
    # device name.
    # + device - The device name
    # + instanceId - The ID of the instance
    # + volumeId - The ID of the EBS volume, The volume and instance must be within the same Availability Zone
    # + return - If successful, returns Attachment information, else returns an error
    public remote function attachVolume(string device, string instanceId, string volumeId) returns AttachmentInfo|error;

    # Detaches an EBS volume from an instance.
    # + force - Forces detachment if the previous detachment attempt did not occur cleanly
    # + volumeId - The ID of the volume
    # + return - If successful, returns detached volume information, else returns an error
    public remote function detachVolume(boolean force = false, string volumeId) returns AttachmentInfo|error;
};

public remote function Client.runInstances(string imgId, int maxCount, int minCount, string[]? securityGroup = (),
                                           string[]? securityGroupId = ()) returns EC2Instance[]|error {

    string[] groupNames;
    string[] groupIds;
    if (securityGroup is string[]) {
        groupNames = securityGroup;
    } else {
        groupNames = [];
    }

    if (securityGroupId is string[]) {
        groupIds = securityGroupId;
    } else {
        groupIds = [];
    }

    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=RunInstances&";

    if (imgId != "") {
        canonicalQueryString = canonicalQueryString + "ImageId" + "=" + imgId + "&";
    }

    canonicalQueryString = canonicalQueryString + "MaxCount" + "=" + maxCount + "&" + "MinCount" + "=" + minCount + "&";

    if (groupNames.length() > 0) {
        int i = 1;
        foreach var name in groupNames {
            canonicalQueryString = canonicalQueryString + "SecurityGroup." + i + "=" + name + "&";
            i = i + 1;
        }
    }

    if (groupIds.length() > 0) {
        int j = 1;
        foreach var id in groupIds {
            canonicalQueryString = canonicalQueryString + "SecurityGroupId." + j + "=" + id + "&";
            j = j + 1;
        }
    }

    canonicalQueryString = canonicalQueryString + "Version" + "=" + API_VERSION;
    string constructCanonicalString = "/?" + canonicalQueryString;
    request.setHeader(HOST, host);
    var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);

    if (signature is error) {
        error err = error(AMAZONEC2_ERROR_CODE, { ^"error": signature.detail(),
            message: "Error occurred while generating the amazon signature header" });
        return err;
    } else {
        var response = self.amazonClient->get(constructCanonicalString, message = request);
        if (response is http:Response) {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            if (amazonResponse is xml) {
                if (statusCode == 200) {
                    return getSpawnedInstancesList(amazonResponse);
                } else {
                    return setResponseError(amazonResponse);
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE,
                { message: "Error occurred while accessing the XML payload of the response" });
                return err;
            }
        } else {
            error err = error(AMAZONEC2_ERROR_CODE, { message: "Error occurred while invoking the amazonec2 API" });
            return err;
        }
    }
}


public remote function Client.describeInstances(string... instanceIds) returns EC2Instance[]|error {

    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=DescribeInstances&";
    if (instanceIds.length() > 0) {
        int i = 1;
        foreach var instances in instanceIds {
            canonicalQueryString = canonicalQueryString + "InstanceId." + i + "=" + instances + "&";
            i = i + 1;
        }
    }
    canonicalQueryString = canonicalQueryString + "Version" + "=" + API_VERSION;
    string constructCanonicalString = "/?" + canonicalQueryString;
    request.setHeader(HOST, host);
    var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);

    if (signature is error) {
        error err = error(AMAZONEC2_ERROR_CODE, { ^"error": signature.detail(),
            message: "Error occurred while generating the amazon signature header" });
        return err;
    } else {
        var response = self.amazonClient->get(constructCanonicalString, message = request);
        if (response is http:Response) {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            if (amazonResponse is xml) {
                if (statusCode == 200) {
                    return getInstanceList(amazonResponse);
                } else {
                    return setResponseError(amazonResponse);
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE,
                { message: "Error occurred while accessing the XML payload of the response" });
                return err;
            }
        } else {
            error err = error(AMAZONEC2_ERROR_CODE, { message: "Error occurred while invoking the AmazonEc2 API" });
            return err;
        }
    }
}

public remote function Client.terminateInstances(string... instanceArray) returns EC2Instance[]|error {

    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=TerminateInstances&";
    int i = 1;
    foreach var instances in instanceArray {
        canonicalQueryString = canonicalQueryString + "InstanceId." + i + "=" + instances + "&";
        i = i + 1;
    }

    canonicalQueryString = canonicalQueryString + "Version" + "=" + API_VERSION;
    string constructCanonicalString = "/?" + canonicalQueryString;
    var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);

    if (signature is error) {
        error err = error(AMAZONEC2_ERROR_CODE, { ^"error": signature.detail(),
            message: "Error occurred while generating the amazon signature header" });
        return err;
    } else {
        var response = self.amazonClient->get(untaint constructCanonicalString, message = request);

        if (response is http:Response) {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            if (amazonResponse is xml) {
                if (statusCode == 200) {
                    return getTerminatedInstancesList(amazonResponse);
                } else {
                    return setResponseError(amazonResponse);
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE,
                { message: "Error occurred while accessing the XML payload of the response" });
                return err;
            }
        } else {
            error err = error(AMAZONEC2_ERROR_CODE, { message: "Error occurred while invoking the amazonec2 API" });
            return err;
        }
    }
}

public remote function Client.createImage(string instanceId, string name) returns Image|error {

    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=CreateImage" + "&" + "InstanceId" + "=" + instanceId + "&" + "Name" + "=" +
        name + "&" + "Version" + "=" + API_VERSION;
    string constructCanonicalString = "/?" + canonicalQueryString;
    if (constructCanonicalString.contains(" ")) {
        constructCanonicalString = constructCanonicalString.replace(" ", "+");
    }
    request.setHeader(HOST, host);
    var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);

    if (signature is error) {
        error err = error(AMAZONEC2_ERROR_CODE, { ^"error": signature.detail(),
            message: "Error occurred while generating the amazon signature header" });
        return err;
    } else {
        var response = self.amazonClient->get(constructCanonicalString, message = request);

        if (response is http:Response) {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            if (amazonResponse is xml) {
                if (statusCode == 200) {
                    Image image = {};
                    image.imageId = amazonResponse["imageId"].getTextValue();
                    return image;
                } else {
                    return setResponseError(amazonResponse);
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE,
                { message: "Error occurred while accessing the XML payload of the response" });
                return err;
            }
        } else {
            error err = error(AMAZONEC2_ERROR_CODE, { message: "Error occurred while invoking the amazonec2 API" });
            return err;
        }
    }
}

public remote function Client.describeImages(string... imgIdArr) returns Image[]|error {

    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=DescribeImages" + "&";
    if (imgIdArr.length() > 0) {
        int i = 1;
        foreach var instances in imgIdArr {
            canonicalQueryString = canonicalQueryString + "ImageId." + i + "=" + instances + "&";
            i = i + 1;
        }
    }
    canonicalQueryString = canonicalQueryString + "Version" + "=" + API_VERSION;
    string constructCanonicalString = "/?" + canonicalQueryString;
    request.setHeader(HOST, host);
    var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);

    if (signature is error) {
        error err = error(AMAZONEC2_ERROR_CODE, { ^"error": signature.detail(),
            message: "Error occurred while generating the amazon signature header" });
        return err;
    } else {
        var response = self.amazonClient->get(untaint constructCanonicalString, message = request);

        if (response is http:Response) {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            if (amazonResponse is xml) {
                if (statusCode == 200) {
                    return getSpawnedImageList(amazonResponse);
                } else {
                    return setResponseError(amazonResponse);
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE,
                { message: "Error occurred while accessing the XML payload of the response" });
                return err;
            }
        } else {
            error err = error(AMAZONEC2_ERROR_CODE, { message: "Error occurred while invoking the amazonec2 API" });
            return err;
        }
    }
}

public remote function Client.deregisterImage(string imgId) returns EC2ServiceResponse|error {

    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=DeregisterImage" + "&" + "ImageId" + "=" + imgId + "&" +
        "Version" + "=" + API_VERSION;
    string constructCanonicalString = "/?" + canonicalQueryString;
    request.setHeader(HOST, host);
    var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);

    if (signature is error) {
        error err = error(AMAZONEC2_ERROR_CODE, { ^"error": signature.detail(),
            message: "Error occurred while generating the amazon signature header" });
        return err;
    } else {
        var response = self.amazonClient->get(constructCanonicalString, message = request);

        if (response is http:Response) {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            if (amazonResponse is xml) {
                if (statusCode == 200) {
                    EC2ServiceResponse serviceResponse = {};
                    serviceResponse.success = boolean.convert(amazonResponse["return"].getTextValue());
                    return serviceResponse;
                } else {
                    return setResponseError(amazonResponse);
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE,
                { message: "Error occurred while accessing the XML payload of the response" });
                return err;
            }
        } else {
            error err = error(AMAZONEC2_ERROR_CODE, { message: "Error occurred while invoking the amazonec2 API" });
            return err;
        }
    }
}

public remote function Client.describeImageAttribute(string amiId, string attribute) returns ImageAttribute|error {

    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=DescribeImageAttribute" + "&" + "Attribute" + "=" + attribute + "&" +
        "ImageId" + "=" + amiId + "&" + "Version" + "=" + API_VERSION;
    string constructCanonicalString = "/?" + canonicalQueryString;
    request.setHeader(HOST, host);
    var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);

    if (signature is error) {
        error err = error(AMAZONEC2_ERROR_CODE, { ^"error": signature.detail(),
            message: "Error occurred while generating the amazon signature header" });
        return err;
    } else {
        var response = self.amazonClient->get(constructCanonicalString, message = request);

        if (response is http:Response) {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            if (amazonResponse is xml) {
                if (statusCode == 200) {
                    return getAttributeValue(attribute, amazonResponse);
                } else {
                    return setResponseError(amazonResponse);
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE,
                { message: "Error occurred while accessing the XML payload of the response" });
                return err;
            }
        } else {
            error err = error(AMAZONEC2_ERROR_CODE, { message: "Error occurred while invoking the amazonec2 API" });
            return err;
        }
    }
}

public remote function Client.copyImage(string name, string sourceImageId, string sourceRegion)
                                  returns Image|error {

    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=CopyImage" + "&" + "Name" + "=" + name + "&" + "SourceImageId" + "=" +
        sourceImageId + "&" + "SourceRegion" + "=" + sourceRegion + "&" + "Version" + "=" + API_VERSION;
    string constructCanonicalString = "/?" + canonicalQueryString;
    request.setHeader(HOST, host);
    var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);

    if (signature is error) {
        error err = error(AMAZONEC2_ERROR_CODE, { ^"error": signature.detail(),
            message: "Error occurred while generating the amazon signature header" });
        return err;
    } else {
        var response = self.amazonClient->get(constructCanonicalString, message = request);
        if (response is http:Response) {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            if (amazonResponse is xml) {
                if (statusCode == 200) {
                    Image image = {};
                    image.imageId = amazonResponse["imageId"].getTextValue();
                    return image;
                } else {
                    return setResponseError(amazonResponse);
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE,
                { message: "Error occurred while accessing the XML payload of the response" });
                return err;
            }
        } else {
            error err = error(AMAZONEC2_ERROR_CODE, { message: "Error occurred while invoking the amazonec2 API" });
            return err;
        }
    }
}

public remote function Client.createSecurityGroup(string groupName, string groupDescription, string? vpcId = ())
                                  returns SecurityGroup|error {
    string vpc_id;
    if (vpcId is string) {
        vpc_id = vpcId;
    } else {
        vpc_id = "";
    }

    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=CreateSecurityGroup" + "&" + "GroupDescription" + "=" + groupDescription
        + "&" + "GroupName" + "=" + groupName + "&" + "Version" + "=" + API_VERSION;

    if (vpc_id != "") {
        canonicalQueryString = canonicalQueryString + "&VpcId" + "=" + vpc_id;
    }

    string constructCanonicalString = "/?" + canonicalQueryString;

    if (constructCanonicalString.contains(" ")) {
        constructCanonicalString = constructCanonicalString.replace(" ", "+");
    }

    request.setHeader(HOST, host);
    var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);

    if (signature is error) {
        error err = error(AMAZONEC2_ERROR_CODE, { ^"error": signature.detail(),
            message: "Error occurred while generating the amazon signature header" });
        return err;
    } else {
        var response = self.amazonClient->get(untaint constructCanonicalString, message = request);
        if (response is http:Response) {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            if (amazonResponse is xml) {
                if (statusCode == 200) {
                    SecurityGroup securityGroup = {};
                    securityGroup.groupId = amazonResponse["groupId"].getTextValue();
                    return securityGroup;
                } else {
                    return setResponseError(amazonResponse);
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE,
                { message: "Error occurred while accessing the XML payload of the response" });
                return err;
            }
        } else {
            error err = error(AMAZONEC2_ERROR_CODE, { message: "Error occurred while invoking the amazonec2 API" });
            return err;
        }
    }
}

public remote function Client.deleteSecurityGroup(string? groupId = (), string? groupName = ())
                                  returns EC2ServiceResponse|error {
    string group_id;
    string group_name;

    if (groupId is string) {
        group_id = groupId;
    } else {
        group_id = "";
    }

    if (groupName is string) {
        group_name = groupName;
    } else {
        group_name = "";
    }

    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=DeleteSecurityGroup" + "&";

    if (group_id != "") {
        canonicalQueryString = canonicalQueryString + "GroupId" + "=" + group_id + "&";
    }

    if (group_name != "") {
        canonicalQueryString = canonicalQueryString + "GroupName" + "=" + group_name + "&";
    }

    canonicalQueryString = canonicalQueryString + "Version" + "=" + API_VERSION;
    string constructCanonicalString = "/?" + canonicalQueryString;
    request.setHeader(HOST, host);
    var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);

    if (signature is error) {
        error err = error(AMAZONEC2_ERROR_CODE, { ^"error": signature.detail(),
            message: "Error occurred while generating the amazon signature header" });
        return err;
    } else {
        var response = self.amazonClient->get(untaint constructCanonicalString, message = request);

        if (response is http:Response) {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            if (amazonResponse is xml) {
                if (statusCode == 200) {
                    EC2ServiceResponse serviceResponse = {};
                    serviceResponse.success = boolean.convert(amazonResponse["return"].getTextValue());
                    return serviceResponse;
                } else {
                    return setResponseError(amazonResponse);
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE,
                { message: "Error occurred while accessing the XML payload of the response" });
                return err;
            }
        } else {
            error err = error(AMAZONEC2_ERROR_CODE, { message: "Error occurred while invoking the amazonec2 API" });
            return err;
        }
    }
}

public remote function Client.createVolume(string availabilityZone, int? size = (), string? snapshotId = (),
                                           string? volumeType = ()) returns Volume|error {

    int volumeSize = 0;
    string volumeSnapshotId = "";
    string vType = "";

    if (size is int) {
        volumeSize = size;
    } else {
        volumeSize = 0;
    }

    if (snapshotId is string) {
        volumeSnapshotId = snapshotId;
    } else {
        volumeSnapshotId = "";
    }

    if (volumeType is string) {
        vType = volumeType;
    } else {
        vType = "";
    }

    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=CreateVolume" + "&" + "AvailabilityZone" + "=" + availabilityZone + "&";

    if (volumeSize != 0) {
        canonicalQueryString = canonicalQueryString + "Size" + "=" + string.convert(volumeSize) + "&";
    }

    if (volumeSnapshotId != "") {
        canonicalQueryString = canonicalQueryString + "SnapshotId" + "=" + volumeSnapshotId + "&";
    }
    canonicalQueryString = canonicalQueryString + "Version" + "=" + API_VERSION;

    if (vType != "") {
        canonicalQueryString = canonicalQueryString + "&" + "VolumeType" + "=" + vType;
    }
    string constructCanonicalString = "/?" + canonicalQueryString;
    request.setHeader(HOST, host);
    var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);

    if (signature is error) {
        error err = error(AMAZONEC2_ERROR_CODE, { ^"error": signature.detail(),
            message: "Error occurred while generating the amazon signature header" });
        return err;
    } else {
        var response = self.amazonClient->get(constructCanonicalString, message = request);
        if (response is http:Response) {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            if (amazonResponse is xml) {
                if (statusCode == 200) {
                    return getVolumeList(amazonResponse);
                } else {
                    return setResponseError(amazonResponse);
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE,
                { message: "Error occurred while accessing the XML payload of the response" });
                return err;
            }
        } else {
            error err = error(AMAZONEC2_ERROR_CODE, { message: "Error occurred while invoking the amazonec2 API" });
            return err;
        }
    }
}

public remote function Client.attachVolume(string device, string instanceId, string volumeId)
                                  returns AttachmentInfo|error {

    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=AttachVolume" + "&" + "Device" + "=" + device + "&" + "InstanceId" + "="
        + instanceId + "&" + "Version" + "=" + API_VERSION + "&" + "VolumeId" + "=" + volumeId;
    string constructCanonicalString = "/?" + canonicalQueryString;
    request.setHeader(HOST, host);
    var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);

    if (signature is error) {
        error err = error(AMAZONEC2_ERROR_CODE, { ^"error": signature.detail(),
            message: "Error occurred while generating the amazon signature header" });
        return err;
    } else {
        var response = self.amazonClient->get(constructCanonicalString, message = request);

        if (response is http:Response) {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            if (amazonResponse is xml) {
                if (statusCode == 200) {
                    return getVolumeAttachmentList(amazonResponse);
                } else {
                    return setResponseError(amazonResponse);
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE,
                { message: "Error occurred while accessing the XML payload of the response" });
                return err;
            }
        } else {
            error err = error(AMAZONEC2_ERROR_CODE, { message: "Error occurred while invoking the amazonec2 API" });
            return err;
        }
    }
}

public remote function Client.detachVolume(boolean force = false, string volumeId) returns AttachmentInfo|error {

    string httpMethod = "GET";
    string requestURI = "/";
    string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
    string amazonEndpoint = "https://" + host;
    http:Request request = new;
    string canonicalQueryString = "Action=DetachVolume" + "&" + "Force" + "=" + force + "&" +
        "Version" + "=" + API_VERSION + "&" + "VolumeId" + "=" + volumeId;
    string constructCanonicalString = "/?" + canonicalQueryString;
    request.setHeader(HOST, host);
    var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "",
        canonicalQueryString);

    if (signature is error) {
        error err = error(AMAZONEC2_ERROR_CODE, { ^"error": signature.detail(),
            message: "Error occurred while generating the amazon signature header" });
        return err;
    } else {
        var response = self.amazonClient->get(constructCanonicalString, message = request);

        if (response is http:Response) {
            int statusCode = response.statusCode;
            var amazonResponse = response.getXmlPayload();
            if (amazonResponse is xml) {
                if (statusCode == 200) {
                    return getVolumeAttachmentList(amazonResponse);
                } else {
                    return setResponseError(amazonResponse);
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE,
                { message: "Error occurred while accessing the XML payload of the response" });
                return err;
            }
        } else {
            error err = error(AMAZONEC2_ERROR_CODE, { message: "Error occurred while invoking the amazonec2 API" });
            return err;
        }
    }
}
