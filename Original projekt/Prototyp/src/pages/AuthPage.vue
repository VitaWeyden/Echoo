<template>
  <!-- Hlavná stránka autentifikácie -->
  <q-page class="auth-wrapper">
    <!-- Ľavý pruh (vizuálny efekt) -->
    <div class="left-strip"></div>

    <!-- Karta s prihlasovacím / registračným formulárom -->
    <q-card class="auth-card">
      <h1 class="hero">{{ mode === 'login' ? 'WELCOME!' : 'REGISTRATION' }}</h1>
      <p class="lead">{{ mode === 'login' ? 'LOGIN HERE' : 'Create your account' }}</p>

      <!-- Formulár, zabraňuje default submit -->
      <q-form @submit.prevent="onSubmit">

        <!-- PRIHLÁSENIE -->
        <div v-if="mode === 'login'" class="form-column">
          <q-input dense filled v-model="login.email" placeholder="Full Username or Email" class="pill-input" />
          <q-input dense filled v-model="login.password" placeholder="Password" type="password" class="pill-input" />
          <div class="row actions-row">
            <q-btn unelevated class="action-btn" label="Login" @click.prevent="onLogin" />
          </div>
        </div>

        <!-- REGISTRÁCIA -->
        <div v-else class="form-grid">
          <q-input dense filled v-model="reg.firstName" placeholder="First name" class="pill-input" />
          <q-input dense filled v-model="reg.lastName" placeholder="Last name" class="pill-input" />
          <q-input dense filled v-model="reg.nickname" placeholder="Nick name" class="pill-input" />
          <q-input dense filled v-model="reg.email" placeholder="Email" class="pill-input" />
          <q-input dense filled v-model="reg.password" placeholder="Password" type="password" class="pill-input" />
          <q-input dense filled v-model="reg.password2" placeholder="Password again" type="password" class="pill-input" />
          <div class="row actions-row">
            <q-btn unelevated class="action-btn" label="Register now!" @click.prevent="onRegister" />
          </div>
        </div>
      </q-form>

      <!-- Odkaz pre prepínanie medzi login a register -->
      <div class="switch-link">
        <a @click.prevent="toggleMode">
          {{ mode === 'login' ? "DON'T HAVE AN ACCOUNT? CREATE YOUR ACCOUNT HERE" : 'ALREADY HAVE AN ACCOUNT? LOGIN HERE' }}
        </a>
      </div>
    </q-card>
  </q-page>
</template>



<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

// Aktuálny režim: login alebo register
const mode = ref<'login' | 'register'>('login');

// Formulárové modely
const login = ref({ email: '', password: '' });
const reg = ref({ firstName: '', lastName: '', nickname: '', email: '', password: '', password2: '' });

// Prepínanie režimu login/register
function toggleMode() {
  mode.value = mode.value === 'login' ? 'register' : 'login';
}

// VALIDÁCIA PRIHLÁSENIA
function validateLogin() {
  if (!login.value.email || !login.value.password) {
    alert('Please fill email and password');
    return false;
  }
  return true;
}

// VALIDÁCIA EMAILU
function validateEmail(email: string): boolean {
  // regex explanation:
  // ^             -> start
  // [^\s@]{3,}    -> at least 3 characters before @, no space or @
  // @             -> must have @
  // [^\s@]{3,}    -> at least 3 characters domain before dot
  // \.            -> must have a dot
  // [^\s@]{2,}    -> at least 2 characters TLD
  // $             -> end
  const emailRegex = /^[^\s@]{3,}@[^\s@]{3,}\.[^\s@]{2,}$/;
  return emailRegex.test(email);
}

// VALIDÁCIA REGISTRÁCIE
function validateRegister() {
  if (!reg.value.firstName || !reg.value.lastName || !reg.value.nickname || !reg.value.email || !reg.value.password) {
    alert('Please fill required fields'); // alert if required fields are missing
    return false;
  }

  if (!validateEmail(reg.value.email)) {
    alert('Invalid email format'); // alert if email format invalid
    return false;
  }

  if (reg.value.password !== reg.value.password2) {
    alert("Passwords don't match"); // alert if passwords mismatch
    return false;
  }
  return true;
}

// FUNKCIA PRIHLÁSENIE
async function onLogin() {
  if (!validateLogin()) return;
  console.log('LOGIN', login.value);
  alert('Pretend we logged in');
  await router.push('/chat/private1');
}

// FUNKCIA REGISTRÁCIA
function onRegister() {
  if (!validateRegister()) return;
  console.log('REGISTER', reg.value);
  alert('Pretend we registered');

  mode.value = 'login';
  alert('Registration successful! Please log in.');
}

// SUBMIT FORMULÁRA (volá login alebo register podľa režimu)
async function onSubmit() {
  if (mode.value === 'login') {
    await onLogin();
  } else {
    onRegister();
  }
}
</script>



<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Alfa+Slab+One&family=Montserrat:wght@400;700&display=swap');

.auth-wrapper {
  /* Hlavný wrapper stránky autentifikácie */
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100vw;
  height: 100vh;
  min-height: 520px;
  background: #e6eaee;
}

/* Ľavý farebný pruh */
.left-strip {
  position: absolute;
  top: 0;
  left: 0;
  bottom: 0;
  width: 35%;
  background: #243746;
  z-index: 1;
}

/* Karta formulára */
.auth-card {
  width: 820px;
  max-width: 92%;
  padding: 28px;
  border-radius: 10px;
  background: #36506a;
  color: #ffffff;
  box-shadow: 8px 10px 20px rgba(0,0,0,0.35);
  z-index: 2; /* above left-strip */
  font-size: 1rem; /* sets base for child scaling if needed */
}

/* Nadpis */
.hero {
  font-family: 'Alfa Slab One', serif;
  font-size: min(9vw, 72px); /* max 72px, scales down smoothly */
  line-height: 1.1;
  text-align: center;
  letter-spacing: 1px;
  margin: 6px 0;
}

/* Podnadpis */
.lead {
  font-family: 'Montserrat', sans-serif;
  font-weight: 700;
  text-align: center;
}

/* Štýl vstupov */
.pill-input {
  width: 54ch;
  max-width: 80%;
  border-radius: 22px;
  background: #e0e0e0;
  box-shadow: -6px 6px 0 rgba(0,0,0,0.12);
}

/* LOGIN FORM */
.form-column {
  display: flex;
  flex-direction: column;
  gap: 20px;
  align-items: center;
  max-width: 520px;
  margin: 0 auto;
}

/* REGISTRATION FORM */
.form-grid {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 12px 16px;
  margin: 0 auto;
}

.form-grid > .pill-input {
  max-width: 48%;
  box-sizing: border-box;
}

/* Riadok tlačidiel */
.actions-row {
  display: flex;
  justify-content: flex-end;
  width: 98%;
  margin-top: 6px;
}

/* Tlačidlá login/register */
.action-btn {
  background: #1f364a;
  color: #fff;
  border-radius: 22px;
  padding: 8px 18px;
  box-shadow: -6px 6px 0 rgba(0,0,0,0.12);
}

/* Link pre prepínanie medzi login a register */
.switch-link {
  margin-top: 18px;
  text-align: right;
  font-weight: 700;
}

.switch-link a {
  color: #ffffffa9;
  cursor: pointer;
  text-decoration: underline;
}

/* RESPONZÍVNE ÚPRAVY */
@media (max-width: 700px) {
  .form-grid > .pill-input { max-width: 90%; }
  .actions-row { justify-content: center; }
}
</style>
