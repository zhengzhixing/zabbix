#!/usr/bin/python
# -*- coding: utf-8 -*-
# Author: aiker@gdedu.ml
# My blog http://m51cto.51cto.blog.com 
import requests
import json
import sys
import os
 
headers = {'Content-Type': 'application/json;charset=utf-8'}
api_url = "https://oapi.dingtalk.com/robot/send?access_token=811c10f0b6871b07207afce3d862374da776c554e06193b843cd4a768abb94d4"
 
def msg(text):
    json_text= {
     "msgtype": "text",
        "text": {
            "content": text
        }
    }
    print requests.post(api_url,json.dumps(json_text),headers=headers).content
     
if __name__ == '__main__':
    text = sys.argv[1]
    msg(text)
