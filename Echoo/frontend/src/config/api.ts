// Centralized API configuration
//
// This file is bundled into the static JS at BUILD time (Vite), so it can't
// read a real environment variable per-deployment at runtime - the value
// baked in here is final until the frontend image is rebuilt. Because of
// that, the backend port is derived from the frontend's own port, using a
// fixed mapping that matches cloud-lab's documented port matrix:
//
//   Docker Compose:                          frontend 8101 -> backend 3334
//   Kubernetes (local k3d) / Terraform (local + GCP): frontend 8111 -> backend 3344
//
// If VITE_API_URL is set at build time, it takes full priority over the
// port mapping - useful for a custom domain or reverse proxy setup where
// the backend isn't simply "same host, different port".

const FRONTEND_TO_BACKEND_PORT: Record<string, number> = {
  '8101': 3334, // Docker Compose
  '8111': 3344, // Kubernetes (local k3d), local Terraform, and Terraform GCP
}

const currentHostname = window.location.hostname
const currentPort = window.location.port

let API_URL: string

if (import.meta.env.VITE_API_URL) {
  API_URL = import.meta.env.VITE_API_URL.replace(/\/$/, '')
  console.log('[API CONFIG] Using VITE_API_URL override:', API_URL)
} else {
  const backendPort = FRONTEND_TO_BACKEND_PORT[currentPort]
  if (!backendPort) {
    console.warn(
      `[API CONFIG] Frontend port "${currentPort}" is not in the known port mapping - ` +
      'falling back to 3333, which is probably wrong. ' +
      'Add this port to FRONTEND_TO_BACKEND_PORT in src/config/api.ts.'
    )
  }
  API_URL = `http://${currentHostname}:${backendPort ?? 3333}`
}

console.log('[API CONFIG] Frontend URL:', window.location.href)
console.log('[API CONFIG] Final API URL:', API_URL)

export default API_URL
export { API_URL }
