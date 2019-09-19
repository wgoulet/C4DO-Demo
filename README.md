# Venafi Cloud for DevOps Demo Application

This demo application demonstrates how TLS certificates can be requested from Venafi Cloud for DevOps (https://www.venafi.com/platform/cloud/devops) using our Hashi Vault Secrets Engine plugin (https://github.com/Venafi/vault-pki-backend-venafi)

This demo builds a Docker container that serves a static webpage secured with a TLS certificate that is requested when the container is started.

These instructions were tested on Ubuntu 18.04.3 LTS with the following Docker version installed:

    Client:
    Version:           18.09.7
    API version:       1.39
    Go version:        go1.10.1
    Git commit:        2d0083d
    Built:             Fri Aug 16 14:20:06 2019
    OS/Arch:           linux/amd64
    Experimental:      false

    Server:
    Engine:
    Version:          18.09.7
    API version:      1.39 (minimum version 1.12)
    Go version:       go1.10.1
    Git commit:       2d0083d
    Built:            Wed Aug 14 19:41:23 2019
    OS/Arch:          linux/amd64
    Experimental:     false


To build the demo, clone the repo and execute the following command replacing <image name> with an appropriate name for your environment:

    sudo docker build -t <image name> .
    
Once the container is built, you can deploy it locally with the following command (this assumes that docker is running as root and is able to bind to port 443 on your system; do not use this configuration for production use):
    
    sudo docker run --name some-nginx -d -p 443:443 <container image name> <FQDN to embed in certifiate> <API key for Vault> <URL for the PKI backend that was configured with the Venafi Vault secrets engine for Hashi> <URL for retrieving certificates from the Vault instance>
    
You should now be able to connect to your system via https://localhost and see the demo web app after accepting the certificate exception. If you have deployed your container to a server that is publicly visible, you can create a DNS record that contains the FQDN you embedded in the certificate.
