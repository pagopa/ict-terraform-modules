
output "key_vault_cert_store_location" {
  description = "Location on VM filesystem where the certs synced from KV will be stored"
  value       = local.kv_ext.cert_store_location
}
