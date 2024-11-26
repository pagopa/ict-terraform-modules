
# the self signed certificate
resource "azurerm_key_vault_certificate" "this" {
  name         = var.name
  key_vault_id = var.key_vault_id

  # all of this is opinionated except for CN: this is just a
  # quick-and-dirty self-signed, take it as it is!

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject            = "CN=${var.subject_cn}"
      validity_in_months = 12
    }
  }

  tags = var.tags
}
