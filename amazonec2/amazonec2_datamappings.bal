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
// under the License

function getInstanceList(xml response) returns EC2Instance[] {
    EC2Instance[] list = [];
    int i = 0;
    xml reservationSet = response["reservationSet"]["item"];

    foreach reservation in reservationSet {
        xml instances = reservation.elements();

        foreach inst in instances["instancesSet"]["item"] {
            list[i] = getInstance(inst.elements());
            i++;
        }
    }

    return list;
}

function getSpawnedInstancesList(xml response) returns EC2Instance[] {
    EC2Instance[] list = [];
    int i = 0;
    xml spawnedInstances = response["instancesSet"]["item"];

    foreach inst in spawnedInstances {
        list[i] = getInstance(inst.elements());
        i++;
    }

    return list;
}

function getTerminatedInstancesList(xml response) returns EC2Instance[] {
    EC2Instance[] list = [];
    int i = 0;
    xml terminatedInstances = response["instancesSet"]["item"];

    foreach inst in terminatedInstances {
        xml content = inst.elements();
        EC2Instance instance = {};
        instance.id = content["instanceId"].getTextValue();
        instance.state = getInstanceState(check <int>content["currentState"]["code"].getTextValue());
        instance.previousState = getInstanceState(check <int>content["previousState"]["code"].getTextValue());
        list[i] = instance;
        i++;
    }

    return list;
}

function getInstance(xml content) returns EC2Instance {
    EC2Instance instance = {};
    instance.id = content["instanceId"].getTextValue();
    instance.imageId = content["imageId"].getTextValue();
    instance.iType = content["instanceType"].getTextValue();
    instance.zone = content["placement"]["availabilityZone"].getTextValue();
    instance.state = getInstanceState(check <int>content["instanceState"]["code"].getTextValue());
    instance.privateIpAddress = content["privateIpAddress"].getTextValue();
    instance.ipAddress = content["ipAddress"].getTextValue();
    return instance;
}

function getImage(xml content) returns Image {
    Image image = {};
    image.imageId = content["imageId"].getTextValue();
    image.imageLocation = content["imageLocation"].getTextValue();
    image.imageState = content["imageState"].getTextValue();
    image.creationDate = content["creationDate"].getTextValue();
    image.description = content["description"].getTextValue();
    image.imageType = content["imageType"].getTextValue();
    image.name = content["name"].getTextValue();
    return image;
}

function getImageList(xml response) returns  Image {
    Image image = {};
    image.imageId = response["imageId"].getTextValue();
    return image;
}

function getSpawnedImageList(xml response) returns  Image[] {
    Image[] image = [];
    int i = 0;
    xml imageList = response["imagesSet"]["item"];
    foreach inst in imageList {
        image[i] = getImage(inst.elements());
        i++;
    }
    return image;
}

function getVolumeList(xml content) returns Volume {
    Volume volume = {};
    volume.availabilityZone = content["availabilityZone"].getTextValue();
    volume.size = check <int> content["size"].getTextValue();
    volume.volumeId = content["volumeId"].getTextValue();
    volume.volumeType =  getAttachmentVolumeType(content["volumeType"].getTextValue());
    return volume;
}

function getVolumeAttachmentList(xml content) returns AttachmentInfo {
    AttachmentInfo attachment = {};
    attachment.device = content["device"].getTextValue();
    attachment.volumeId = content["volumeId"].getTextValue();
    attachment.attachTime = content["attachTime"].getTextValue();
    attachment.instanceId = content["instanceId"].getTextValue();
    attachment.status = getAttachmentStatus(content["status"].getTextValue());
    return attachment;
}

function getInstanceState(int status) returns InstanceState {
    if (status == 0) {
        return ISTATE_PENDING;
    } else if (status == 16) {
        return ISTATE_RUNNING;
    } else if (status == 32) {
        return ISTATE_SHUTTING_DOWN;
    } else if (status == 48) {
        return ISTATE_TERMINATED;
    } else if (status == 64) {
        return ISTATE_STOPPING;
    } else if (status == 80) {
        return ISTATE_STOPPED;
    } else {
        error e = {message: "Invalid EC2 instance state: " + status}; // This shouldn't happen
        throw e;
    }
}

function getAttachmentVolumeType(string volumeType) returns VolumeType {
    if (volumeType == "standard") {
        return TYPE_STANDARD;
    } else if (volumeType == "io1") {
        return TYPE_IO1;
    } else if (volumeType == "gp2") {
        return TYPE_GP2;
    } else if (volumeType == "sc1") {
        return TYPE_SC1;
    } else if (volumeType == "st1") {
        return TYPE_ST1;
    } else {
        error e = {message: "Invalid EC2 volume type: " + volumeType};
        throw e;
    }
}

