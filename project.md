${{ content_synopsis }} This image will run BIND9 DNS server precompiled for large installations and maximum performance. It also offers three operating modes: Master, Slave and Resolver set via **command: ["mode"]**.

# Master
If run as master, set the IPs of the slaves via *BIND_SLAVES*. Bind will operate with catalog zones for all slaves. You can add new zones via the *addzone* script that requires the zone name and the IP of at least one NS (slave). You can then use nsupdate to update the master with new records and all changes are populates to all slaves automatically. Add a new zone like this:

```shell
docker exec master addzone contoso.com 10.255.53.52
```

It will automatically create a default zone and populate it as well as add a random key for managing the zone via nsupdate or via the dynamically created root key at startup (check /bind/etc/keys.conf for generated keys). Checkout **compose.authoritative.yaml** for an example.

# Slave
If run as slave, make sure you set the *BIND_MASTERS* IPs so they will pickup all changes automatically. The slave enables recursion, so make sure you have a resolver present to resolve queries not handles by the slave. The slave will respond to all IPs on RFC1918 by default. You can setup your own config as well. You can run as many slaves as you like.

# Resolver
If run as a resolver, it will cache all results and use the root zone NS to create its own cache database for all records requested. Make sure the resolver has internet access. The resolver will accept all connections from any RFC1918 address. Checkout **compose.resolver.yaml** for an example.

${{ title_volumes }}
* **${{ json_root }}/etc** - Directory of named.conf
* **${{ json_root }}/var** - Directory of Directory of zone data

${{ content_compose }}

${{ content_defaults }}

${{ content_environment }}
| `BIND_SLAVES` | IPs of bind slaves if using authoritative master (add ;) | |
| `BIND_MASTERS` | IPs of bind master if using authoritative slave (add ;) | |

${{ content_source }}

${{ content_parent }}

${{ content_built }}

${{ content_tips }}