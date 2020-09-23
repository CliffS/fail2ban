# fail2ban client

## API interface for contolling Fail2Ban programmatically

This module is designed to give access to the [fail2ban][fail2ban]
interface used by `fail2ban-client`.  The module talks directly
to the socket that interacts with the server.

It is written in [Coffeescript 2][coffeescript] using native
Promises.  You do not need Coffeescript to use the library; it is pre-compiled to Javascript ES6.

Where possible, I have use properties like `fail.dbfile` rather than
functions such as `fail.getDBFile()` and `fail.setDBFile()`.

All functions and properties return Promises.  Do not forget to
`await` the result.  The result is always a valid Javascript
object or a string.

Errors should be caught with `try`/`catch` if using `await` or
by using a `.catch()` block if using `.then()`.

[fail2ban]: http://www.fail2ban.org
[coffeescript]: https://coffeescript.org/
[issues]: https://github.com/CliffS/fail2ban/issues

## Install

```bash
npm install fail2ban
```

## Example

```javascript
{ Fail2Ban, Jail } = require('fail2ban');

fail = new Fail2ban();
jail = new Jail('sshd');

(async function() {     // Can't use await at the top level
  console.log(await fail.ping());
  console.log(await jail.status);
});
```


## Methods and properties on the Fail2Ban class

### Constructor

```javascript
  fail = new Fail2Ban();
  fail = new Fail2Ban(socket);
```

### Properties

```javascript
await fail.status
```

Returns the number of jails and a list of them. For example:

```json
{
  "jails": 1,
  "list": [
    "sshd",
    "smtp-proxy"
  ]
}
```

### Functions

```javascript
await fail.ping();
```

Checks the server is alive.  It returns "pong".

```javascript
var response = await fail.message(<array of strings>);
```

This is the low level function that simply passes the message onto
the socket. It returns a Promise that resolves to the response or will
reject on error.

It is not intended that the consumer of this module call this method
directly.

## Methods and properties on the Jail class

### Constructor

```javascript
  jail = new Jail(<jail name>);
  jail = new Jail(<jail name>, config);
```

The jail name is mandatory.  All methods and properties will work
off this jail.  The second (optional) parameter is the config file or
socket as mentioned above.

### Properties

```javascript
await jail.status;
```

This shows the status for the single jail.  Example below:

```json
{
  "filter": {
    "currentlyFailed": 27,
    "totalFailed": 81,
    "fileList": [
      "/var/log/auth.log"
    ]
  },
  "actions": {
    "currentlyBanned": 2,
    "totalBanned": 2,
    "bannedIPList": [
      "200.46.254.107",
      "217.182.165.158"
    ]
  }
}
```
```javascript
await jail.regex
```

This returns the list of regexes for this jail.

```javascript
await jail.findTime;
jail.findTime = <num>;
```

This returns the "find time" in seconds.

```javascript
await jail.retries;
jail.retries = <num>;
```

This shows and sets the maximum retries befor the IP address is banned.

```javascript
await jail.useDNS;
jail.useDNS = "<mode>";
```

This shows and sets the useDNS flag to one of the following values:
`yes`, `warn`, `no`, `raw`.

### Methods

```javascript
await jail.addRegex(<new regex>);
```

Add an new regex to the jail.

```javascript
await jail.delRegex(<new regex>);
```

Remove an existing regex from the jail.

```javascript
await jail.ban(<ip address>);
```

This adds an IP address to the ban list for this jail.

```javascript
await jail.unban(<ip address>);
```

This removes an IP address to the ban list for this jail.


## Bugs

* This is a long way from finished.  there are many more functions to be
added.

* This has been tested on fail2ban version v0.10.2.  It may not work on earlier
clients.

## Helping out

If you have any time to add more functions to this module, feel free to
submit a pull request.

## Issues

Please report any bugs or make any suggestions at the [Github issues page][issues].