function getAttachmentStatus(string status) returns VolumeAttachmentStatus {
    if (status == "attaching") {
        return ATTACHING;
    } else if (status == "attached") {
        return ATTACHED;
    } else if (status == "detaching") {
        return DETACHING;
    } else if (status == "detached") {
        return DETACHED;
    } else if (status == "busy") {
        return BUSY;
    } else {
        error e = {message: "Invalid EC2 volume attachment status: " + status};
        throw e;
    }
}

function getAttributeValue(string attribute, xml content) returns ImageAttribute {
    if (attribute == "description") {
        return getImageWithDescriptionAttribute(content);
    } else if (attribute == "kernel") {
        return getImageWithKernelAttribute(content);
    } else if (attribute == "launchPermission") {
        return getImageWithLaunchPermissionAttribute(content);
    } else if (attribute == "productCodes") {
        return getImageWithProductCodesAttribute(content);
    } else if (attribute == "blockDeviceMapping") {
        return getImageWithBlockDeviceMappingAttribute(content);
    } else if (attribute == "sriovNetSupport") {
        return getImageWithSriovNetSupportAttribute(content);
    } else if (attribute == "ramdisk") {
        return getImageWithRamDiskAttribute(content);
    } else {
        error e = {message: "Invalid EC2 Image attribute: " + attribute};
        throw e;
    }
}

function getImageWithDescriptionAttribute(xml content) returns DescriptionAttribute {
    DescriptionAttribute descriptionAttribute = {};
    descriptionAttribute.description = content["description"]["value"].getTextValue();
    return descriptionAttribute;
}

function getImageWithKernelAttribute(xml content) returns KernelAttribute {
    KernelAttribute kernelAttribute = {};
    kernelAttribute.kernelId = content["kernel"]["value"].getTextValue();
    return kernelAttribute;
}

function getImageWithLaunchPermissionAttribute(xml content) returns LaunchPermissionAttribute[] {
    LaunchPermissionAttribute[] launchPermissionAttribute = [];
    int i = 0;
    xml permissionList = content["launchPermission"]["item"];
    foreach inst in permissionList {
        xml elements = inst.elements();
        LaunchPermissionAttribute permission = {};
        permission.groupName = elements["group"].getTextValue();
        permission.userId = elements["userId"].getTextValue();
        launchPermissionAttribute[i] = permission;
        i++;
    }
    return launchPermissionAttribute;
}


function getImageWithProductCodesAttribute(xml content) returns ProductCodeAttribute[] {
    ProductCodeAttribute[] productCodeAttribute = [];
    int i = 0;
    xml productCodeList = content["productCode"]["item"];
    foreach inst in productCodeList {
        xml elements = inst.elements();
        ProductCodeAttribute code = {};
        code.productCode = elements["productCode"].getTextValue();
        code.productType = elements["type"].getTextValue();
        productCodeAttribute[i] = code;
        i++;
    }
    return productCodeAttribute;
}


function getImageWithBlockDeviceMappingAttribute(xml content) returns BlockDeviceMapping[] {
    BlockDeviceMapping[] blockDeviceMapping = [];
    int i = 0;
    xml mappingList = content["blockDeviceMapping"]["item"];
    foreach inst in mappingList {
        xml elements = inst.elements();
        BlockDeviceMapping mapping = {};
        mapping.deviceName = elements["deviceName"].getTextValue();
        mapping.noDevice = elements["noDevice"].getTextValue();
        mapping.virtualName = elements["virtualName"].getTextValue();
        blockDeviceMapping[i] = mapping;
        i++;
    }
    return blockDeviceMapping;
}


function getImageWithSriovNetSupportAttribute(xml content) returns SriovNetSupportAttribute {
    SriovNetSupportAttribute sriovNetSupportAttribute = {};
    sriovNetSupportAttribute.sriovNetSupportValue = content["sriovNetSupport"]["value"].getTextValue();
    return sriovNetSupportAttribute;
}

function getImageWithRamDiskAttribute(xml content) returns RamdiskAttribute {
    RamdiskAttribute ramdiskAttribute = {};
    ramdiskAttribute.ramDiskValue = content["ramdisk"]["value"].getTextValue();
    return ramdiskAttribute;
}