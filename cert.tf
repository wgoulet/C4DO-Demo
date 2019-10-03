variable "common_name" {
	type = string
}

variable "dns_sans" {
	type = list(string)
}

variable "passphrase" {
	type = string
}

variable "apikey" {
	type = string
}

variable "zone" {
	type = string
}

provider "venafi" {
	api_key = "${var.apikey}"
	zone = "${var.zone}"
}

resource "venafi_certificate" "webserver" {
    common_name = "${var.common_name}"
    algorithm = "RSA"
    rsa_bits = "2048"
    san_dns = "${var.dns_sans}"
    key_password = "${var.passphrase}"
}


resource "local_file" "privatekey" {
    content = "${venafi_certificate.webserver.private_key_pem}"
    filename = "${path.module}/privkey.pem"
}

resource "local_file" "chain" {
    content = "${venafi_certificate.webserver.chain}${venafi_certificate.webserver.certificate}"
    filename = "${path.module}/certs.pem"
}

output "cert_certificate" {
    value = "${venafi_certificate.webserver.certificate}"
}

output "cert_chain" {
    value = "${venafi_certificate.webserver.chain}"
}

output "cert_private_key" {
    value = "${venafi_certificate.webserver.private_key_pem}"
    sensitive   = false
}

resource "null_resource" "create-p12" {
    provisioner "local-exec" {
        command = "openssl pkcs12 -export -in '${local_file.chain.filename}' -inkey '${local_file.privatekey.filename}' -passin pass:\"${var.passphrase}\" -password pass:\"${var.passphrase}\" -out ${path.module}/tcert.p12"
    }
}

resource "null_resource" "create-b64p12" {
    depends_on = ["null_resource.create-p12"]
    provisioner "local-exec" {
	command = "base64 ${path.module}/tcert.p12 > ${path.module}/tcertp12.b64"
    }

}

#resource "local_file" "b64p12"{
#    depends_on = ["null_resource.create-p12"]
#    content = filebase64("${path.module}/tcert.p12")
#    filename = "${path.module}/tcertp12.b64"
#}
