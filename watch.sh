#!/bin/bash
coffee -cw -o ./ ./src/coffee/server/*.coffee &
coffee -cw -o ./public/js ./src/coffee/client/*.coffee &
