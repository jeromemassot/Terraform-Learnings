# Chapter 07 Summary: Serverless Architectures and Integration

Chapter 07 shifts the focus from traditional VM-based infrastructure to **Modern Serverless Architectures** using Google Cloud Run. It demonstrates how to build a scalable, multi-layered application that integrates serverless compute with private networking, stateful services, and global traffic management.

## 🚀 Key Learnings

### 1. Cloud Run for Serverless Compute
- **Managed Containers**: Deploying stateless containers without managing servers.
- **Microservices**: Orchestrating multiple services (e.g., `hello` and `redis` services) that interact with each other.
- **Ingress Control**: Using `run.googleapis.com/ingress = "internal-and-cloud-load-balancing"` to restrict access, ensuring traffic only comes from the Load Balancer or internal sources.

### 2. Private Networking for Serverless
- **Serverless VPC Access**: Use of `google_vpc_access_connector` to bridge the gap between serverless platforms (Cloud Run) and private VPC networks.
- **Egress Routing**: Configuring Cloud Run with `run.googleapis.com/vpc-access-egress = "private-ranges-only"` to route traffic to internal IPs (like Redis) while maintaining public internet access for other requests.

### 3. Stateful Serverless with Memorystore
- **Redis Integration**: Provisioning a `google_redis_instance` (Memorystore) within the VPC.
- **Private Connectivity**: Accessing Redis over its private IP from Cloud Run via the VPC connector.
- **Secret Manager**: Securely storing the Redis IP in Secret Manager and injecting it into Cloud Run as an environment variable (`REDIS_IP`).

### 4. Global HTTP Load Balancing (Frontdoor)
- **Serverless NEGs**: Using `google_compute_region_network_endpoint_group` of type `SERVERLESS` to connect Cloud Run services to a Global Load Balancer.
- **Hybrid Backends**: A single URL Map routing traffic to different backends:
    - `/api/*` → Cloud Run (Compute).
    - `Default` → GCS Bucket (Static Content).
- **Global Reach**: Using Forwarding Rules and Target HTTP Proxies to provide a single entry point for the entire stack.

---

## 💡 Insights & Best Practices

### The "Bridge" Pattern (VPC Connector)
One of the most critical learnings is the **Serverless VPC Access Connector**. In GCP, serverless services essentially live "outside" your VPC. To let them talk to private resources like Memorystore or Cloud SQL via private IPs, you **must** create a connector. It acts as a bridge, consuming a `/28` subnet range to route traffic.

### Dynamic vs. Static Split
The integration of **Backend Buckets** and **Serverless NEGs** in one Load Balancer is a powerful architectural pattern. It allows you to:
1. Serve static assets (JS, CSS, Images) directly from GCS (cheap and fast).
2. Serve dynamic requests through Cloud Run.
3. Keep the entire frontend under a single domain name, simplifying CORS and SSL management.

### Security-First Configuration
The chapter emphasizes **Secret Manager** for metadata injection. Instead of hardcoding the Redis IP or passing it as a plain variable, storing it in Secret Manager ensures that sensitive infrastructure details are versioned and access-controlled. 

### Why store the Redis IP in Secret Manager?
1. **Security & Obfuscation**: Prevents sensitive internal infrastructure details (like private IPs) from being hardcoded in container images or visible in plaintext in deployment dashboards.
2. **Dynamic Discovery**: The application (Cloud Run) doesn't need to know the IP at build time. It simply requests the `latest` version of the secret at runtime via the environment variable reference.
3. **Automated Lifecycle**: If the Redis instance is recreated (potentially changing its IP), Terraform automatically updates the Secret Manager value. The application then picks up the new IP on its next container start without requiring code changes or a manual update to environment variables.

### Ingress Hardening
By setting Cloud Run ingress to `internal-and-cloud-load-balancing`, you prevent users from bypassing your Load Balancer and hitting the `.run.app` URL directly. This ensures that features like WAF (Cloud Armor) or CDN (Cloud CDN) enabled on the LB cannot be bypassed.

---
*Summary generated for learning progression in Terraform for Google Cloud Essential Guide.*
