#!/bin/bash
container_name=$1

# Read log info from the generated file
source ${path.module}/log_info.txt

echo "${timestamp} | ${ssh_user}@${ssh_host} > destroy ${container_name}" >> traces.log
