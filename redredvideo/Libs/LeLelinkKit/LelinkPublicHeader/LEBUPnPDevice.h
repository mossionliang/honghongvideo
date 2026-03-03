//
//  LEBUPnPDevice.h
//  LEBDMC
//
//  Created by 刘明星 on 2018/3/22.
//  Copyright © 2018年 刘明星. All rights reserved.
//

#import "LBBaseModel.h"
#import "LBLelinkBase.h"
/**
 服务模型，一个逻辑设备所提供的服务
 */
@interface LEBUPnPService : LBBaseModel

/**
 必有字段
 UPnP服务类型
    服务类型                            表示文字
 UPnP_MediaServer1          urn:schemas-upnp-org:device:MediaServer:1
 UPnP_MediaRenderer1        urn:schemas-upnp-org:device:MediaRenderer:1
 UPnP_ContentDirectory1     urn:schemas-upnp-org:service:ContentDirectory:1
 UPnP_RenderingControl1     urn:schemas-upnp-org:service:RenderingControl:1
 UPnP_ConnectionManager1    urn:schemas-upnp-org:service:ConnectionManager:1
 UPnP_AVTransport1          urn:schemas-upnp-org:service:AVTransport:1
*/
@property (nonatomic, copy) NSString *serviceType;

/** 必有字段    服务表示符，是服务实例的唯一标识  如：urn:upnp-org:serviceId:AVTransport */
@property (nonatomic, copy) NSString *serviceId;

/** 必有字段    向服务发出控制消息的URL   如：/dev/88024158-a0e8-2dd5-ffff-ffffc7831a22/svc/upnp-org/AVTransport/action */
@property (nonatomic, copy) NSString *controlURL;

/** 必有字段    订阅该服务时间的URL 如：/dev/88024158-a0e8-2dd5-ffff-ffffc7831a22/svc/upnp-org/AVTransport/event */
@property (nonatomic, copy) NSString *eventSubURL;

/** 必有字段    Service Control Protocol Description URL，获取设备描述文档URL    如：/dev/88024158-a0e8-2dd5-ffff-ffffc7831a22/svc/upnp-org/AVTransport/desc.xml */
@property (nonatomic, copy) NSString *SCPDURL;

/** 可选字段，乐联服务地址和端口  默认为空字符串 */
@property (nonatomic, copy) NSString *LELINKFT;

- (void)setArray:(NSArray *)array;

/**
 提供本类对象的等同性判断方法
 
 @param object 比较的对象
 @return 是否等同，YES：等同，NO：不等同
 */
- (BOOL)isEqualToLEBUPnPService:(LEBUPnPService *)object;

@end

/**
 设备模型，一个提供各种服务的逻辑设备
 */
@interface LEBUPnPDevice : LBBaseModel

/** 设备的唯一标识符 */
@property (nonatomic, copy) NSString *uuid;

@property (nonatomic, copy) NSString *tvUID;

@property (nonatomic, copy) NSString *udn;

/** 包含根设备描述得URL地址  device 的webservice路径 */
@property (nonatomic, strong) NSURL     *loaction;

@property (nonatomic, copy) NSString    *URLHeader;

/** 设备名称 如：乐投A8 */
@property (nonatomic, copy) NSString *friendlyName;
@property (nonatomic, copy) NSString *modelName;
@property (nonatomic, copy) NSString *modelDescription;
@property (nonatomic, copy) NSString *manufacturer;


@property (nonatomic, copy) NSString *ipString;
@property (nonatomic, copy) NSString *port;
@property (nonatomic, copy) NSString *urlString;

@property (nonatomic, copy) NSString *timestamp;

/**
 * 接收端渠道支持引流的字段
 * 举例如下：
 （B渠道打开 ： drainage：1）
 00000000 000000000 00000000 00000001
 （只打开西瓜渠道 drainage：2）
 000000000 00000000 00000000 00000010
 （B站和西瓜渠道都打开引流 ：drainage：3）
 00000000 00000000 00000000 00000011
 （假设有32个渠道每个渠道都打开 ：drainage：65535）
 11111111 11111111 11111111 11111111
 */
@property (nonatomic, copy) NSString    *drainage; // 引流功能

@property (nonatomic, strong) LEBUPnPService *AVTransport;
@property (nonatomic, strong) LEBUPnPService *RenderingControl;
@property (nonatomic, strong) LEBUPnPService *lelinkService; // 乐联设备
@property (nonatomic, assign) LBLelinkServiceSourceStyle sourceStyle;

- (void)setArray:(NSArray *)array;

/**
 提供本类对象的等同性判断方法
 
 @param object 比较的对象
 @return 是否等同，YES：等同，NO：不等同
 */
- (BOOL)isEqualToLEBUPnPDevice:(LEBUPnPDevice *)object;

@end


