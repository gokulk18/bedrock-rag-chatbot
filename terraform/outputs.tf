output "api_url" { value = module.api.api_endpoint }
output "knowledge_base_id" { value = module.bedrock.knowledge_base_id }
output "documents_bucket" { value = module.documents.bucket_name }
output "frontend_url" { value = module.frontend.distribution_domain_name }
