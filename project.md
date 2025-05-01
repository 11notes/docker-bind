${{ content_synopsis }} This image will run BIND9 DNS server precompiled for large installations and maximum performance. It also offers three operating modes: Master, Slave and Resolver set via **command: ["mode"]**.

${{ content_uvp }} Good question! All the other images on the market that do exactly the same don’t do or offer these options:

${{ github:> [!IMPORTANT] }}
${{ github:> }}* This image runs as 1000:1000 by default, most other images run everything as root
${{ github:> }}* This image is created via a secure, pinned CI/CD process and immune to upstream attacks, most other images have upstream dependencies that can be exploited
${{ github:> }}* This image contains a proper health check that verifies the app is actually working, most other images have either no health check or only check if a port is open or ping works
${{ github:> }}* This repository has an auto update feature that will automatically build the latest version if released, most other providers don't do this
${{ github:> }}* This image is a lot smaller than most other images

If you value security, simplicity and the ability to interact with the maintainer and developer of an image. Using my images is a great start in that direction.

${{ content_comparison }}

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