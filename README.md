# Tailgate #

Tailgate serves up your mp3s so you can listen to them at work or on your phone.

### Installation

Make sure [Node.js is installed](http://nodejs.org/), then:

    npm install -g tailgate

### Enjoyment

1. <code>$ cd /music/directory</code>
2. <code>$ tailgate</code>
3. [ open the displayed url in your browser ]

<img src="http://rboxx.com/tailgate.png" />

### Etc...

Tailgate uses port 3000 by default, if you'd like another port:

    $ PORT=1337 tailgate

Tailgate uses Mozilla Persona for Authentication. Authorized user list will be stored in <code>~/.config/tailgate/config.json</code>. If it's the first time running Tailgate, the first user to login will automatically be added.

If Redis is available Tailgate can:

* store up/downvotes
* store user sessions