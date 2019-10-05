variable "client_secret" {
  type = string
}

variable "certpass" {
  type = string
}

variable "sub_id" {
  type = string
}

variable  "client_id" {
  type = string
}

variable  "tenant_id" {
  type = string
}

variable  "backend_addr_pool" {
  type = list(string)
}

variable  "frontend_ip_id" {
  type = string
}

variable  "gateway_subnet_ip_id" {
  type = string
}

provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=1.34.0"

  subscription_id = "${var.sub_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}


resource "azurerm_application_gateway" "demoapps" {
    disabled_ssl_protocols = []
    enable_http2           = false
    location               = "eastus"
    name                   = "demoappslb"
    resource_group_name    = "vcloud4app"
    tags                   = {}
    zones                  = []

    sku {
        name = "Standard_v2"
        tier = "Standard_v2"
    }

    autoscale_configuration {
        max_capacity = 10
        min_capacity = 2
    }

    backend_address_pool {
        fqdns           = "${var.backend_addr_pool}"
        name            = "demoappsbackend"
    }

    backend_http_settings {
        cookie_based_affinity               = "Disabled"
        name                                = "demoapplbbe"
        pick_host_name_from_backend_address = true
        port                                = 443
        protocol                            = "Https"
        request_timeout                     = 20
    }

    trusted_root_certificate {
       	  name = "beroot"
          data = file("${path.module}/cacerts.pem")
    }

    frontend_ip_configuration {
        name                          = "appGwPublicFrontendIp"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = "${var.frontend_ip_id}"
    }

    frontend_port {
        name = "port_443"
        port = 443
    }

    gateway_ip_configuration {
        name      = "appGatewayIpConfig"
        subnet_id = "${var.gateway_subnet_ip_id}"
    }

    http_listener {
        frontend_ip_configuration_name = "appGwPublicFrontendIp"
        frontend_port_name             = "port_443"
        name                           = "demoapplblistener"
        protocol                       = "Https"
        ssl_certificate_name           = "ssl_pubcert"
        require_sni                    = false
    }

    ssl_certificate {
        name = "ssl_pubcert"
        password = "${var.certpass}"
        data = file("${path.module}/tcertp12.b64")
    }

    request_routing_rule {
        backend_address_pool_name  = "demoappsbackend"
        backend_http_settings_name = "demoapplbbe"
        http_listener_name         = "demoapplblistener"
        name                       = "routehttptohttps"
        rule_type                  = "Basic"
    }

}

resource "null_resource" "az_login" {
    depends_on = ["azurerm_application_gateway.demoapps"]
    triggers = {
        timestamp = timestamp()
    }
    provisioner "local-exec" {
        command = "az login --service-principal -u ${var.client_id} -p ${var.client_secret} --tenant ${var.tenant_id}"
    }
}

resource "null_resource" "bind_root_http_settings" {
    depends_on = ["null_resource.az_login"]
    triggers = {
        timestamp = timestamp()
    }
    provisioner "local-exec" {
        command = "az network application-gateway http-settings update --gateway-name demoappslb --resource-group vcloud4app --root-cert beroot --name demoapplbbe"
    }
}
