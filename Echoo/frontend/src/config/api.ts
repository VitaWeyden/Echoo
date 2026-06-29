// Centralized API configuration - FULLY DYNAMIC, NO HARDCODED IPs!

const BACKEND_PORT = window.location.port === '8101' ? 3334 : 3333
const currentHostname = window.location.hostname
const currentPort = window.location.port

console.log('[API CONFIG] Window location:', window.location.href)
console.log('[API CONFIG] Frontend hostname:', currentHostname)
console.log('[API CONFIG] Frontend port:', currentPort)

// Smart API URL detection
let API_URL: string

if (currentHostname === 'localhost' || currentHostname === '127.0.0.1') {
  API_URL = `http://localhost:${BACKEND_PORT}`
} else {
  API_URL = `http://${currentHostname}:${BACKEND_PORT}`
}

// Environment variable override - ONLY IF LOCALHOST!
if (import.meta.env.VITE_API_URL) {
  const envUrl = import.meta.env.VITE_API_URL.replace(/\/$/, '')

  console.log('[API CONFIG] Found VITE_API_URL:', envUrl)

  if (currentHostname === 'localhost' || currentHostname === '127.0.0.1') {
    API_URL = `http://localhost:${BACKEND_PORT}`
    console.log('[API CONFIG] Localhost detected, forcing localhost backend')
  } else {
    console.log('[API CONFIG] Network IP detected, ignoring env variable')
    API_URL = `http://${currentHostname}:${BACKEND_PORT}`
  }
}

console.log('[API CONFIG] ✅ Final API URL:', API_URL)

export default API_URL
export { API_URL }
