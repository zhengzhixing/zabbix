#!/bin/bash
function get_auth_id(){
auth=$(curl -s -X POST -H 'Content-Type:application/json' -d '{
    "jsonrpc": "2.0",
    "method": "user.login",
    "params": {
        "user": "Admin",
        "password": "zabbix"
    },
    "id": 1,
    "auth": null
}' http://192.168.124.130/zabbix/api_jsonrpc.php)
echo $auth | awk -F "":"" '{print $3}' | awk -F "," '{print $1}'
}
#!打开即调用模板
auth=$(get_auth_id)
echo "$auth"

#!host---模板名字
#!groups--把模板链接到已有模板的groupid号
function create_template(){
template=$(curl -s -X POST -H 'Content-Type: application/json-rpc' -d '{
    "jsonrpc": "2.0",
    "method": "template.create",
    "params": {
        "host": "'''$1'''", 
	"groups": {
		"groupid": 2
	}
    },
    "auth": '''$2''',
    "id": 2
}' http://192.168.124.130/zabbix/api_jsonrpc.php)
export tempid=$(echo $template | cut -d : -f 4,8 | awk -F "," '{print $1}' | cut -d \" -f 2,2)
}
#!打开即调用模板
#create_template new-template "$auth"

#!name--创建应用集名字
#!hostid--应用集中添加到模板的id号
function create_application(){
app=$(curl -s -X POST -H 'Content-Type:application/json' -d '{
    "jsonrpc": "2.0",
    "method": "application.create",
    "params": {
        "name": "'''$1'''",    
        "hostid": "'''$2'''"
    },
    "auth": '''$3''',
    "id": 1
}' http://192.168.124.130/zabbix/api_jsonrpc.php)
export appid=$(echo $app | cut -d : -f 4,8 | awk -F "," '{print $1}' | cut -d \" -f 2,2)
}
#!打开即调用模板
#create_application new-application "$tempid" "$auth" 



#!创建监控项
#!name--监控项名字
#!key_--监控需要用到的key
#!hostid-监控的id
#!application--添加到应用集
function create_mon(){
mon=$(curl -s -X POST -H 'Content-Type:application/json' -d '{
    "jsonrpc": "2.0",
    "method": "item.create",
    "params": {
        "name": "'''$1'''",
        "key_": "'''$2'''",
	"hostid": "'''$5'''",
        "type": 0,
        "value_type": 1,
        "interfaceid": "30084",
        "applications": [
            "'''$3'''"
        ],
        "delay": "10s"
    },
    "auth": '''$4''',
    "id": 1
}' http://192.168.124.130/zabbix/api_jsonrpc.php)	
}
#!打开即调用模板
#create_mon new-mon mon_httpd "$appid" "$auth" "$tempid"