/**
 HTTP/1.1 200 OK
 Content-Length    : 3612
 Content-type      : text/xml
 Date              : Tue, 01 Mar 2016 10:00:36 GMT+00:00
 
 <?xml version="1.0" encoding="UTF-8"?>
 <root xmlns="urn:schemas-upnp-org:device-1-0" xmlns:qq="http://www.tencent.com">
 <specVersion>
 <major>1</major>
 <minor>0</minor>
 </specVersion>
 <device>
 <deviceType>urn:schemas-upnp-org:device:MediaRenderer:1</deviceType>
 <UDN>uuid:88024158-a0e8-2dd5-ffff-ffffc7831a22</UDN>
 <friendlyName>客厅的小米盒子</friendlyName>
 <qq:X_QPlay_SoftwareCapability>QPlay:1</qq:X_QPlay_SoftwareCapability>
 <manufacturer>Xiaomi</manufacturer>
 <manufacturerURL>http://www.xiaomi.com/</manufacturerURL>
 <modelDescription>Xiaomi MediaRenderer</modelDescription>
 <modelName>Xiaomi MediaRenderer</modelName>
 <modelNumber>1</modelNumber>
 <modelURL>http://www.xiaomi.com/hezi</modelURL>
 <serialNumber>11262/180303452</serialNumber>
 <presentationURL>device_presentation_page.html</presentationURL>
 <UPC>123456789012</UPC>
 <dlna:X_DLNADOC xmlns:dlna="urn:schemas-dlna-org:device-1-0">DMR-1.50</dlna:X_DLNADOC>
 <dlna:X_DLNACAP xmlns:dlna="urn:schemas-dlna-org:device-1-0">,</dlna:X_DLNACAP>
 <iconList>
 <icon>
 <mimetype>image/png</mimetype>
 <width>128</width>
 <height>128</height>
 <depth>8</depth>
 <url>icon/icon128x128.png</url>
 </icon>
 </iconList>
 <serviceList>
 <service>
 <serviceType>urn:schemas-upnp-org:service:AVTransport:1</serviceType>
 <serviceId>urn:upnp-org:serviceId:AVTransport</serviceId>
 <controlURL>/dev/88024158-a0e8-2dd5-ffff-ffffc7831a22/svc/upnp-org/AVTransport/action</controlURL>
 <eventSubURL>/dev/88024158-a0e8-2dd5-ffff-ffffc7831a22/svc/upnp-org/AVTransport/event</eventSubURL>
 <SCPDURL>/dev/88024158-a0e8-2dd5-ffff-ffffc7831a22/svc/upnp-org/AVTransport/desc.xml</SCPDURL>
 </service>
 <service>
 <serviceType>urn:schemas-upnp-org:service:RenderingControl:1</serviceType>
 <serviceId>urn:upnp-org:serviceId:RenderingControl</serviceId>
 <controlURL>/dev/88024158-a0e8-2dd5-ffff-ffffc7831a22/svc/upnp-org/RenderingControl/action</controlURL>
 <eventSubURL>/dev/88024158-a0e8-2dd5-ffff-ffffc7831a22/svc/upnp-org/RenderingControl/event</eventSubURL>
 <SCPDURL>/dev/88024158-a0e8-2dd5-ffff-ffffc7831a22/svc/upnp-org/RenderingControl/desc.xml</SCPDURL>
 </service>
 <service>
 <serviceType>urn:schemas-upnp-org:service:ConnectionManager:1</serviceType>
 <serviceId>urn:upnp-org:serviceId:ConnectionManager</serviceId>
 <controlURL>/dev/88024158-a0e8-2dd5-ffff-ffffc7831a22/svc/upnp-org/ConnectionManager/action</controlURL>
 <eventSubURL>/dev/88024158-a0e8-2dd5-ffff-ffffc7831a22/svc/upnp-org/ConnectionManager/event</eventSubURL>
 <SCPDURL>/dev/88024158-a0e8-2dd5-ffff-ffffc7831a22/svc/upnp-org/ConnectionManager/desc.xml</SCPDURL>
 </service>
 <service>
 <serviceType>urn:mi-com:service:RController:1</serviceType>
 <serviceId>urn:upnp-org:serviceId:RController</serviceId>
 <controlURL>/dev/88024158-a0e8-2dd5-ffff-ffffc7831a22/svc/upnp-org/RController/action</controlURL>
 <eventSubURL>/dev/88024158-a0e8-2dd5-ffff-ffffc7831a22/svc/upnp-org/RController/event</eventSubURL>
 <SCPDURL>/dev/88024158-a0e8-2dd5-ffff-ffffc7831a22/svc/upnp-org/RController/desc.xml</SCPDURL>
 </service>
 <!-- 乐联 -->
 <service>
 <serviceType>urn:schemas-upnp-org:service:Lelink:1</serviceType>
 <serviceId>urn:upnp-org:serviceId:Lelink</serviceId>
 <LELINKURL>x.x.x.x（ip）:52244(端口)</LELINKURL>
 </service>
 
 </serviceList>
 <av:X_RController_DeviceInfo xmlns:av="urn:mi-com:av">
 <av:X_RController_Version>1.0</av:X_RController_Version>
 <av:X_RController_ServiceList>
 <av:X_RController_Service>
 <av:X_RController_ServiceType>controller</av:X_RController_ServiceType>
 <av:X_RController_ActionList_URL>http://192.168.1.243:6095/</av:X_RController_ActionList_URL>
 </av:X_RController_Service>
 <av:X_RController_Service>
 <av:X_RController_ServiceType>data</av:X_RController_ServiceType>
 <av:X_RController_ActionList_URL>http://api.tv.duokanbox.com/bolt/3party/</av:X_RController_ActionList_URL>
 </av:X_RController_Service>
 </av:X_RController_ServiceList>
 </av:X_RController_DeviceInfo>
 </device>
 </root>
 */
