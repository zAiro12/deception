<script setup>
import { computed, onMounted, onUnmounted, reactive, watch } from 'vue'

const STORAGE_KEY = 'deception-match-v1'
const MIN_PLAYERS = 2
const MAX_PLAYERS = 20
const MIN_WEAPONS_PER_PLAYER = 1

const categories = [
  {
    key: 'contundenti',
    label: 'Armi contundenti',
    color: '#f97316',
    weapons: [
      'Mattone',
      'Padella',
      'Estintore',
      'Chiave inglese',
      'Manubrio',
      'Martello',
      'Bastone',
      'Tubo',
      'Mazza',
      'Sasso',
      'Vaso',
    ],
  },
  {
    key: 'soffocamento',
    label: 'Armi da soffocamento / strangolamento',
    color: '#6366f1',
    weapons: [
      'Corda',
      'Filo metallico',
      'Cavo elettrico',
      'Catena',
      'Frusta',
      'Cuscino',
      'Sacchetto di plastica',
      'Mani',
      'Sciarpa',
      'Nastro adesivo',
    ],
  },
  {
    key: 'taglio',
    label: 'Armi da taglio o perforanti',
    color: '#ef4444',
    weapons: [
      'Forbici',
      'Spada',
      'Trapano',
      'Taglierino',
      'Rasoio',
      'Ascia',
      'Sega',
      'Cacciavite',
      'Punteruolo',
      'Bottiglia rotta',
      'Coltello',
    ],
  },
  {
    key: 'distanza',
    label: 'Armi a distanza',
    color: '#0ea5e9',
    weapons: [
      'Pistola',
      'Fucile da cecchino',
      'Arco con freccia',
      'Balestra',
      'Fionda',
      'Cerbottana',
      'Fiocina',
      'Taser',
      'Granata',
    ],
  },
  {
    key: 'chimiche',
    label: 'Armi chimiche, farmaci o incendiarie',
    color: '#22c55e',
    weapons: [
      'Veleno',
      'Acido',
      'Farmaco',
      'Siringa',
      'Molotov',
      'Accendino',
      'Candeggina',
      'Gas',
      'Spray tossico',
    ],
  },
]

const weaponPool = categories.flatMap((category) =>
  category.weapons.map((name, index) => ({
    id: `${category.key}-${index}`,
    name,
    category: category.label,
    categoryKey: category.key,
    color: category.color,
  })),
)

const state = reactive({
  playersCount: 4,
  weaponsPerPlayer: 2,
  names: ['Giocatore 1', 'Giocatore 2', 'Giocatore 3', 'Giocatore 4'],
  players: [],
})

const formError = reactive({ message: '' })

const totalWeaponsNeeded = computed(
  () => state.playersCount * state.weaponsPerPlayer,
)

const hasGame = computed(() => state.players.length > 0)
let saveTimeoutId = null

const syncNamesLength = (nextCount) => {
  const safeCount = Math.max(
    MIN_PLAYERS,
    Math.min(MAX_PLAYERS, Number(nextCount) || MIN_PLAYERS),
  )
  if (state.names.length < safeCount) {
    for (let i = state.names.length + 1; i <= safeCount; i += 1) {
      state.names.push(`Giocatore ${i}`)
    }
  }
  if (state.names.length > safeCount) {
    state.names.length = safeCount
  }
}

const shuffle = (items) => {
  const copy = [...items]
  for (let i = copy.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[copy[i], copy[j]] = [copy[j], copy[i]]
  }
  return copy
}

const startGame = () => {
  formError.message = ''
  const playersCount = Number(state.playersCount)
  const weaponsPerPlayer = Number(state.weaponsPerPlayer)

  if (!Number.isInteger(playersCount) || playersCount < 2 || playersCount > 20) {
    formError.message = 'Il numero di giocatori deve essere tra 2 e 20.'
    return
  }

  if (
    !Number.isInteger(weaponsPerPlayer) ||
    weaponsPerPlayer < 1 ||
    weaponsPerPlayer > weaponPool.length
  ) {
    formError.message = 'Numero armi non valido.'
    return
  }

  if (playersCount * weaponsPerPlayer > weaponPool.length) {
    formError.message = `Armi insufficienti: massimo ${Math.floor(weaponPool.length / playersCount)} per giocatore.`
    return
  }

  const trimmedNames = state.names
    .slice(0, playersCount)
    .map((name, index) => name.trim() || `Giocatore ${index + 1}`)

  const shuffled = shuffle(weaponPool)
  state.players = trimmedNames.map((name, playerIndex) => {
    const start = playerIndex * weaponsPerPlayer
    const assigned = shuffled.slice(start, start + weaponsPerPlayer).map((weapon) => ({
      ...weapon,
      disabled: false,
    }))

    return {
      id: `player-${playerIndex}`,
      name,
      weapons: assigned,
    }
  })
}

