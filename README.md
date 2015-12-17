# Price Tracker

Track your favorit products' price.

Tested platform: [Mint](http://linuxmint.com/), [Mageia](http://www.mageia.org/), [Ubuntu](http://www.ubuntu.com/), [Fedora](https://getfedora.org/), [Debian](http://www.debian.org/), [OpenSUSE](http://www.opensuse.org/), [CentOS](http://www.centos.org/), [Arch](http://www.archlinux.org/)

## Getting Started

1.  Install

    *   [sudo](https://www.sudo.ws/) and add yourself to *wheel* or *sudo* group. 

    *   [postgres](https://wiki.postgresql.org/wiki/Detailed_installation_guides) and run it.

    *   [nvm](https://github.com/creationix/nvm#install-script).

2.  Run

    ```bash
    $ ./install.sh
    ```

    Click this [link](http://127.0.0.1:4000/).

### Command Line

*   Add Product

    ```bash
    $ ./product add B01639694M 'Samsung 950 Pro 512GB'
    ```

*   Remove Product

    ```bash
    $ ./product remove B01639694M
    ```
