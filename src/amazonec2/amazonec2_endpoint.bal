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
import ballerina/stringutils;

# AmazonEC2 Client object.
# + accessKeyId - The access key of the Amazon EC2 account
# + secretAccessKey - The secret key of the Amazon EC2 account
# + securityToken - When you are using temporary security credentials (i.e., the accessKeyId and secretAccessKey),
#                   the API request must include this session token, which is returned along with those temporary
#                   credentials. AWS uses the session token to validate the temporary security credentials.
# + region - The AWS region
# + amazonClient - HTTP client endpoint config
public type Client client object {

    public string accessKeyId;
    public string secretAccessKey;
    public string? securityToken = ();
    public string region;
    public http:Client amazonClient;

    public function __init(AmazonEC2Configuration amazonec2Config) {
        string ec2Endpoint = "https://ec2." + amazonec2Config.region + ".amazonaws.com";
        self.amazonClient = new(ec2Endpoint, config = amazonec2Config.clientConfig);
        self.accessKeyId = amazonec2Config.accessKeyId;
        self.secretAccessKey = amazonec2Config.secretAccessKey;
        var token = amazonec2Config.securityToken;
        if ((token is string) && token != "") {
            self.securityToken = token;
        }
        self.region = amazonec2Config.region;
    }

    # Launches the specified number of instances using an AMI for which you have permissions.
    # + imgId -  The ID of the AMI which is required to launch an instance
    # + maxCount - The maximum number of instances to launch
    # + minCount - The minimum number of instances to launch
    # + securityGroup - [EC2-Classic, default VPC] One or more security group names
    # + securityGroupId - One or more security group IDs
    # + return - If success, returns EC2Instance of launched instances, else returns error
    public remote function runInstances(string imgId, int maxCount, int minCount, public string[]? securityGroup = (),
                                        public string[]? securityGroupId = ()) returns @tainted EC2Instance[]|error {
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

        canonicalQueryString = canonicalQueryString + "MaxCount" + "=" + maxCount.toString() + "&" + "MinCount" + "=" + minCount.toString() + "&";

        if (groupNames.length() > 0) {
            int i = 1;
            foreach var name in groupNames {
                canonicalQueryString = canonicalQueryString + "SecurityGroup." + i.toString() + "=" + name + "&";
                i = i + 1;
            }
        }

        if (groupIds.length() > 0) {
            int j = 1;
            foreach var id in groupIds {
                canonicalQueryString = canonicalQueryString + "SecurityGroupId." + j.toString() + "=" + id + "&";
                j = j + 1;
            }
        }

        canonicalQueryString = canonicalQueryString + "Version" + "=" + API_VERSION;
        string constructCanonicalString = "/?" + canonicalQueryString;
        request.setHeader(HOST, host);
        var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.securityToken, self.region,
            GET, requestURI, "", canonicalQueryString);

        if (signature is error) {
            error err = error(AMAZONEC2_ERROR_CODE, cause = signature,
                message = "Error occurred while generating the amazon signature header" );
            return err;
        } else {
            var response = self.amazonClient->get(constructCanonicalString, message = request);
            if (response is http:Response) {
                var amazonResponse = response.getXmlPayload();
                if (amazonResponse is xml) {
                    if (response.statusCode == http:STATUS_OK) {
                        return getSpawnedInstancesList(amazonResponse);
                    } else {
                        return setResponseError(amazonResponse);
                    }
                } else {
                    error err = error(AMAZONEC2_ERROR_CODE,
                    message = "Error occurred while accessing the XML payload of the response");
                    return err;
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE, message = "Error occurred while invoking the amazonec2 API");
                return err;
            }
        }
    }

    # Describes one or more of your instances.
    # + instanceIds -  Array of instanceIds to describe those
    # + return - If successful, returns EC2Instance[] with zero or more instances, else returns an error
    public remote function describeInstances(string... instanceIds) returns @tainted EC2Instance[]|error {
        string httpMethod = "GET";
        string requestURI = "/";
        string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
        string amazonEndpoint = "https://" + host;
        http:Request request = new;
        string canonicalQueryString = "Action=DescribeInstances&";
        if (instanceIds.length() > 0) {
            int i = 1;
            foreach var instances in instanceIds {
                canonicalQueryString = canonicalQueryString + "InstanceId." + i.toString() + "=" + instances + "&";
                i = i + 1;
            }
        }
        canonicalQueryString = canonicalQueryString + "Version" + "=" + API_VERSION;
        string constructCanonicalString = "/?" + canonicalQueryString;
        request.setHeader(HOST, host);
        var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.securityToken, self.region,
            GET, requestURI, "", canonicalQueryString);
        if (signature is error) {
            error err = error(AMAZONEC2_ERROR_CODE, cause = signature,
                message = "Error occurred while generating the amazon signature header");
            return err;
        } else {
            var response = self.amazonClient->get(constructCanonicalString, message = request);
            if (response is http:Response) {
                var amazonResponse = response.getXmlPayload();
                if (amazonResponse is xml) {
                    if (response.statusCode == http:STATUS_OK) {
                        return getInstanceList(amazonResponse);
                    } else {
                        return setResponseError(amazonResponse);
                    }
                } else {
                    error err = error(AMAZONEC2_ERROR_CODE,
                        message = "Error occurred while accessing the XML payload of the response");
                    return err;
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE, message = "Error occurred while invoking the AmazonEc2 API");
                return err;
            }
        }
    }

    # Shuts down one or more instances.
    # + instanceArray -  Array of instanceIds to terminate those
    # + return - If success, returns EC2Instance with terminated instances, else returns error
    public remote function terminateInstances(string... instanceArray) returns @tainted EC2Instance[]|error {
        string httpMethod = "GET";
        string requestURI = "/";
        string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
        string amazonEndpoint = "https://" + host;
        http:Request request = new;
        string canonicalQueryString = "Action=TerminateInstances&";
        int i = 1;
        foreach var instances in instanceArray {
            canonicalQueryString = canonicalQueryString + "InstanceId." + i.toString() + "=" + instances + "&";
            i = i + 1;
        }

        canonicalQueryString = canonicalQueryString + "Version" + "=" + API_VERSION;
        string constructCanonicalString = "/?" + canonicalQueryString;
        var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.securityToken, self.region,
            GET, requestURI, "", canonicalQueryString);
        if (signature is error) {
            error err = error(AMAZONEC2_ERROR_CODE, cause = signature,
                message = "Error occurred while generating the amazon signature header");
            return err;
        } else {
            var response = self.amazonClient->get(<@untainted> constructCanonicalString, message = request);

            if (response is http:Response) {
                var amazonResponse = response.getXmlPayload();
                if (amazonResponse is xml) {
                    if (response.statusCode == http:STATUS_OK) {
                        return getTerminatedInstancesList(amazonResponse);
                    } else {
                        return setResponseError(amazonResponse);
                    }
                } else {
                    error err = error(AMAZONEC2_ERROR_CODE,
                        message = "Error occurred while accessing the XML payload of the response");
                    return err;
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE, message = "Error occurred while invoking the amazonec2 API");
                return err;
            }
        }
    }

    # Create image.
    # + instanceId -  The ID of the instance which is created with the particular image id
    # + name - The name of the image
    # + return - If successful, returns Image with image id, else returns an error
    public remote function createImage(string instanceId, string name) returns @tainted Image|error {
        string httpMethod = "GET";
        string requestURI = "/";
        string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
        string amazonEndpoint = "https://" + host;
        http:Request request = new;
        string canonicalQueryString = "Action=CreateImage" + "&" + "InstanceId" + "=" + instanceId + "&" + "Name" + "=" +
            name + "&" + "Version" + "=" + API_VERSION;
        string constructCanonicalString = "/?" + canonicalQueryString;
        if (stringutils:contains(constructCanonicalString, " ")) {
            constructCanonicalString = stringutils:replace(constructCanonicalString," ", "+");
        }
        request.setHeader(HOST, host);
        var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.securityToken, self.region,
            GET, requestURI, "", canonicalQueryString);

        if (signature is error) {
            error err = error(AMAZONEC2_ERROR_CODE, cause = signature,
                message = "Error occurred while generating the amazon signature header");
            return err;
        } else {
            var response = self.amazonClient->get(constructCanonicalString, message = request);

            if (response is http:Response) {
                var amazonResponse = response.getXmlPayload();
                if (amazonResponse is xml) {
                    if (response.statusCode == http:STATUS_OK) {
                        Image image = { imageId: amazonResponse["imageId"].getTextValue() };
                        return image;
                    } else {
                        return setResponseError(amazonResponse);
                    }
                } else {
                    error err = error(AMAZONEC2_ERROR_CODE,
                        message = "Error occurred while accessing the XML payload of the response");
                    return err;
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE, message = "Error occurred while invoking the amazonec2 API");
                return err;
            }
        }
    }

    # Describe images.
    # + imgIdArr -  The string of AMI array to describe those images
    # + return - If successful, returns Image[] with image details, else returns an error
    public remote function describeImages(string... imgIdArr) returns @tainted Image[]|error {
        string httpMethod = "GET";
        string requestURI = "/";
        string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
        string amazonEndpoint = "https://" + host;
        http:Request request = new;
        string canonicalQueryString = "Action=DescribeImages" + "&";
        if (imgIdArr.length() > 0) {
            int i = 1;
            foreach var instances in imgIdArr {
                canonicalQueryString = canonicalQueryString + "ImageId." + i.toString() + "=" + instances + "&";
                i = i + 1;
            }
        }
        canonicalQueryString = canonicalQueryString + "Version" + "=" + API_VERSION;
        string constructCanonicalString = "/?" + canonicalQueryString;
        request.setHeader(HOST, host);
        var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.securityToken, self.region,
            GET, requestURI, "", canonicalQueryString);
        if (signature is error) {
            error err = error(AMAZONEC2_ERROR_CODE, cause = signature,
                message = "Error occurred while generating the amazon signature header");
            return err;
        } else {
            var response = self.amazonClient->get(<@untainted> constructCanonicalString, message = request);

            if (response is http:Response) {
                var amazonResponse = response.getXmlPayload();
                if (amazonResponse is xml) {
                    if (response.statusCode == http:STATUS_OK) {
                        return getSpawnedImageList(amazonResponse);
                    } else {
                        return setResponseError(amazonResponse);
                    }
                } else {
                    error err = error(AMAZONEC2_ERROR_CODE,
                        message = "Error occurred while accessing the XML payload of the response");
                    return err;
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE, message = "Error occurred while invoking the amazonec2 API");
                return err;
            }
        }
    }

    # Deregisters the specified AMI. After you deregister an AMI, it can't be used to launch new instances.
    # + imgId - The ID of the AMI
    # + return - If successful, returns success response, else returns an error
    public remote function deregisterImage(string imgId) returns @tainted EC2ServiceResponse|error {
        string httpMethod = "GET";
        string requestURI = "/";
        string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
        string amazonEndpoint = "https://" + host;
        http:Request request = new;
        string canonicalQueryString = "Action=DeregisterImage" + "&" + "ImageId" + "=" + imgId + "&" +
            "Version" + "=" + API_VERSION;
        string constructCanonicalString = "/?" + canonicalQueryString;
        request.setHeader(HOST, host);
        var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.securityToken, self.region,
            GET, requestURI, "", canonicalQueryString);

        if (signature is error) {
            error err = error(AMAZONEC2_ERROR_CODE, cause = signature,
                message = "Error occurred while generating the amazon signature header");
            return err;
        } else {
            var response = self.amazonClient->get(constructCanonicalString, message = request);

            if (response is http:Response) {
                var amazonResponse = response.getXmlPayload();
                if (amazonResponse is xml) {
                    if (response.statusCode == http:STATUS_OK) {
                        EC2ServiceResponse serviceResponse =
                        { success: convertToBoolean(amazonResponse["return"].getTextValue())};
                        return serviceResponse;
                    } else {
                        return setResponseError(amazonResponse);
                    }
                } else {
                    error err = error(AMAZONEC2_ERROR_CODE,
                        message = "Error occurred while accessing the XML payload of the response");
                    return err;
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE, message = "Error occurred while invoking the amazonec2 API");
                return err;
            }
        }
    }

    # Describes the specified attribute of the specified AMI. You can specify only one attribute at a time.
    # + amiId - The ID of the AMI
    # + attribute - The specific attribute of the image
    # + return - If successful, returns success response, else returns an error
    public remote function describeImageAttribute(string amiId, string attribute) returns @tainted ImageAttribute|error {
        string httpMethod = "GET";
        string requestURI = "/";
        string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
        string amazonEndpoint = "https://" + host;
        http:Request request = new;
        string canonicalQueryString = "Action=DescribeImageAttribute" + "&" + "Attribute" + "=" + attribute + "&" +
            "ImageId" + "=" + amiId + "&" + "Version" + "=" + API_VERSION;
        string constructCanonicalString = "/?" + canonicalQueryString;
        request.setHeader(HOST, host);
        var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.securityToken, self.region,
            GET, requestURI, "", canonicalQueryString);

        if (signature is error) {
            error err = error(AMAZONEC2_ERROR_CODE, cause = signature,
                message = "Error occurred while generating the amazon signature header");
            return err;
        } else {
            var response = self.amazonClient->get(constructCanonicalString, message = request);

            if (response is http:Response) {
                var amazonResponse = response.getXmlPayload();
                if (amazonResponse is xml) {
                    if (response.statusCode == http:STATUS_OK) {
                        return getAttributeValue(attribute, amazonResponse);
                    } else {
                        return setResponseError(amazonResponse);
                    }
                } else {
                    error err = error(AMAZONEC2_ERROR_CODE,
                        message = "Error occurred while accessing the XML payload of the response");
                    return err;
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE, message = "Error occurred while invoking the amazonec2 API");
                return err;
            }
        }
    }

    # Initiates the copy of an AMI from the specified source region to the current region.
    # + name -  The name of the new AMI in the destination region
    # + sourceImageId - The ID of the AMI to copy
    # + sourceRegion - The name of the region that contains the AMI to copy
    # + return - If successful, returns Image object, else returns an error
    public remote function copyImage(string name, string sourceImageId, string sourceRegion) returns @tainted Image|error {
        string httpMethod = "GET";
        string requestURI = "/";
        string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
        string amazonEndpoint = "https://" + host;
        http:Request request = new;
        string canonicalQueryString = "Action=CopyImage" + "&" + "Name" + "=" + name + "&" + "SourceImageId" + "=" +
            sourceImageId + "&" + "SourceRegion" + "=" + sourceRegion + "&" + "Version" + "=" + API_VERSION;
        string constructCanonicalString = "/?" + canonicalQueryString;
        request.setHeader(HOST, host);
        var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.securityToken, self.region,
            GET, requestURI, "", canonicalQueryString);

        if (signature is error) {
            error err = error(AMAZONEC2_ERROR_CODE, cause = signature,
                message = "Error occurred while generating the amazon signature header");
            return err;
        } else {
            var response = self.amazonClient->get(constructCanonicalString, message = request);
            if (response is http:Response) {
                var amazonResponse = response.getXmlPayload();
                if (amazonResponse is xml) {
                    if (response.statusCode == http:STATUS_OK) {
                        Image image = { imageId: amazonResponse["imageId"].getTextValue() };
                        return image;
                    } else {
                        return setResponseError(amazonResponse);
                    }
                } else {
                    error err = error(AMAZONEC2_ERROR_CODE,
                        message = "Error occurred while accessing the XML payload of the response");
                    return err;
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE, message = "Error occurred while invoking the amazonec2 API");
                return err;
            }
        }
    }

    # Creates a security group.
    # + groupName - The name of the security group
    # + groupDescription - A description for the security group
    # + vpcId - The ID of the VPC, Required for EC2-VPC
    # + return - If successful, returns SecurityGroup object with groupId, else returns an error
    public remote function createSecurityGroup(string groupName, string groupDescription, public string? vpcId = ())
                               returns @tainted SecurityGroup|error {
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

        if (stringutils:contains(constructCanonicalString, " ")) {
            constructCanonicalString = stringutils:replace(constructCanonicalString," ", "+");
        }

        request.setHeader(HOST, host);
        var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.securityToken, self.region,
            GET, requestURI, "", canonicalQueryString);

        if (signature is error) {
            error err = error(AMAZONEC2_ERROR_CODE, cause = signature,
                message = "Error occurred while generating the amazon signature header");
            return err;
        } else {
            var response = self.amazonClient->get(<@untainted> constructCanonicalString, message = request);
            if (response is http:Response) {
                var amazonResponse = response.getXmlPayload();
                if (amazonResponse is xml) {
                    if (response.statusCode == http:STATUS_OK) {
                        SecurityGroup securityGroup = { groupId: amazonResponse["groupId"].getTextValue() };
                        return securityGroup;
                    } else {
                        return setResponseError(amazonResponse);
                    }
                } else {
                    error err = error(AMAZONEC2_ERROR_CODE,
                        message = "Error occurred while accessing the XML payload of the response");
                    return err;
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE, message = "Error occurred while invoking the amazonec2 API");
                return err;
            }
        }
    }

    # Deletes a security group. Can specify either the security group name or the security group ID,
    # But group id is required for a non default VPC.
    # + groupId -  The id of the security group
    # + groupName - The name of the security group
    # + return - If successful, returns success response, else returns an error
    public remote function deleteSecurityGroup(public string? groupId = (), public string? groupName = ())
                               returns @tainted EC2ServiceResponse|error {
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
        var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.securityToken, self.region,
            GET, requestURI, "", canonicalQueryString);

        if (signature is error) {
            error err = error(AMAZONEC2_ERROR_CODE, cause = signature,
                message = "Error occurred while generating the amazon signature header");
            return err;
        } else {
            var response = self.amazonClient->get(<@untainted> constructCanonicalString, message = request);

            if (response is http:Response) {
                var amazonResponse = response.getXmlPayload();
                if (amazonResponse is xml) {
                    if (response.statusCode == http:STATUS_OK) {
                        EC2ServiceResponse serviceResponse =
                        { success: convertToBoolean(amazonResponse["return"].getTextValue()) };
                        return serviceResponse;
                    } else {
                        return setResponseError(amazonResponse);
                    }
                } else {
                    error err = error(AMAZONEC2_ERROR_CODE,
                        message = "Error occurred while accessing the XML payload of the response");
                    return err;
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE, message = "Error occurred while invoking the amazonec2 API");
                return err;
            }
        }
    }

    # Creates an EBS volume that can be attached to an instance in the same Availability Zone.
    # + availabilityZone - The Availability Zone in which to create the volume
    # + size - The size of the volume, in GiBs
    # + snapshotId - The snapshot from which to create the volume
    # + volumeType - The volume type
    # + return - If successful, returns Volume object with created volume details, else returns an error
    public remote function createVolume(string availabilityZone, public int? size = (), public string? snapshotId = (),
                                        public string? volumeType = ()) returns @tainted Volume|error {
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
            canonicalQueryString = canonicalQueryString + "Size" + "=" + volumeSize.toString() + "&";
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
        var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.securityToken, self.region,
            GET, requestURI, "", canonicalQueryString);

        if (signature is error) {
            error err = error(AMAZONEC2_ERROR_CODE, cause = signature,
                message = "Error occurred while generating the amazon signature header");
            return err;
        } else {
            var response = self.amazonClient->get(constructCanonicalString, message = request);
            if (response is http:Response) {
                var amazonResponse = response.getXmlPayload();
                if (amazonResponse is xml) {
                    if (response.statusCode == http:STATUS_OK) {
                        return getVolumeList(amazonResponse);
                    } else {
                        return setResponseError(amazonResponse);
                    }
                } else {
                    error err = error(AMAZONEC2_ERROR_CODE,
                        message = "Error occurred while accessing the XML payload of the response");
                    return err;
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE, message = "Error occurred while invoking the amazonec2 API");
                return err;
            }
        }
    }

    # Attaches an EBS volume to a running or stopped instance and exposes it to the instance with the specified
    # device name.
    # + device - The device name
    # + instanceId - The ID of the instance
    # + volumeId - The ID of the EBS volume, The volume and instance must be within the same Availability Zone
    # + return - If successful, returns Attachment information, else returns an error
    public remote function attachVolume(string device, string instanceId, string volumeId) returns @tainted AttachmentInfo|error {
        string httpMethod = "GET";
        string requestURI = "/";
        string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
        string amazonEndpoint = "https://" + host;
        http:Request request = new;
        string canonicalQueryString = "Action=AttachVolume" + "&" + "Device" + "=" + device + "&" + "InstanceId" + "="
            + instanceId + "&" + "Version" + "=" + API_VERSION + "&" + "VolumeId" + "=" + volumeId;
        string constructCanonicalString = "/?" + canonicalQueryString;
        request.setHeader(HOST, host);
        var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.securityToken, self.region,
            GET, requestURI, "", canonicalQueryString);

        if (signature is error) {
            error err = error(AMAZONEC2_ERROR_CODE, cause = signature,
                message = "Error occurred while generating the amazon signature header");
            return err;
        } else {
            var response = self.amazonClient->get(constructCanonicalString, message = request);

            if (response is http:Response) {
                var amazonResponse = response.getXmlPayload();
                if (amazonResponse is xml) {
                    if (response.statusCode == http:STATUS_OK) {
                        return getVolumeAttachmentList(amazonResponse);
                    } else {
                        return setResponseError(amazonResponse);
                    }
                } else {
                    error err = error(AMAZONEC2_ERROR_CODE,
                        message = "Error occurred while accessing the XML payload of the response");
                    return err;
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE, message = "Error occurred while invoking the amazonec2 API");
                return err;
            }
        }
    }

    # Detaches an EBS volume from an instance.
    # + force - Forces detachment if the previous detachment attempt did not occur cleanly
    # + volumeId - The ID of the volume
    # + return - If successful, returns detached volume information, else returns an error
    public remote function detachVolume(string volumeId, boolean force = false) returns @tainted AttachmentInfo|error {
        string httpMethod = "GET";
        string requestURI = "/";
        string host = SERVICE_NAME + "." + self.region + "." + "amazonaws.com";
        string amazonEndpoint = "https://" + host;
        http:Request request = new;
        string canonicalQueryString = "Action=DetachVolume" + "&" + "Force" + "=" + force.toString() + "&" +
            "Version" + "=" + API_VERSION + "&" + "VolumeId" + "=" + volumeId;
        string constructCanonicalString = "/?" + canonicalQueryString;
        request.setHeader(HOST, host);
        var signature = generateSignature(request, self.accessKeyId, self.secretAccessKey, self.securityToken, self.region,
            GET, requestURI, "", canonicalQueryString);

        if (signature is error) {
            error err = error(AMAZONEC2_ERROR_CODE, cause = signature,
                message = "Error occurred while generating the amazon signature header");
            return err;
        } else {
            var response = self.amazonClient->get(constructCanonicalString, message = request);

            if (response is http:Response) {
                var amazonResponse = response.getXmlPayload();
                if (amazonResponse is xml) {
                    if (response.statusCode == http:STATUS_OK) {
                        return getVolumeAttachmentList(amazonResponse);
                    } else {
                        return setResponseError(amazonResponse);
                    }
                } else {
                    error err = error(AMAZONEC2_ERROR_CODE,
                        message = "Error occurred while accessing the XML payload of the response");
                    return err;
                }
            } else {
                error err = error(AMAZONEC2_ERROR_CODE, message = "Error occurred while invoking the amazonec2 API");
                return err;
            }
        }
    }
};
