#!/usr/bin/env coffee
#

{ Fail2Ban, Jail } = require './src/index'

f = new Fail2Ban

do ->
  console.log await f.bans
  jail = new Jail 'sshd'
  # console.log await jail.bans
  console.log 'PING  ', JSON.stringify (await f.ping), null, 2
  console.log 'STATUS', JSON.stringify (await f.status), null, 2
  console.log 'DBFILE', await f.dbfile
  console.log 'REGEX', await jail.regex
  try
    console.log 'ADD-REGEX', JSON.stringify (await jail.addRegex 'Test Regex'), null, 2
  catch err
    console.log err
  try
    console.log 'DEL-REGEX', JSON.stringify (await jail.delRegex 'Test Regex'), null, 2
  catch err
    console.log err
  jail.unban '158.152.1.666'
  .then (response) ->
    console.log 'BAN  ', JSON.stringify response, null, 2
  .catch (err) ->
    console.log err
  console.log 'JAIL STATUS', JSON.stringify (await jail.status), null, 2
  jail.findTime = 600
  console.log 'FINDTIME', await jail.findTime
  jail.retries = 3
  console.log 'RETRY   ', await jail.retries
  jail.useDNS = 'no'
  console.log 'DNS     ', await jail.useDNS
  console.log 'STATUS', JSON.stringify (await f.status), null, 2
