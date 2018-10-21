#!/usr/bin/env coffee
#

Fail2Ban = require './src/fail2ban'

f = new Fail2Ban

f.status()
.then (status) =>
  console.log "STATUS", typeof status, status
  console.log JSON.stringify status, null, 2
.catch (err) =>
  console.error err
