# Home Assistant Add-on: Hetzner DNS updater

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

Use the value of a given entity that contains the current external
IP address (e.g. UPnP sensor) and set the IP for a given set of domains.

## Why is this "special"

When Home Assistant is connected to an LTE router, it may have a different 
external IP address than the router.

The external IP address is obtained via the UPnP integration, typically from a router that supports UPnP (e.g., FRITZ!Box 6842 LTE).

## Configuration

| Option        | Description                                                                                                                      | Default                           |
|---------------|----------------------------------------------------------------------------------------------------------------------------------|-----------------------------------|
| **API url**   | The base URL of the Hetzner DNS API                                                                                              | `https://dns.hetzner.com/api/v1/` |
| **API Token** | API token can be obtained from [DNS Console](https://dns.hetzner.com/settings/api-token)                                         | -                                 |
| **IP Entity** | A entity name that holds the current external IP address e.g. `sensor.fritz_box_6842_lte_externe_ip`                             | -                                 |
| **Domains**   | A list of all domains to update (e.g. `test.example.com`, `@.example.com`). In case the record was not found, it will be created | -                                 |

## Notes

* Updates only A records
* DNS will be checked every 60 seconds
* The record will only be updated if the external IP address does not match the one set in the DNS record
* sub-sub domains are **not supported** e.g. `sub-sub-domain.sub-domain.example.com`

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
