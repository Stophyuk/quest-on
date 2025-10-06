import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'
import Quests from '../views/Quests.vue'
import Calendar from '../views/Calendar.vue'
import Profile from '../views/Profile.vue'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/quests',
    name: 'Quests',
    component: Quests
  },
  {
    path: '/calendar',
    name: 'Calendar',
    component: Calendar
  },
  {
    path: '/profile',
    name: 'Profile',
    component: Profile
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router