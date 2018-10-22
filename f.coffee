#!/usr/bin/env coffee
#

Fail2Ban = require './src/fail2ban'

f = new Fail2Ban

Promise.resolve()
.then =>
  f.ping()
.then (ping) =>
  console.log JSON.stringify ping, null, 2
  f.status()
.then (status) =>
  console.log JSON.stringify status, null, 2
  f.status 'sshd'
.then (status) =>
  console.log JSON.stringify status, null, 2
  f.dbFile()
.then (status) =>
  console.log JSON.stringify status, null, 2
###
  f.reload()
.then (status) =>
  console.log JSON.stringify status, null, 2
###
.catch (err) =>
  console.error "CAUGHT: #{err.message}"