const toggleWeapon = (playerId, weaponId) => {
  const player = state.players.find((entry) => entry.id === playerId)
  const weapon = player?.weapons.find((entry) => entry.id === weaponId)
  if (weapon) {
    weapon.disabled = !weapon.disabled
  }
}

const resetGame = () => {
  state.players = []
  formError.message = ''
}

const normalizeInteger = (value, fallback, min, max) => {
  const numeric = Number(value)
  if (!Number.isInteger(numeric)) return fallback
  return Math.max(min, Math.min(max, numeric))
}

const saveState = () => {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state))
}

const scheduleStateSave = () => {
  if (saveTimeoutId) {
    clearTimeout(saveTimeoutId)
  }
  saveTimeoutId = setTimeout(() => {
    saveState()
    saveTimeoutId = null
  }, 200)
}

const loadState = () => {
  const raw = localStorage.getItem(STORAGE_KEY)
  if (!raw) return

  try {
    const parsed = JSON.parse(raw)
    const playersCount = normalizeInteger(parsed.playersCount, 4, MIN_PLAYERS, MAX_PLAYERS)
    const maxWeaponsByPlayers = Math.floor(weaponPool.length / playersCount)
    state.playersCount = playersCount
    state.weaponsPerPlayer = normalizeInteger(
      parsed.weaponsPerPlayer,
      2,
      MIN_WEAPONS_PER_PLAYER,
      maxWeaponsByPlayers,
    )
    state.names = Array.isArray(parsed.names)
      ? parsed.names.map((name) => String(name ?? ''))
      : []
    syncNamesLength(state.playersCount)
    state.players = Array.isArray(parsed.players) ? parsed.players : []
  } catch {
    localStorage.removeItem(STORAGE_KEY)
  }
}

watch(
  () => state.playersCount,
  (nextCount) => {
    syncNamesLength(nextCount)
  },
)

watch(
  state,
  () => {
    scheduleStateSave()
  },
  { deep: true },
)

onMounted(() => {
  loadState()
})

onUnmounted(() => {
  if (saveTimeoutId) {
    clearTimeout(saveTimeoutId)
  }
})
</script>

<template>
  <main class="app-shell">
    <header class="hero">
      <h1>Deception · Armory Setup</h1>
      <p>Configura la partita, distribuisci armi uniche e traccia quelle disabilitate.</p>
    </header>

    <section class="panel setup-panel">
      <h2>Prompt iniziale</h2>
      <div class="setup-grid">
        <label>
          Giocatori
          <input v-model.number="state.playersCount" type="number" min="2" max="20" />
        </label>
        <label>
          Armi per giocatore
          <input
            v-model.number="state.weaponsPerPlayer"
            type="number"
            min="1"
            :max="weaponPool.length"
          />
        </label>
      </div>

      <div class="names-list">
        <label v-for="(name, index) in state.names" :key="`name-${index}`">
          Nome giocatore {{ index + 1 }}
          <input v-model="state.names[index]" type="text" maxlength="30" />
        </label>
      </div>

      <p class="summary">Armi richieste: {{ totalWeaponsNeeded }} / {{ weaponPool.length }}</p>
      <p v-if="formError.message" class="error">{{ formError.message }}</p>

      <div class="actions">
        <button class="primary" type="button" @click="startGame">Distribuisci armi</button>
        <button class="ghost" type="button" @click="resetGame">Nuova configurazione</button>
      </div>
    </section>

    <section v-if="hasGame" class="players-grid">
      <article v-for="player in state.players" :key="player.id" class="panel player-card">
        <h3>{{ player.name }}</h3>
        <div class="weapons-grid">
          <button
            v-for="weapon in player.weapons"
            :key="weapon.id"
            type="button"
            class="weapon-box"
            :aria-pressed="weapon.disabled"
            :class="[{ disabled: weapon.disabled }, `cat-${weapon.categoryKey}`]"
            :style="{ '--category-color': weapon.color }"
            @click="toggleWeapon(player.id, weapon.id)"
          >
            <strong>{{ weapon.name }}</strong>
            <small>{{ weapon.category }}</small>
          </button>
        </div>
      </article>
    </section>
  </main>
</template>
