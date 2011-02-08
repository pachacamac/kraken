just a few notes for myself ...

every peer consists of the following components
  - a webserver which
x   - serves all shared files
    - provides a rest interface for the following operations
      - list all files with name, mtime, size and hash
        - (optional: since a certain time to save bandwith?)
x     - list all peers he knows
      - update peers
      - receive update notifications from peers
        - hash and size should be sufficient
        - answer should be weather or not the peer has the file already
x - a hashing daemon which
    - monitors a folder and maintains actual hashes of each file
  - a synchronization daemon which
    - maintains a list of peers
    - downloads missing files from peers (via open-uri? can it resume etc?)
    - notifies the rest service of other peers about new and modified files
    - (tries to discover new peers in a local network?)

1. build rest interface with sinatra, with json support only
2. build a hashing daemon. where to store hashes? file or files in a folder?
3. build a synchronization daemon
4. ???
5. profit!

- only allow downloads from peers
- count downloads per file?

look into
http://httparty.rubyforge.org/
http://www.rubyinside.com/nethttp-cheat-sheet-2940.html
