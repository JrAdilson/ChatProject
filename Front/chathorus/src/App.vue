<template>
  <v-app id="inspire">
    <v-main>
      <router-view /> 
    </v-main>
  </v-app>
</template>

<script>
import LoginChat from './views/LoginChat.vue'
export default {
  name: 'App',

  components: {
    LoginChat,
  },
  
  data: () => ({
    //
  }),
};
</script>
