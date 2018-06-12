#!/bin/bash

##获取zabbix-api认证id
function get_auth_id {
auth=$(curl -s -X POST -H 'Content-Type: application/json-rpc' -d '{
    "jsonrpc": "2.0",
    "method": "user.login",
    "params": {
        "user": "zzx",
        "password": "Rq@2018zzx"
    },
    "id": 1,
    "auth": null
}' http://120.79.64.173/zabbix/api_jsonrpc.php)
echo $auth | awk -F ":" '{print $3}' | awk -F "," '{print $1}'
}
auth=$(get_auth_id)

#获取主机id
function get_host() {
host=$(curl -s -X POST -H 'Content-Type: application/json-rpc' -d '{
    "jsonrpc": "2.0",
    "method": "host.get",
    "params": {
        "output": "extend",
        "filter": {
            "host": [
                "test"
            ]
        }
    },
    "auth": '''$1''',
    "id": 1
}' http://120.79.64.173/zabbix/api_jsonrpc.php)
echo $host | jq .result[0].hostid
}
host=$(get_host "$auth")

#获取主机接口
function get_host_interfaces() {
inter=$(curl -s -X POST -H 'Content-Type: application/json-rpc' -d '{
    "jsonrpc": "2.0",
    "method": "hostinterface.get",
    "params": {
        "output": "extend",
        "hostids": '''$1'''
    },
    "auth": '''$2''',
    "id": 1
}' http://120.79.64.173/zabbix/api_jsonrpc.php)
echo $inter | jq .result[0].interfaceid
}
inter=$(get_host_interfaces "$host" "$auth")

#创建自动发现
function create_lld() {
discover=$(curl -s -X POST -H 'Content-Type: application/json-rpc' -d '{
    "jsonrpc": "2.0",
    "method": "discoveryrule.create",
    "params": {
        "name": '''\"$1\"''',
        "key_": '''\"$2\"''',
        "hostid": '''$3''',
        "type": "0",
        "interfaceid": '''$5''',
        "delay": "30s"
    },
    "auth": '''$4''',
    "id": 1
}' http://120.79.64.173/zabbix/api_jsonrpc.php)
#echo $discover | jq .
}
#create_lld discover_port port "$host" "$auth" "$inter"

#获取自动发现id
function get_ruleid() {
ruleid=$(curl -s -X POST -H 'Content-Type: application/json-rpc' -d '{
    "jsonrpc": "2.0",
    "method": "discoveryrule.get",
    "params": {
        "output": "extend",
        "hostids": '''$1'''
    },
    "auth": '''$2''',
    "id": 1
}' http://120.79.64.173/zabbix/api_jsonrpc.php)
echo $ruleid | jq .result[3].itemid 
}
rule=$(get_ruleid "$host" "$auth")

#创建监控原型
function create_memitem() {
mem=$(curl -s -X POST -H 'Content-Type: application/json-rpc' -d '{
    "jsonrpc": "2.0",
    "method": "itemprototype.create",
    "params": {
        "name": '''\"$1\"''',
        "key_": '''\"$2\"''',
        "hostid": '''$3''',
        "ruleid": '''$4''',
        "type": 0,
        "value_type": 3,
        "delay": "60s",
        "interfaceid": '''$6''',
        "preprocessing": [
            {
                "type": "21",
                "params": ""
            }
        ]
    },
    "auth": '''$5''',
    "id": 1
}' http://120.79.64.173/zabbix/api_jsonrpc.php)
}
create_memitem '{#SERVICE}-mem' 'test-json[{#PORT},mem]' "$host" "$rule" "$auth" "$inter"




