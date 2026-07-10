#!/usr/bin/env python3

import os
import shutil
import subprocess
import sys

# ── Colours ──────────────────────────────────────────────────────────────────
GREEN  = "\033[92m"
YELLOW = "\033[93m"
RED    = "\033[91m"
CYAN   = "\033[96m"
RESET  = "\033[0m"

def info(msg):    print(f"{CYAN}[•]{RESET} {msg}")
def success(msg): print(f"{GREEN}[✓]{RESET} {msg}")
def warn(msg):    print(f"{YELLOW}[!]{RESET} {msg}")
def error(msg):   print(f"{RED}[✗]{RESET} {msg}")

# ── Helpers ───────────────────────────────────────────────────────────────────
def check_command(cmd):
    """Returns True if the command is available on PATH."""
    return shutil.which(cmd) is not None

def run(cmd, **kwargs):
    """Run a shell command, inheriting stdout/stderr."""
    return subprocess.run(cmd, shell=True, **kwargs)

def generate_app_key():
    """Generate a random 32-byte base64 APP_KEY."""
    import base64
    return base64.urlsafe_b64encode(os.urandom(32)).decode()

# ── Checks ────────────────────────────────────────────────────────────────────
def check_prerequisites():
    ok = True
    for tool in ["docker"]:
        if check_command(tool):
            success(f"{tool} found")
        else:
            error(f"{tool} not found – please install it first: https://docs.docker.com/get-docker/")
            ok = False

    # Docker Compose v2 is a sub-command of docker
    result = run("docker compose version", capture_output=True)
    if result.returncode == 0:
        success("docker compose found")
    else:
        error("docker compose not found – make sure Docker Desktop or the Compose plugin is installed")
        ok = False

    return ok

# ── .env setup ────────────────────────────────────────────────────────────────
REQUIRED_KEYS = ["APP_KEY", "DB_PASSWORD"]

def read_env(path):
    """Parse a .env file into a dict (ignores comments/blank lines)."""
    values = {}
    with open(path) as f:
        for line in f:
            stripped = line.strip()
            if not stripped or stripped.startswith("#") or "=" not in stripped:
                continue
            key, _, value = stripped.partition("=")
            values[key.strip()] = value.strip()
    return values

def setup_env():
    env_file     = ".env"
    env_example  = ".env.example"

    if os.path.exists(env_file):
        existing = read_env(env_file)
        missing = [k for k in REQUIRED_KEYS if not existing.get(k)]

        if not missing:
            success(".env already exists, skipping setup")
            return True

        warn(f".env exists but is missing/empty: {', '.join(missing)} – filling in the gaps")

        with open(env_file) as f:
            lines = f.readlines()

        fill_values = {}
        if "APP_KEY" in missing:
            fill_values["APP_KEY"] = generate_app_key()
            info("APP_KEY generated automatically")
        if "DB_PASSWORD" in missing:
            db_password = input(f"{CYAN}[?]{RESET} Enter a PostgreSQL password for the DB: ").strip()
            if not db_password:
                error("DB_PASSWORD cannot be empty")
                return False
            fill_values["DB_PASSWORD"] = db_password

        found_keys = set()
        with open(env_file, "w") as f:
            for line in lines:
                stripped = line.strip()
                if stripped.startswith("#") or not stripped or "=" not in stripped:
                    f.write(line)
                    continue
                key = stripped.split("=")[0].strip()
                if key in fill_values:
                    f.write(f"{key}={fill_values[key]}\n")
                    found_keys.add(key)
                else:
                    f.write(line)
            # Anything still missing (key wasn't even present as a line) gets appended
            for key, value in fill_values.items():
                if key not in found_keys:
                    f.write(f"{key}={value}\n")

        success(".env updated with the missing values")
        return True

    if not os.path.exists(env_example):
        error(".env.example not found – make sure you are running this script from the Echoo/ folder")
        return False

    warn(".env file not found – let's create one")
    print()

    # Read the example as a template
    with open(env_example) as f:
        lines = f.readlines()

    values = {}

    # Auto-generate APP_KEY
    app_key = generate_app_key()
    values["APP_KEY"] = app_key
    info(f"APP_KEY generated automatically")

    # Ask for DB password
    db_password = input(f"{CYAN}[?]{RESET} Enter a PostgreSQL password for the DB: ").strip()
    if not db_password:
        error("DB_PASSWORD cannot be empty")
        return False
    values["DB_PASSWORD"] = db_password

    # Optional overrides
    db_user = input(f"{CYAN}[?]{RESET} DB user [postgres]: ").strip() or "postgres"
    db_name = input(f"{CYAN}[?]{RESET} DB name [ECHOO]: ").strip() or "ECHOO"
    values["DB_USER"]     = db_user
    values["DB_DATABASE"] = db_name

    # Write the .env file
    with open(env_file, "w") as f:
        for line in lines:
            stripped = line.strip()
            if stripped.startswith("#") or not stripped:
                f.write(line)
                continue
            key = stripped.split("=")[0].strip()
            if key in values:
                f.write(f"{key}={values[key]}\n")
            else:
                f.write(line)

    success(".env created successfully")
    return True

# ── Docker ────────────────────────────────────────────────────────────────────
def start_docker(detach=True):
    flag = "-d" if detach else ""
    info("Building and starting containers (this may take a while on first run)...")
    print()
    result = run(f"docker compose up --build {flag}")
    return result.returncode == 0

# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    print()
    print(f"{CYAN}{'─' * 50}")
    print(f"  Echoo – Docker startup script")
    print(f"{'─' * 50}{RESET}")
    print()

    # 0. Make sure we're in the right folder
    if not os.path.exists("docker-compose.yml"):
        error("docker-compose.yml not found.")
        error("Run this script from the Echoo/ folder:\n  cd Echoo && python3 start.py")
        sys.exit(1)

    # 1. Prerequisites
    info("Checking prerequisites...")
    if not check_prerequisites():
        sys.exit(1)
    print()

    # 2. .env
    info("Checking environment configuration...")
    if not setup_env():
        sys.exit(1)
    print()

    # 3. Start
    detach = "--no-detach" not in sys.argv
    if not start_docker(detach=detach):
        error("Docker Compose failed – check the output above for details")
        sys.exit(1)

    print()
    success("Echoo is running!")
    print()
    print(f"  {GREEN}Frontend:{RESET}  http://localhost")
    print(f"  {GREEN}Backend:{RESET}   http://localhost:3333")
    print(f"  {GREEN}Database:{RESET}  localhost:5432")
    print()
    if detach:
        print(f"  {YELLOW}Logs:{RESET}      docker compose logs -f")
        print(f"  {YELLOW}Stop:{RESET}      docker compose down")
    print()

if __name__ == "__main__":
    main()