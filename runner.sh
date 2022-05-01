#!/bin/bash

pgloader postgres://django:Fatima123x.@localhost/d8454c8grlk05 $(heroku config:get DATABASE_URL -a rog2021)'?ssl=true&sslfactory=org.postgresql.ssl.NonValidatingFactory'
