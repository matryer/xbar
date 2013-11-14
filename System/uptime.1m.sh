#!/bin/bash
uptime | sed -n 1'p' | tr ',' '\n'