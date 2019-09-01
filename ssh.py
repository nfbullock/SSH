#!/usr/bin/env python3

import configparser
import json
import os
import sys
import syslog

# Default vars
config = {
    "local": os.getcwd() + "/.bastion.cfg",
    "home": os.path.expanduser("~/.bastion.cfg"),
    "global": "/etc/bastion.cfg",
}
ssh_config = {
    "port": "22",
    "user": "root",
    "key": os.path.expanduser("~/.ssh/id_rsa"),
    "group": "unsorted",
    "hosts": os.path.expanduser("~/.ssh/bastion_hosts"),
    "favorites": "6",
}

textConfig = """
[MAIN]
# Default user, port, & private key
user = {0}
port = {1}
key = {2}

# Default group assignment and hosts file savepoint
group = {3}
# File to store hosts dictionary
hosts = {4}
# Number of favorites to display
favorites = {5}
"""

# Dynamic vars
host_list = []
group_list = []
favorite_list = []
host_details = []


def debug(debug_str):
    syslog.syslog(debug_str)


def error(debug_str):
    syslog.syslog("ERROR: " + debug_str)


def get_config():
    for file in config:
        if os.path.isfile(config[file]) is True:
            source_config(config[file])
            return

    w_lines = textConfig.format(
        ssh_config["port"],
        ssh_config["user"],
        ssh_config["key"],
        ssh_config["group"],
        ssh_config["hosts"],
        ssh_config["favorites"],
    )
    try:
        with open(config["home"], "w") as f:
            f.write(w_lines)
    except:
        e = sys.exc_info()[0]
        error(
            "getConfig: open config file: %s, err=%s"
            % (config["home"], str(e))
        )
    get_config()


def source_config(config_file):
    c = configparser.ConfigParser()
    try:
        c.read(config_file)
    except:
        e = sys.exc_info()[0]
        error(
            "getConfig: open config file: %s, err=%s" % (config_file, str(e))
        )
        return
    for item in c:
        if item is not None:
            if ("key", "hosts") in item:
                item = os.path.expanduser(item)
            ssh_config[item] = c["MAIN"][item]


def read_host_file(host_file):
    try:
        with open(host_file, "r") as f:
            lines = json.load(f)
            for line in lines:
                host_list.append(
                    SshHost(
                        line["name"],
                        line["address"],
                        line["port"],
                        line["user"],
                        line["key"],
                        line["group"],
                        line["useCount"],
                    )
                )
    except:
        e = sys.exc_info()[0]
        error(
            "readHostsFile: open config file: %s, err=%s" % (host_file, str(e))
        )
        return


def write_host_file(host_file):
    for host in host_list:
        host.recordHost()
    try:
        with open(host_file, "w") as f:
            json.dump(host_details, f)
    except:
        e = sys.exc_info()[0]
        error("write_host_file: open: %s, err=%s" % (host_file, str(e)))
        return
    for host in host_list:
        host.writeHostFile()


def create_host():
    name = host_prompt("connection name")
    address = host_prompt("address")
    user = host_prompt("user", ssh_config["user"])
    edit_mode = host_prompt("advanced", "N")
    if edit_mode.lower() == "y":
        port = host_prompt("port", ssh_config["port"])
        key = host_prompt("key", ssh_config["key"])
        group = host_prompt("group", ssh_config["group"])
        host_list.append(SshHost(name, address, user, port, key, group))
    else:
        host_list.append(SshHost(name, address, user))


def host_prompt(prompt_string, default=None):
    if default is None:
        return input("%s: " % prompt_string)
    else:
        return input("%s (%s): " % (prompt_string, default) or str(default))


"""
def createGroup

def editHost

def getFavorites():
    sortObjectsByCount
    createListEqualToFavoritesNum
    return(favorites)

#def doSSH
"""


def enum_hosts(num_list):
    num = 1
    for i in num_list:
        i["hostNum"] = num
        num += 1


def print_menu():
    enum_hosts(host_list)
    for host in host_list:
        print("[%s] - %s" % (host.hostNum, host.name))
    print("[0] - Create host")
    user_says = host_prompt("Input your choice", "0")
    print(user_says)


class SshHost:
    def __init__(
        self,
        name,
        address,
        user=ssh_config["user"],
        port=ssh_config["port"],
        key=ssh_config["key"],
        group=ssh_config["group"],
        use_count="0",
        host_num="",
    ):
        self.name = name
        self.address = address
        self.port = port
        self.user = user
        self.key = key
        self.group = group
        self.useCount = use_count
        self.hostNum = host_num

    def record_host(self):
        host_details.append(
            {
                "name": self.name,
                "address": self.address,
                "port": self.port,
                "user": self.user,
                "key": self.key,
                "group": self.group,
                "useCount": self.useCount,
            }
        )


if __name__ == "__main__":
    get_config()
    read_host_file()
    get_favorites()
    print_menu()
