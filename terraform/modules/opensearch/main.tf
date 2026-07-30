# ==============================================================================
# Reusable OpenSearch Serverless Vector Search Module
# ==============================================================================
# Provisions an Amazon OpenSearch Serverless collection configured for
# high-dimensional vector search supporting Amazon Bedrock Knowledge Bases.
#
# Resources Created:
# 1. Encryption Security Policy (AWS-owned key, encryption at rest)
# 2. Network Security Policy (Public access to collection endpoints)
# 3. Vector Search Collection (VECTORSEARCH type)
# 4. Data Access Policy (Data-plane permissions for IAM roles)
# ==============================================================================

# ------------------------------------------------------------------------------
# Encryption Security Policy
# ------------------------------------------------------------------------------
# Defines data-at-rest encryption settings for the vector collection.
resource "aws_opensearchserverless_security_policy" "encryption" {
  name        = "${var.collection_name}-enc"
  type        = "encryption"
  description = "Encryption security policy for ${var.collection_name} collection."

  policy = jsonencode({
    Rules = [
      {
        ResourceType = "collection"
        Resource     = ["collection/${var.collection_name}"]
      }
    ]
    AWSOwnedKey = true
  })
}

# ------------------------------------------------------------------------------
# Network Security Policy
# ------------------------------------------------------------------------------
# Controls network reachability for collection and dashboard endpoints.
resource "aws_opensearchserverless_security_policy" "network" {
  name        = "${var.collection_name}-net"
  type        = "network"
  description = "Network security policy for ${var.collection_name} collection."

  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "collection"
          Resource     = ["collection/${var.collection_name}"]
        },
        {
          ResourceType = "dashboard"
          Resource     = ["collection/${var.collection_name}"]
        }
      ]
      AllowFromPublic = true
    }
  ])
}

# ------------------------------------------------------------------------------
# OpenSearch Serverless Vector Collection
# ------------------------------------------------------------------------------
# Primary serverless vector search container.
resource "aws_opensearchserverless_collection" "this" {
  name        = var.collection_name
  type        = "VECTORSEARCH"
  description = "OpenSearch Serverless vector search collection for Amazon Bedrock RAG Chatbot."

  tags = var.tags

  depends_on = [
    aws_opensearchserverless_security_policy.encryption,
    aws_opensearchserverless_security_policy.network
  ]
}

# ------------------------------------------------------------------------------
# Data Access Policy
# ------------------------------------------------------------------------------
# Grants least-privilege data access to specified IAM principal roles.
resource "aws_opensearchserverless_access_policy" "this" {
  name        = "${var.collection_name}-acc"
  type        = "data"
  description = "Data access policy for ${var.collection_name} collection."

  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index"
          Resource     = ["index/${var.collection_name}/*"]
          Permission = [
            "aoss:ReadDocument",
            "aoss:WriteDocument",
            "aoss:CreateIndex",
            "aoss:DeleteIndex",
            "aoss:UpdateIndex",
            "aoss:DescribeIndex"
          ]
        },
        {
          ResourceType = "collection"
          Resource     = ["collection/${var.collection_name}"]
          Permission = [
            "aoss:CreateCollectionItems",
            "aoss:DeleteCollectionItems",
            "aoss:UpdateCollectionItems",
            "aoss:DescribeCollectionItems"
          ]
        }
      ]
      Principal = var.iam_role_arns
    }
  ])
}
